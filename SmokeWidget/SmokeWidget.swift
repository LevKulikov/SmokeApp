//
//  SmokeWidget.swift
//  SmokeWidget
//
//  Created by Лев Куликов on 05.02.2023.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    /// **Widget property to store data**
    @AppStorage("SmokeWidget", store: UserDefaults(suiteName: "group.someballs.SmokeApp"))
    var lastSmokeItemData = Data()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), smokeItem: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        guard let smokeItem = try? JSONDecoder().decode(SmokeItemData.self, from: lastSmokeItemData) else { return }
        dump(smokeItem)
        let entry = SimpleEntry(date: Date(), configuration: configuration, smokeItem: smokeItem)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            guard let smokeItem = try? JSONDecoder().decode(SmokeItemData.self, from: lastSmokeItemData) else { return }
            let entry = SimpleEntry(date: entryDate, configuration: configuration, smokeItem: smokeItem)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let smokeItem: SmokeItemData?
}

struct SmokeWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.smokeItem?.date ?? entry.date, style: .date)
                .padding(10)
            
            Text(String(entry.smokeItem?.amount ?? 0))
                .bold()
                .font(.system(size: 40))
                .padding(.leading, 40)
        }
    }
}

struct SmokeWidget: Widget {
    let kind: String = "SmokeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SmokeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SmokeApp Widget")
        .description("Track your smoke count from screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct SmokeWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmokeWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), smokeItem: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
