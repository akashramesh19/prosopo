//
//  PersonasWidget.swift
//  PersonasWidget
//
//  Created by Akash Ramesh on 9/10/2025.
//

import WidgetKit
import SwiftUI

/// Displays the favourite persona set by the user in the main app.
struct FavoriteEntry: TimelineEntry {
    let date: Date
    let favorite: FavoritePersona?
}

struct FavoriteProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoriteEntry {
        FavoriteEntry(date: .now,
                      favorite: FavoritePersona(id: "sample", name: "Set a Favourite", prompt: ""))
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoriteEntry) -> ()) {
        completion(FavoriteEntry(date: .now, favorite: FavoriteStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoriteEntry>) -> ()) {
        let fav = FavoriteStore.load()
        let entry = FavoriteEntry(date: .now, favorite: fav)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct FavoriteWidgetView: View {
    var entry: FavoriteProvider.Entry

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
            VStack(spacing: 8) {
                Text("Favourite Persona")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let fav = entry.favorite {
                    Link(destination: URL(string: "prosopo://copy?id=\(fav.id)")!) {
                        Text(fav.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    Text("Tap to copy prompt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Link(destination: URL(string: "prosopo://")!) {
                        Text("No favourite set")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    Text("Set a favourite in Prosopo")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                }
            }
            .padding(12)
        }
        .padding(8)
    }
}

struct PersonasWidget: Widget {
    let kind: String = "PersonasWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoriteProvider()) { entry in
            FavoriteWidgetView(entry: entry)
        }
        .configurationDisplayName("Favourite Persona")
        .description("Shows your favourite persona. Tap to copy its prompt.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
