import SwiftUI

// MARK: - ADHD Focus App Color Palette
struct ADHDTheme {
    
    // MARK: - Core Colors
    static let appBackground = Color(hex: "F7F5F2")      // 앱 배경색
    static let cardBackground = Color(hex: "FFFDFA")     // 카드, 리스트 컴포넌트 배경색
    static let mainPoint = Color(hex: "A4D0B4")          // 메인 포인트 컬러
    static let subColor1 = Color(hex: "FBEACC")          // 서브 컬러 1
    static let subColor2 = Color(hex: "C1E2FF")          // 서브 컬러 2
    static let subColor3 = Color(hex: "FF7539")          // 서브 컬러 3
    static let charcoal = Color(hex: "282828")           // 블랙 대용 차콜 컬러
    
    // MARK: - Semantic Colors
    static let primaryText = charcoal
    static let secondaryText = charcoal.opacity(0.7)
    static let accentColor = mainPoint
    static let successColor = Color.green
    static let warningColor = subColor3
    static let errorColor = Color.red
    
    // MARK: - Priority Colors
    static let priorityHigh = subColor3
    static let priorityMedium = subColor2
    static let priorityLow = mainPoint

    
    // MARK: - Calendar Colors
    static let calendarBackground = cardBackground
    static let calendarSelected = mainPoint
    static let calendarToday = mainPoint.opacity(0.3)
    static let calendarEvent = subColor2
    static let calendarEventAlt = subColor3
    
    // MARK: - Progress Colors
    static let progressBackground = mainPoint.opacity(0.2)
    static let progressFill = mainPoint
    
    // MARK: - Card Modifier
    struct CardModifier: ViewModifier {
        let cornerRadius: CGFloat
        let shadowRadius: CGFloat
        
        init(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) {
            self.cornerRadius = cornerRadius
            self.shadowRadius = shadowRadius
        }
        
        func body(content: Content) -> some View {
            content
                .background(cardBackground)
                .cornerRadius(cornerRadius)
                .shadow(
                    color: charcoal.opacity(0.1),
                    radius: shadowRadius,
                    x: 0,
                    y: 2
                )
        }
    }
    
    // MARK: - Modern Button Modifier
    struct ModernButton: ViewModifier {
        let backgroundColor: Color
        let foregroundColor: Color
        
        init(backgroundColor: Color = mainPoint, foregroundColor: Color = .white) {
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
        }
        
        func body(content: Content) -> some View {
            content
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .cornerRadius(8)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.1), value: true)
        }
    }
    
    // MARK: - Floating Action Button
    struct FloatingActionButton: View {
        let action: () -> Void
        let icon: String
        
        var body: some View {
            Button(action: action) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(mainPoint)
                            .shadow(color: charcoal.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
            }
            .modernButton(backgroundColor: mainPoint, foregroundColor: .white)
        }
    }
    
    // MARK: - Progress Ring
    struct ProgressRing: View {
        let progress: Double
        let size: CGFloat
        let thickness: CGFloat
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(progressBackground, lineWidth: thickness)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressFill,
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
            }
            .frame(width: size, height: size)
        }
    }
    
    // MARK: - Priority Badge
    struct PriorityBadge: View {
        let priority: TaskPriority
        
        var body: some View {
            Text(priority.displayText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(priority.color)
                )
        }
    }
    
    // MARK: - Calendar Day View
    struct CalendarDayView: View {
        let date: Date
        let isSelected: Bool
        let isToday: Bool
        let hasEvents: Bool
        
        var body: some View {
            VStack(spacing: 2) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : primaryText)
                
                if hasEvents {
                    HStack(spacing: 2) {
                        Circle()
                            .fill(calendarEvent)
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(calendarEventAlt)
                            .frame(width: 4, height: 4)
                    }
                }
            }
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(backgroundColor)
            )
        }
        
        private var backgroundColor: Color {
            if isSelected {
                return calendarSelected
            } else if isToday {
                return calendarToday
            } else {
                return Color.clear
            }
        }
    }
    
    // MARK: - Task Card
    struct TaskCard: View {
        let task: Task
        let onToggle: () -> Void
        
        var body: some View {
            HStack(spacing: 12) {
                // Checkbox
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? mainPoint : charcoal.opacity(0.3))
                }
                
                // Task Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryText)
                        .strikethrough(task.isCompleted)
                    
                    if !task.subtitle.isEmpty {
                        Text(task.subtitle)
                            .font(.caption)
                            .foregroundColor(secondaryText)
                    }
                }
                
                Spacer()
                
                // Priority Badge
                if task.priority != .normal {
                    PriorityBadge(priority: task.priority)
                }
                
                // Streak Icon
                if task.streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundColor(subColor3)
                        Text("\(task.streak)")
                            .font(.caption)
                            .foregroundColor(secondaryText)
                    }
                }
            }
            .padding(16)
            .background(cardBackground)
            .cornerRadius(12)
            .shadow(color: charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle(cornerRadius: CGFloat = 12, shadowRadius: CGFloat = 4) -> some View {
        modifier(ADHDTheme.CardModifier(cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func modernButton(backgroundColor: Color = ADHDTheme.mainPoint, foregroundColor: Color = .white) -> some View {
        modifier(ADHDTheme.ModernButton(backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
}

// MARK: - Color Extensions
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
    
    static let appBackground = ADHDTheme.appBackground
    static let cardBackground = ADHDTheme.cardBackground
    static let mainPoint = ADHDTheme.mainPoint
    static let subColor1 = ADHDTheme.subColor1
    static let subColor2 = ADHDTheme.subColor2
    static let subColor3 = ADHDTheme.subColor3
    static let charcoal = ADHDTheme.charcoal
    static let primaryText = ADHDTheme.primaryText
    static let secondaryText = ADHDTheme.secondaryText
    static let accentColor = ADHDTheme.accentColor
    static let successColor = ADHDTheme.successColor
    static let warningColor = ADHDTheme.warningColor
    static let errorColor = ADHDTheme.errorColor
} 
