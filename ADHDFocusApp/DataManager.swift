import Foundation
import SwiftUI

class DataManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var habits: [Habit] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var statistics = Statistics()
    
    private let todosKey = "todos"
    private let habitsKey = "habits"
    private let focusSessionsKey = "focusSessions"
    private let statisticsKey = "statistics"
    
    init() {
        loadData()
        setupSampleData()
    }
    
    // MARK: - Todo Management
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveData()
        updateStatistics()
    }
    
    func updateTodo(_ todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveData()
            updateStatistics()
        }
    }
    
    func deleteTodo(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        saveData()
        updateStatistics()
    }
    
    func toggleTodoCompletion(_ todo: Todo) {
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()
        
        if updatedTodo.isCompleted {
            updatedTodo.completedDate = Date()
        } else {
            updatedTodo.completedDate = nil
        }
        
        updateTodo(updatedTodo)
    }
    
    // MARK: - Habit Management
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveData()
        updateStatistics()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveData()
            updateStatistics()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveData()
        updateStatistics()
    }
    
    func completeHabit(_ habit: Habit, for date: Date = Date()) {
        var updatedHabit = habit
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // 이미 완료된 날짜인지 확인
        if let existingIndex = updatedHabit.completedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: startOfDay) }) {
            // 완료된 날짜라면 제거 (토글)
            updatedHabit.completedDates.remove(at: existingIndex)
        } else {
            // 완료되지 않은 날짜라면 추가
            updatedHabit.completedDates.append(startOfDay)
        }
        
        updateHabit(updatedHabit)
    }
    
    // MARK: - Habit Date Validation
    func isHabitApplicableForDate(_ habit: Habit, date: Date) -> Bool {
        let calendar = Calendar.current
        
        switch habit.frequency {
        case .daily:
            return true
        case .weekly:
            let weekday = calendar.component(.weekday, from: date) - 1 // 0=일요일, 1=월요일, ..., 6=토요일
            return habit.selectedWeekdays.contains(weekday)
        case .monthly:
            let dayOfMonth = calendar.component(.day, from: date)
            return habit.selectedDayOfMonth == dayOfMonth
        }
    }
    
    // MARK: - Focus Session Management
    func addFocusSession(_ session: FocusSession) {
        focusSessions.append(session)
        saveData()
        updateStatistics()
    }
    
    func updateFocusSession(_ session: FocusSession) {
        if let index = focusSessions.firstIndex(where: { $0.id == session.id }) {
            focusSessions[index] = session
            saveData()
            updateStatistics()
        }
    }
    
    func completeFocusSession(_ session: FocusSession) {
        var updatedSession = session
        updatedSession.endTime = Date()
        updatedSession.isCompleted = true
        updateFocusSession(updatedSession)
    }
    
    // MARK: - Task Management (for MainView)
    func addTask(_ task: Task) {
        // Task를 Todo로 변환해서 추가 (간단 변환 예시)
        let newTodo = Todo(title: task.title, description: task.subtitle, priority: .medium, category: .personal, targetDate: Date())
        todos.append(newTodo)
        saveData()
        updateStatistics()
    }
    
    // MARK: - Statistics
    private func updateStatistics() {
        statistics.totalTodos = todos.count
        statistics.completedTodos = todos.filter { $0.isCompleted }.count
        statistics.totalHabits = habits.count
        statistics.totalFocusSessions = focusSessions.count
        statistics.totalFocusTime = focusSessions.reduce(0) { total, session in
            if let endTime = session.endTime {
                return total + endTime.timeIntervalSince(session.startTime)
            }
            return total
        }
        statistics.lastUpdated = Date()
        
        // Calculate streak
        statistics.streakDays = calculateStreak()
        
        saveData()
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        while true {
            let dayTodos = todos.filter { todo in
                calendar.isDate(todo.targetDate, inSameDayAs: currentDate) && todo.isCompleted
            }
            
            let dayHabits = habits.filter { habit in
                habit.completedDates.contains { calendar.isDate($0, inSameDayAs: currentDate) }
            }
            
            if dayTodos.isEmpty && dayHabits.isEmpty {
                break
            }
            
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
        }
        
        return streak
    }
    
    // MARK: - Data Persistence
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(encoded, forKey: todosKey)
        }
        
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(focusSessions) {
            UserDefaults.standard.set(encoded, forKey: focusSessionsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            todos = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: focusSessionsKey),
           let decoded = try? JSONDecoder().decode([FocusSession].self, from: data) {
            focusSessions = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode(Statistics.self, from: data) {
            statistics = decoded
        }
    }
    
    // MARK: - Sample Data
    private func setupSampleData() {
        // Only add sample data if no data exists
        guard todos.isEmpty && habits.isEmpty else { return }
        
        // Add sample todos
        let sampleTodos = [
            Todo(title: "물마시기", description: "하루 8잔 마시기", priority: .medium, category: .habit),
            Todo(title: "운동하기", description: "30분 걷기", priority: .high, category: .health),
            Todo(title: "매일 블로그", description: "3개 쓰기", priority: .medium, category: .personal),
            Todo(title: "카레 요리하기", description: "맛있겠당", priority: .high, category: .personal),
            Todo(title: "독서하기", description: "30분 독서", priority: .low, category: .study),
            Todo(title: "명상하기", description: "10분 명상", priority: .medium, category: .health)
        ]
        
        // Add sample habits
        let sampleHabits = [
            Habit(title: "물마시기", description: "하루 8잔 마시기", category: .health),
            Habit(title: "운동하기", description: "30분 걷기", category: .exercise),
            Habit(title: "독서하기", description: "30분 독서", category: .study)
        ]
        
        todos = sampleTodos
        habits = sampleHabits
        saveData()
        updateStatistics()
    }
    
    // MARK: - Utility Methods
    func getTodosForDate(_ date: Date) -> [Todo] {
        return todos.filter { todo in
            Calendar.current.isDate(todo.createdDate, inSameDayAs: date)
        }
    }
    
    func getHabitsForDate(_ date: Date) -> [Habit] {
        return habits.filter { habit in
            habit.isActive && habit.completedDates.contains { completedDate in
                Calendar.current.isDate(completedDate, inSameDayAs: date)
            }
        }
    }
    
    func getCompletionRateForDate(_ date: Date) -> Double {
        let dayTodos = getTodosForDate(date)
        guard !dayTodos.isEmpty else { return 0.0 }
        
        let completedCount = dayTodos.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(dayTodos.count)
    }
} 