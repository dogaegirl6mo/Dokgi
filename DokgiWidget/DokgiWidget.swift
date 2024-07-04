//
//  DokgiWidget.swift
//  DokgiWidget
//
//  Created by 예슬 on 6/5/24.
//

import RxCocoa
import RxSwift
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    let disposeBag = DisposeBag()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), passage: "누군가를 있는 그대로 존중한다는 것은 그만큼 어려운 일이다.")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), passage: "누군가를 있는 그대로 존중한다는 것은 그만큼 어려운 일이다.")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let midnight = Calendar.current.startOfDay(for: currentDate)
        let nextDayMidnight = Calendar.current.date(byAdding: .day, value: 1, to: midnight)!
        CoreDataManager.shared.readPassage()
        let randomPassage = CoreDataManager.shared.passageData.value.randomElement()?.passage ?? "누군가를 있는 그대로 존중한다는 것은 그만큼 어려운 일이다."
        let entry = SimpleEntry(date: midnight, passage: randomPassage)
        let timeline = Timeline(entries: [entry], policy: .after(nextDayMidnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var passage: String
}

struct DokgiWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Image("doubleQuotationMarks")
                Spacer()
            }
            Text(entry.passage)
                .font(.subheadline)
                .padding(EdgeInsets(top: 7, leading: 15, bottom: 16, trailing: 0))
                .foregroundColor(.black)
            Spacer(minLength: 0)
        }
    }
}

struct DokgiWidget: Widget {
    let kind: String = "DokgiWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DokgiWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("구절")
        .description("작성한 구절을 보여줍니다. 처음에는 기본 문구가 들어가요. \n하루에 하나씩 새로운 구절을 만나보세요!")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    DokgiWidget()
} timeline: {
    SimpleEntry(date: .now, passage: "")
    SimpleEntry(date: .distantFuture, passage: "")
}
