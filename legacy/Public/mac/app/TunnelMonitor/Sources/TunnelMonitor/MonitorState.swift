import Foundation
import SwiftUI
import Combine
import AppKit

struct DedupBlock: Decodable, Equatable {
    let reachable: Bool
    let state: String?
    let checked_at: String?
}

struct Snapshot: Decodable, Equatable {
    struct PingCheck: Decodable, Equatable {
        let target: String?
        let ok: Bool?
        let latency_ms: Double?
    }
    struct DNSCheck: Decodable, Equatable {
        let host: String?
        let resolved: String?
        let expected: String?
        let match: Bool?
    }
    struct Checks: Decodable, Equatable {
        let tunnel: PingCheck
        let remote_wan: PingCheck
        let our_internet: PingCheck
        let dns: DNSCheck
    }

    let timestamp: String
    let alert_state: String
    let failure_count: Int
    let checks: Checks
    let dedup: DedupBlock
    let last_alert_sent_at: String?
    let last_recovery_sent_at: String?
    let diagnosis: String
    let down_since: String?
    let schema_version: Int?

    var schemaVersionLabel: String {
        if let v = schema_version { return String(v) }
        return "1 (legacy)"
    }

    /// Stale if older than ~12 minutes (2× default 5-minute check interval).
    func isStale(relativeTo now: Date = Date(), thresholdSeconds: TimeInterval = 720) -> Bool {
        guard let start = parseISO8601(timestamp) else { return false }
        return now.timeIntervalSince(start) > thresholdSeconds
    }

    private func parseISO8601(_ s: String) -> Date? {
        let f1 = ISO8601DateFormatter()
        f1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f1.date(from: s) { return d }
        let f2 = ISO8601DateFormatter()
        return f2.date(from: s)
    }

    enum CodingKeys: String, CodingKey {
        case timestamp, alert_state, failure_count, checks
        case gateway_dedup, udr7_dedup, router_dedup
        case last_alert_sent_at, last_recovery_sent_at, diagnosis, down_since
        case schema_version
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        timestamp = try c.decode(String.self, forKey: .timestamp)
        alert_state = try c.decode(String.self, forKey: .alert_state)
        failure_count = try c.decode(Int.self, forKey: .failure_count)
        checks = try c.decode(Checks.self, forKey: .checks)
        last_alert_sent_at = try c.decodeIfPresent(String.self, forKey: .last_alert_sent_at)
        last_recovery_sent_at = try c.decodeIfPresent(String.self, forKey: .last_recovery_sent_at)
        diagnosis = try c.decode(String.self, forKey: .diagnosis)
        down_since = try c.decodeIfPresent(String.self, forKey: .down_since)
        schema_version = try c.decodeIfPresent(Int.self, forKey: .schema_version)

        if let g = try c.decodeIfPresent(DedupBlock.self, forKey: .gateway_dedup) {
            dedup = g
        } else if let u = try c.decodeIfPresent(DedupBlock.self, forKey: .udr7_dedup) {
            dedup = u
        } else if let r = try c.decodeIfPresent(DedupBlock.self, forKey: .router_dedup) {
            dedup = r
        } else {
            dedup = DedupBlock(reachable: false, state: nil, checked_at: nil)
        }
    }
}

enum MonitorPaths {
    static let stateFile = "/opt/tunnel-monitor/state.json"
    static let logFile   = "/opt/tunnel-monitor/monitor.log"
    static let config    = "/opt/tunnel-monitor/config.env"
    static let installDir = "/opt/tunnel-monitor"
}

private struct ReloadPayload {
    let snapshot: Snapshot?
    let error: String?
    let presentation: StatusPresentation
    let widgetSnapshot: WidgetStatusSnapshot?
}

@MainActor
final class MonitorState: ObservableObject {

    @Published private(set) var snapshot: Snapshot?
    @Published private(set) var lastLoadError: String?
    @Published private(set) var lastReadAt: Date = .distantPast
    @Published private(set) var presentation: StatusPresentation = .unavailable(error: nil)

    private var timer: Timer?
    private var refreshInterval: TimeInterval = AppPreferences.refreshIntervalSeconds
    private var reloadInFlight = false

    init() {
        reload()
        restartTimer()
    }

    func setRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = max(5, interval)
        restartTimer()
    }

    private func restartTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.reload() }
        }
    }

    func reload() {
        guard !reloadInFlight else { return }
        reloadInFlight = true
        let statePath = MonitorPaths.stateFile
        let syncWidget = AppPreferences.widgetSyncEnabled

        Task.detached(priority: .utility) {
            let payload = Self.loadPayload(from: statePath, syncWidget: syncWidget)
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.apply(payload)
                self.reloadInFlight = false
            }
        }
    }

    private func apply(_ payload: ReloadPayload) {
        if snapshot != payload.snapshot { snapshot = payload.snapshot }
        if lastLoadError != payload.error { lastLoadError = payload.error }
        if presentation != payload.presentation { presentation = payload.presentation }
        lastReadAt = Date()
        if let widget = payload.widgetSnapshot {
            AppGroupSync.writeWidgetSnapshot(widget)
        }
    }

    nonisolated private static func loadPayload(from path: String, syncWidget: Bool) -> ReloadPayload {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url, options: [.uncached, .mappedIfSafe])
            let decoded = try JSONDecoder().decode(Snapshot.self, from: data)
            let readAt = Date()
            let presentation = StatusPresentation.from(snapshot: decoded, readAt: readAt)
            let widget: WidgetStatusSnapshot? = syncWidget
                ? WidgetStatusSnapshot.from(presentation: presentation, lastCheck: decoded.timestamp)
                : nil
            return ReloadPayload(snapshot: decoded, error: nil, presentation: presentation, widgetSnapshot: widget)
        } catch {
            let presentation = StatusPresentation.unavailable(error: error.localizedDescription)
            return ReloadPayload(snapshot: nil, error: error.localizedDescription, presentation: presentation, widgetSnapshot: nil)
        }
    }

    var alertState: String { snapshot?.alert_state ?? "UNKNOWN" }
    var diagnosis: String  { snapshot?.diagnosis ?? "NO_STATE_FILE" }
    var trafficLight: TrafficLight { presentation.trafficLight }

    var menuBarColor: Color { trafficLight.color }
}
