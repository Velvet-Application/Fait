import SwiftUI
import WidgetKit

private struct WidgetSnapshot: Codable {
    let updatedAt: Date
    let pendingCount: Int
    let activeCount: Int
    let nextTitle: String?
    let nextDate: Date?
    let headline: String?
}

private struct FAITWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

private struct FAITWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> FAITWidgetEntry {
        FAITWidgetEntry(date: .now, snapshot: sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (FAITWidgetEntry) -> Void) {
        completion(FAITWidgetEntry(date: .now, snapshot: load() ?? sample))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FAITWidgetEntry>) -> Void) {
        let entry = FAITWidgetEntry(date: .now, snapshot: load() ?? sample)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private var sample: WidgetSnapshot {
        WidgetSnapshot(
            updatedAt: .now,
            pendingCount: 2,
            activeCount: 4,
            nextTitle: "Rendez-vous dentaire",
            nextDate: Calendar.current.date(byAdding: .day, value: 1, to: .now),
            headline: "Une décision attend votre accord"
        )
    }

    private func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: "group.com.velvetapplication.fait"),
              let data = defaults.data(forKey: "fait.widget.snapshot") else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}

private struct SealMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.66, green: 0.77, blue: 0.69).opacity(0.45))
            Circle().fill(Color(red: 0.18, green: 0.42, blue: 0.31)).padding(5)
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 32, height: 32)
    }
}

private struct FAITWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: FAITWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            default:
                mediumView
            }
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.97, blue: 0.95),
                    Color(red: 0.86, green: 0.92, blue: 0.88),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .widgetURL(URL(string: "fait://detected"))
    }

    private var smallView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                SealMark()
                Text("FAIT.").font(.headline.weight(.heavy))
                Spacer()
            }
            Spacer()
            Text("\(entry.snapshot.pendingCount)")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.11, green: 0.29, blue: 0.22))
            Text(entry.snapshot.pendingCount == 1 ? "décision attend" : "décisions attendent")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Label("Ouvrir Détecté", systemImage: "arrow.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(red: 0.18, green: 0.42, blue: 0.31))
        }
        .padding(4)
    }

    private var mediumView: some View {
        HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    SealMark()
                    VStack(alignment: .leading, spacing: 1) {
                        Text("FAIT.").font(.headline.weight(.heavy))
                        Text("Votre quotidien").font(.caption2).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(entry.snapshot.headline ?? "Tout est sous contrôle")
                    .font(.headline)
                    .lineLimit(2)
                HStack(spacing: 12) {
                    metric(value: entry.snapshot.pendingCount, label: "à confirmer")
                    metric(value: entry.snapshot.activeCount, label: "dossiers")
                }
            }

            Divider().opacity(0.35)

            VStack(alignment: .leading, spacing: 8) {
                Label("Prochain", systemImage: "calendar")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.18, green: 0.42, blue: 0.31))
                Text(entry.snapshot.nextTitle ?? "Aucun rendez-vous")
                    .font(.headline)
                    .lineLimit(2)
                if let date = entry.snapshot.nextDate {
                    Text(date, format: .dateTime.day().month(.wide).hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Mis à jour maintenant")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(4)
    }

    private func metric(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("\(value)").font(.title3.bold()).foregroundStyle(Color(red: 0.11, green: 0.29, blue: 0.22))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

struct FAITDailyWidget: Widget {
    let kind = "FAITDailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FAITWidgetProvider()) { entry in
            FAITWidgetView(entry: entry)
        }
        .configurationDisplayName("FAIT. quotidien")
        .description("Vos décisions en attente et votre prochain rendez-vous, sans afficher le contenu de vos e-mails.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct FAITWidgetBundle: WidgetBundle {
    var body: some Widget {
        FAITDailyWidget()
    }
}
