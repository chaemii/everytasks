import SwiftUI

// 공통 습관 행 컴포넌트
struct SharedHabitRowView: View {
    let habit: SharedHabit
    
    var body: some View {
        HStack(spacing: 6) {
            // 체크박스
            Button(action: {
                WidgetDataManager.shared.toggleHabit(id: habit.id)
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(habit.isCompleted ? Color(hex: "A4D0B4") : Color(hex: "282828").opacity(0.3))
                    .scaleEffect(habit.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompleted)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 습관 제목
            Text(habit.title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .strikethrough(habit.isCompleted)
                .foregroundColor(habit.isCompleted ? Color(hex: "282828").opacity(0.7) : Color(hex: "282828"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .background(Color(hex: "FFFDFA"))
        .cornerRadius(6)
    }
}

// 공통 할일 행 컴포넌트
struct SharedTodoRowView: View {
    let todo: SharedTodo
    
    var body: some View {
        HStack(spacing: 6) {
            // 체크박스
            Button(action: {
                WidgetDataManager.shared.toggleTodo(id: todo.id)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(todo.isCompleted ? Color(hex: "A4D0B4") : Color(hex: "282828").opacity(0.3))
                    .scaleEffect(todo.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: todo.isCompleted)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 할일 제목
            Text(todo.title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? Color(hex: "282828").opacity(0.7) : Color(hex: "282828"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .background(Color(hex: "FFFDFA"))
        .cornerRadius(6)
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 