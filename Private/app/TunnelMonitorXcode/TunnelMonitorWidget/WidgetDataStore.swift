import Foundation

struct WidgetStatusSnapshot: Codable, Equatable {
    let trafficLight: String
    let reason: String
    let issues: [String]
    let downDurationText: String?
    let lastCheck: String
}

enum WidgetDataStore {
    static let groupID = "group.com.tunnel.monitor"
    static let fileName = "tunnel-status.json"

    static func load() -> WidgetStatusSnapshot? {
        guard let base = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        ) else { return nil }
        let file = base
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: file) else { return nil }
        return try? JSONDecoder().decode(WidgetStatusSnapshot.self, from: data)
    }
}
