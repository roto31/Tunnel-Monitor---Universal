import WidgetKit
import SwiftUI

struct TunnelMonitorWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetStatusSnapshot?
}

struct TunnelMonitorWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TunnelMonitorWidgetEntry {
        TunnelMonitorWidgetEntry(
            date: Date(),
            snapshot: WidgetStatusSnapshot(
                trafficLight: "green",
                reason: "HEALTHY",
                issues: [],
                downDurationText: nil,
                lastCheck: "—"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TunnelMonitorWidgetEntry) -> Void) {
        completion(TunnelMonitorWidgetEntry(date: Date(), snapshot: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TunnelMonitorWidgetEntry>) -> Void) {
        let entry = TunnelMonitorWidgetEntry(date: Date(), snapshot: WidgetDataStore.load())
        let next = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date().addingTimeInterval(300)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct TunnelMonitorWidgetEntryView: View {
    var entry: TunnelMonitorWidgetProvider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let light = trafficLightColor(entry.snapshot?.trafficLight ?? "yellow")
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Circle()
                    .fill(light)
                    .frame(width: 14, height: 14)
                Text(statusTitle(entry.snapshot?.trafficLight ?? "yellow"))
                    .font(.headline)
            }
            Text(entry.snapshot?.reason ?? "No data")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(family == .systemSmall ? 2 : 3)
            if family != .systemSmall, let down = entry.snapshot?.downDurationText {
                Text(down)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
            }
            if family != .systemSmall, let issue = entry.snapshot?.issues.first {
                Text(issue)
                    .font(.caption2)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            Text("Checked: \(entry.snapshot?.lastCheck ?? "—")")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .modifier(TMWidgetBackgroundModifier(light: light))
    }
}

private struct TMWidgetBackgroundModifier: ViewModifier {
    let light: Color

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content
                .containerBackground(for: .widget) {
                    ZStack {
                        light.opacity(0.12)
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.clear)
                    }
                }
        } else {
            content
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension TunnelMonitorWidgetEntryView {
    private func trafficLightColor(_ raw: String) -> Color {
        switch raw {
        case "green":  return .green
        case "red":    return .red
        default:       return .yellow
        }
    }

    private func statusTitle(_ raw: String) -> String {
        switch raw {
        case "green":  return "UP"
        case "red":    return "DOWN"
        default:       return "Issues"
        }
    }
}

@main
struct TunnelMonitorWidgetBundle: WidgetBundle {
    var body: some Widget {
        TunnelMonitorWidget()
    }
}

struct TunnelMonitorWidget: Widget {
    let kind = "TunnelMonitorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TunnelMonitorWidgetProvider()) { entry in
            TunnelMonitorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tunnel Monitor")
        .description("Site-to-site VPN status from tunnel-monitor.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
