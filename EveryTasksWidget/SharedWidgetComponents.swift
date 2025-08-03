import SwiftUI

// 공통 습관 행 컴포넌트
struct SharedHabitRowView: View {
    let habit: SharedHabit
    
    var body: some View {
        HStack(spacing: 8) {
            // 체크박스
            Button(action: {
                WidgetDataManager.shared.toggleHabit(id: habit.id)
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompleted ? .green : .gray)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            // 습관 제목
            Text(habit.title)
                .font(.caption)
                .lineLimit(1)
                .strikethrough(habit.isCompleted)
                .foregroundColor(habit.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
    }
}

// 공통 할일 행 컴포넌트
struct SharedTodoRowView: View {
    let todo: SharedTodo
    
    var body: some View {
        HStack(spacing: 8) {
            // 체크박스
            Button(action: {
                WidgetDataManager.shared.toggleTodo(id: todo.id)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .gray)
                    .font(.system(size: 16))
            }
            .buttonStyle(PlainButtonStyle())
            
            // 할일 제목
            Text(todo.title)
                .font(.caption)
                .lineLimit(1)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
    }
} 