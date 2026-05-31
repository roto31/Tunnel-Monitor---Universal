import SwiftUI
import Combine

@main
struct UniversalVPNMonitorApp: App {
    @StateObject private var model = UvpnStateModel()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: LiquidGlassDesign.containerSpacing) {
                HStack {
                    Circle().fill(model.color).frame(width: 10, height: 10)
                    Text(model.title).font(.headline)
                }
                .modifier(TMGlassBadgeModifier(tint: model.color))

                if model.isStale {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.exclamationmark")
                        Text("State stale (>12 min) — run check")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.orange)
                    .modifier(TMGlassCardModifier(tint: .orange))
                }

                if let detail = model.detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }

                Group {
                    if !model.statsSummary.isEmpty {
                        DisclosureGroup("Statistics") {
                            Text(model.statsSummary).font(.caption.monospaced())
                        }
                    }
                    if !model.logPreview.isEmpty {
                        DisclosureGroup("Logs") {
                            Text(model.logPreview).font(.caption.monospaced()).lineLimit(8)
                        }
                    }
                    if !model.steps.isEmpty {
                        DisclosureGroup("Diagnostics") {
                            ForEach(Array(model.steps.enumerated()), id: \.offset) { idx, step in
                                Text("\(idx + 1). \(step)").font(.caption)
                            }
                        }
                    }
                }
                .modifier(TMGlassCardModifier(tint: model.color))

                HStack {
                    Button("Refresh") { model.reload() }
                    Button("Run check") { model.runCheck() }
                }
                HStack {
                    Button("Explain") { model.runExplain() }
                    Button("Preflight") { model.runPreflight() }
                    Button("Adapters") { model.runAdapters() }
                }
            }
            .padding(LiquidGlassDesign.cardPadding)
            .frame(width: 340)
            .modifier(TMAppWindowBackgroundModifier())
            .onAppear { model.startPolling() }
            .sheet(isPresented: $model.showSheet) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.sheetTitle).font(.headline)
                    ScrollView {
                        Text(model.sheetText).font(.caption.monospaced()).frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Button("Close") { model.showSheet = false }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(16)
                .frame(width: 420, height: 320)
                .modifier(TMAppWindowBackgroundModifier())
            }
        } label: {
            Circle().fill(model.color).frame(width: 10, height: 10)
        }
    }
}

enum LiquidGlassDesign {
    static let sectionCornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 12
    static let containerSpacing: CGFloat = 14
    static let staleThresholdMinutes: Double = 12
}

private struct TMAppWindowBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.background {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.06), Color.clear, Color.blue.opacity(0.04)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
            }
        } else {
            content.background(.regularMaterial)
        }
    }
}

private struct TMGlassCardModifier: ViewModifier {
    var tint: Color
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *), !reduceTransparency {
            content.padding(LiquidGlassDesign.cardPadding)
                .glassEffect(.regular.tint(tint.opacity(0.25)), in: RoundedRectangle(cornerRadius: LiquidGlassDesign.sectionCornerRadius, style: .continuous))
        } else {
            content.padding(LiquidGlassDesign.cardPadding)
                .background(tint.opacity(0.08), in: RoundedRectangle(cornerRadius: LiquidGlassDesign.sectionCornerRadius, style: .continuous))
        }
    }
}

private struct TMGlassBadgeModifier: ViewModifier {
    let tint: Color

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.padding(.horizontal, 8).padding(.vertical, 4)
                .glassEffect(.regular.tint(tint.opacity(0.2)), in: Capsule())
        } else {
            content.padding(.horizontal, 8).padding(.vertical, 4)
                .background(tint.opacity(0.15), in: Capsule())
        }
    }
}

final class UvpnStateModel: ObservableObject {
    @Published var title = "uvpn"
    @Published var detail: String?
    @Published var steps: [String] = []
    @Published var statsSummary = ""
    @Published var logPreview = ""
    @Published var color = Color.gray
    @Published var isStale = false
    @Published var showSheet = false
    @Published var sheetTitle = ""
    @Published var sheetText = ""

    private let stateURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/uvpn/state.json")
    private var timer: Timer?

    func startPolling() {
        reload()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in self?.reload() }
    }

    func reload() {
        guard let data = try? Data(contentsOf: stateURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            title = "No state"
            detail = "Run: uvpn check"
            color = .gray
            statsSummary = ""
            logPreview = ""
            isStale = true
            return
        }
        title = json["diagnosis"] as? String ?? "UNKNOWN"
        detail = (json["issues"] as? [String])?.first
        steps = json["recommended_steps"] as? [String] ?? []
        if let stats = json["statistics"] as? [String: Any],
           let encoded = try? JSONSerialization.data(withJSONObject: stats),
           let text = String(data: encoded, encoding: .utf8) {
            statsSummary = String(text.prefix(600))
        }
        if let logs = json["logs"] as? [String] {
            logPreview = logs.suffix(6).joined(separator: "\n")
        }
        if let ts = json["timestamp"] as? String {
            isStale = Self.isOlderThanMinutes(ts, minutes: LiquidGlassDesign.staleThresholdMinutes)
        } else {
            isStale = true
        }
        switch json["traffic_light"] as? String {
        case "green": color = .green
        case "yellow": color = .yellow
        case "red": color = .red
        default: color = .gray
        }
    }

    func runCheck() {
        _ = runUvpn(args: ["check"])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.reload() }
    }

    func runExplain() {
        present(title: "Explain", text: runUvpn(args: ["explain"]) ?? "uvpn explain failed")
    }

    func runPreflight() {
        present(title: "Preflight", text: runUvpn(args: ["preflight"]) ?? "uvpn preflight failed")
    }

    func runAdapters() {
        present(title: "Adapters", text: runUvpn(args: ["adapters"]) ?? "uvpn adapters failed")
    }

    private func present(title: String, text: String) {
        sheetTitle = title
        sheetText = text
        showSheet = true
    }

    private func runUvpn(args: [String]) -> String? {
        let paths = ["/usr/local/bin/uvpn", "/opt/homebrew/bin/uvpn"]
        let bin = paths.first { FileManager.default.isExecutableFile(atPath: $0) } ?? "uvpn"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: bin)
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }

    private static func isOlderThanMinutes(_ iso: String, minutes: Double) -> Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = formatter.date(from: iso)
        if date == nil {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: iso)
        }
        guard let parsed = date else { return true }
        return Date().timeIntervalSince(parsed) > minutes * 60
    }
}
