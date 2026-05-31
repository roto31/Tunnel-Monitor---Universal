import SwiftUI
import Combine

@main
struct UniversalVPNMonitorApp: App {
    @StateObject private var model = UvpnStateModel()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 8) {
                Text(model.title).font(.headline)
                if let detail = model.detail {
                    Text(detail).font(.caption).foregroundStyle(.secondary)
                }
                if !model.steps.isEmpty {
                    DisclosureGroup("Suggested steps") {
                        ForEach(Array(model.steps.enumerated()), id: \.offset) { idx, step in
                            Text("\(idx + 1). \(step)").font(.caption)
                        }
                    }
                }
                Button("Refresh") { model.reload() }
                Button("Run check (uvpn)") { model.runCheck() }
            }
            .padding(12)
            .frame(width: 320)
            .onAppear { model.startPolling() }
        } label: {
            Circle()
                .fill(model.color)
                .frame(width: 10, height: 10)
        }
    }
}

final class UvpnStateModel: ObservableObject {
    @Published var title = "uvpn"
    @Published var detail: String?
    @Published var steps: [String] = []
    @Published var color = Color.gray

    private let stateURL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config/uvpn/state.json")
    private var timer: Timer?

    func startPolling() {
        reload()
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.reload()
        }
    }

    func reload() {
        guard let data = try? Data(contentsOf: stateURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            title = "No state"
            detail = "Run: uvpn check"
            color = .gray
            return
        }
        let diagnosis = json["diagnosis"] as? String ?? "UNKNOWN"
        let light = json["traffic_light"] as? String ?? "grey"
        title = diagnosis
        detail = (json["issues"] as? [String])?.first
        steps = json["recommended_steps"] as? [String] ?? []
        switch light {
        case "green": color = .green
        case "yellow": color = .yellow
        case "red": color = .red
        default: color = .gray
        }
    }

    func runCheck() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/uvpn")
        task.arguments = ["check"]
        try? task.run()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.reload() }
    }
}
