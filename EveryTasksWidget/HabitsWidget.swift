import WidgetKit
import SwiftUI

struct HabitsProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitsEntry {
        HabitsEntry(date: Date(), habits: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitsEntry) -> ()) {
        let habits = WidgetDataManager.shared.getSharedData()?.habits ?? []
        let entry = HabitsEntry(date: Date(), habits: Array(habits.prefix(4)))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let habits = WidgetDataManager.shared.getSharedData()?.habits ?? []
        let entry = HabitsEntry(date: Date(), habits: Array(habits.prefix(4)))
        
        // 15분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct HabitsEntry: TimelineEntry {
    let date: Date
    let habits: [SharedHabit]
}

struct HabitsWidgetEntryView: View {
    var entry: HabitsProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.blue)
                Text("오늘의 습관")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom, 4)
            
            if entry.habits.isEmpty {
                // 습관이 없을 때
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("습관을 추가해보세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 습관 목록
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.habits, id: \.id) { habit in
                        SharedHabitRowView(habit: habit)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}



struct HabitsWidget: Widget {
    let kind: String = "com.chaeeun.everytask.habits.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitsProvider()) { entry in
            HabitsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("습관 위젯")
        .description("오늘의 습관을 확인하고 체크할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
} 