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
        VStack(alignment: .leading, spacing: 6) {
            // 헤더
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "F68566"))
                Text("오늘의 습관")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "282828"))
                Spacer()
            }
            .background(Color(hex: "FFFDFA"))
            .cornerRadius(6)
            .padding(.bottom, 8)
            
            if entry.habits.isEmpty {
                // 습관이 없을 때
                VStack(spacing: 3) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "A4D0B4"))
                    Text("습관을 추가해보세요")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "282828").opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "FFFDFA"))
                .cornerRadius(6)
            } else {
                // 습관 목록
                LazyVStack(alignment: .leading, spacing: 3) {
                    ForEach(entry.habits, id: \.id) { habit in
                        SharedHabitRowView(habit: habit)
                    }
                }
            }
        }
        .background(Color(hex: "FFFDFA"))
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