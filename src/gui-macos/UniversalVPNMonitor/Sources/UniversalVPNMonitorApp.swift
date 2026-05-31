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
            }
            .padding(LiquidGlassDesign.cardPadding)
            .frame(width: 340)
            .modifier(TMAppWindowBackgroundModifier())
            .onAppear { model.startPolling() }
        } label: {
            Circle().fill(model.color).frame(width: 10, height: 10)
        }
    }
}

enum LiquidGlassDesign {
    static let sectionCornerRadius: CGFloat = 14
    static let cardPadding: CGFloat = 12
    static let containerSpacing: CGFloat = 14
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
        switch json["traffic_light"] as? String {
        case "green": color = .green
        case "yellow": color = .yellow
        case "red": color = .red
        default: color = .gray
        }
    }

    func runCheck() {
        let paths = ["/usr/local/bin/uvpn", "/opt/homebrew/bin/uvpn"]
        let bin = paths.first { FileManager.default.isExecutableFile(atPath: $0) } ?? "uvpn"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: bin)
        task.arguments = ["check"]
        try? task.run()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.reload() }
    }
}
