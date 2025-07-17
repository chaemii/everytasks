import Foundation
import SwiftUI

// MARK: - Task Model (for MainView)
struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var isCompleted: Bool
    var priority: TaskPriority
    var streak: Int
    var createdDate: Date
    var completedDate: Date?
    
    init(id: UUID = UUID(), title: String, subtitle: String = "", priority: TaskPriority = .normal, streak: Int = 0) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = false
        self.priority = priority
        self.streak = streak
        self.createdDate = Date()
        self.completedDate = nil
    }
}

// MARK: - Task Priority
enum TaskPriority: String, CaseIterable, Codable {
    case low = "낮음"
    case normal = "보통"
    case high = "높음"
    
    var displayText: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return ADHDTheme.mainPoint
        case .normal:
            return ADHDTheme.subColor2
        case .high:
            return ADHDTheme.subColor3
        }
    }
}

// MARK: - Todo Model
struct Todo: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TodoPriority
    var category: TodoCategory
    var targetDate: Date
    var createdDate: Date
    var completedDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String = "", priority: TodoPriority = .medium, category: TodoCategory = .personal, targetDate: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.category = category
        self.targetDate = targetDate
        self.createdDate = Date()
        self.completedDate = nil
    }
}

// MARK: - Todo Priority
enum TodoPriority: String, CaseIterable, Codable {
    case low = "낮음"
    case medium = "보통"
    case high = "높음"
    case urgent = "긴급"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return Color(hex: "FBEACC") ?? .green
        case .medium:
            return Color(hex: "A4D0B4") ?? .blue
        case .high:
            return Color(hex: "C1E2FF") ?? Color(hex: "F68566")
        case .urgent:
            return Color(hex: "F68566") ?? .red
        }
    }
}

// MARK: - Todo Category
enum TodoCategory: String, CaseIterable, Codable {
    case personal = "개인"
    case work = "업무"
    case study = "학습"
    case health = "건강"
    case habit = "습관"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .personal:
            return "person"
        case .work:
            return "briefcase"
        case .study:
            return "book"
        case .health:
            return "heart"
        case .habit:
            return "arrow.clockwise"
        }
    }
}

// MARK: - Habit Model
struct Habit: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var color: String // Color를 String으로 저장 (hex 값)
    var isActive: Bool
    var createdDate: Date
    var completedDates: [Date]
    var selectedWeekdays: [Int] // 0=일요일, 1=월요일, ..., 6=토요일
    var selectedDayOfMonth: Int? // 월간 반복시 선택된 일자 (1-31)
    
    init(id: UUID = UUID(), title: String, description: String = "", category: HabitCategory = .health, frequency: HabitFrequency = .daily, color: String = "F68566", selectedWeekdays: [Int] = [], selectedDayOfMonth: Int? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.frequency = frequency
        self.color = color
        self.isActive = true
        self.createdDate = Date()
        self.completedDates = []
        self.selectedWeekdays = selectedWeekdays
        self.selectedDayOfMonth = selectedDayOfMonth
    }
}

// MARK: - Habit Category
enum HabitCategory: String, CaseIterable, Codable {
    case health = "건강"
    case study = "학습"
    case personal = "개인"
    case work = "업무"
    case exercise = "운동"
    
    var displayText: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .health:
            return "heart"
        case .study:
            return "book"
        case .personal:
            return "person"
        case .work:
            return "briefcase"
        case .exercise:
            return "figure.walk"
        }
    }
}

// MARK: - Habit Frequency
enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "매일"
    case weekly = "매주"
    case monthly = "매월"
    
    var displayName: String {
        return self.rawValue
    }
    
    var requiresSelection: Bool {
        switch self {
        case .daily:
            return false
        case .weekly, .monthly:
            return true
        }
    }
}

// MARK: - Focus Session Model
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var duration: TimeInterval
    var startTime: Date
    var endTime: Date?
    var isCompleted: Bool
    var notes: String?
    
    init(id: UUID = UUID(), title: String, duration: TimeInterval = 1500) { // 25 minutes default
        self.id = id
        self.title = title
        self.duration = duration
        self.startTime = Date()
        self.endTime = nil
        self.isCompleted = false
        self.notes = nil
    }
}

// MARK: - Statistics Model
struct Statistics: Codable {
    var totalTodos: Int
    var completedTodos: Int
    var totalHabits: Int
    var completedHabits: Int
    var totalFocusSessions: Int
    var totalFocusTime: TimeInterval
    var streakDays: Int
    var lastUpdated: Date
    
    init() {
        self.totalTodos = 0
        self.completedTodos = 0
        self.totalHabits = 0
        self.completedHabits = 0
        self.totalFocusSessions = 0
        self.totalFocusTime = 0
        self.streakDays = 0
        self.lastUpdated = Date()
    }
    
    var completionRate: Double {
        guard totalTodos > 0 else { return 0.0 }
        return Double(completedTodos) / Double(totalTodos)
    }
    
    var habitCompletionRate: Double {
        guard totalHabits > 0 else { return 0.0 }
        return Double(completedHabits) / Double(totalHabits)
    }
    
    var averageFocusTime: TimeInterval {
        guard totalFocusSessions > 0 else { return 0.0 }
        return totalFocusTime / Double(totalFocusSessions)
    }
} 
