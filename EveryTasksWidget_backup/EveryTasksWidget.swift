//
//  EveryTasksWidget.swift
//  EveryTasksWidget
//
//  Created by cham on 8/3/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), sharedData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), sharedData: WidgetDataManager.shared.getSharedData())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedData = WidgetDataManager.shared.getSharedData()
        let entry = SimpleEntry(date: Date(), sharedData: sharedData)
        
        // 15분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let sharedData: SharedData?
}

struct EveryTasksWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 헤더
            HStack {
                Text("오늘의 할일")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            if let sharedData = entry.sharedData {
                // 습관 섹션
                if !sharedData.habits.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("습관")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        
                        ForEach(sharedData.habits.prefix(3), id: \.id) { habit in
                            HabitRowView(habit: habit)
                        }
                    }
                    .padding(.bottom, 4)
                }
                
                // 할일 섹션
                if !sharedData.todos.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("할일")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                        
                        ForEach(sharedData.todos.prefix(3), id: \.id) { todo in
                            TodoRowView(todo: todo)
                        }
                    }
                }
                
                if sharedData.habits.isEmpty && sharedData.todos.isEmpty {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("할일을 추가해보세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("데이터를 불러올 수 없습니다")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
    }
}

struct HabitRowView: View {
    let habit: SharedHabit
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                WidgetDataManager.shared.toggleHabit(id: habit.id)
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompleted ? .green : .gray)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(habit.title)
                .font(.caption)
                .lineLimit(1)
                .strikethrough(habit.isCompleted)
                .foregroundColor(habit.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
    }
}

struct TodoRowView: View {
    let todo: SharedTodo
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                WidgetDataManager.shared.toggleTodo(id: todo.id)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(todo.title)
                .font(.caption)
                .lineLimit(1)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
    }
}

struct EveryTasksWidget: Widget {
    let kind: String = "EveryTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            EveryTasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("EveryTasks 위젯")
        .description("오늘의 습관과 할일을 확인하고 체크할 수 있습니다.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


