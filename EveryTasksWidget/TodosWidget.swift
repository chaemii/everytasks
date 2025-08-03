import WidgetKit
import SwiftUI

struct TodosProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodosEntry {
        TodosEntry(date: Date(), todos: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodosEntry) -> ()) {
        let todos = WidgetDataManager.shared.getSharedData()?.todos ?? []
        let entry = TodosEntry(date: Date(), todos: Array(todos.prefix(4)))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let todos = WidgetDataManager.shared.getSharedData()?.todos ?? []
        let entry = TodosEntry(date: Date(), todos: Array(todos.prefix(4)))
        
        // 15분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct TodosEntry: TimelineEntry {
    let date: Date
    let todos: [SharedTodo]
}

struct TodosWidgetEntryView: View {
    var entry: TodosProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Image(systemName: "checklist")
                    .foregroundColor(.orange)
                Text("오늘의 할일")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom, 4)
            
            if entry.todos.isEmpty {
                // 할일이 없을 때
                VStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("할일을 추가해보세요")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 할일 목록
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.todos, id: \.id) { todo in
                        SharedTodoRowView(todo: todo)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}



struct TodosWidget: Widget {
    let kind: String = "com.chaeeun.everytask.todos.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodosProvider()) { entry in
            TodosWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("할일 위젯")
        .description("오늘의 할일을 확인하고 체크할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
} 