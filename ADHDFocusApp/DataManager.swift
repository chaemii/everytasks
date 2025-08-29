import Foundation
import SwiftUI
import WidgetKit

class DataManager: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var habits: [Habit] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var statistics = Statistics()
    
    private let todosKey = "todos"
    private let habitsKey = "habits"
    private let focusSessionsKey = "focusSessions"
    private let statisticsKey = "statistics"
    private let dataVersionKey = "dataVersion"
    private let currentDataVersion = "1.0"
    private let widgetUserDefaults = UserDefaults(suiteName: "group.everytasks")
    
    init() {
        loadData()
        setupSampleDataIfNeeded()
        shareDataWithWidget() // 초기 데이터를 위젯과 공유
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
    
    // MARK: - Data Persistence with Version Control
    private func saveData() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let todosData = try encoder.encode(todos)
            UserDefaults.standard.set(todosData, forKey: todosKey)
            
            let habitsData = try encoder.encode(habits)
            UserDefaults.standard.set(habitsData, forKey: habitsKey)
            
            let focusSessionsData = try encoder.encode(focusSessions)
            UserDefaults.standard.set(focusSessionsData, forKey: focusSessionsKey)
            
            let statisticsData = try encoder.encode(statistics)
            UserDefaults.standard.set(statisticsData, forKey: statisticsKey)
            
            // Save data version for future migrations
            UserDefaults.standard.set(currentDataVersion, forKey: dataVersionKey)
            
            // Force UserDefaults to save immediately
            UserDefaults.standard.synchronize()
            
            // 위젯과 데이터 공유
            shareDataWithWidget()
            
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            if let todosData = UserDefaults.standard.data(forKey: todosKey) {
                todos = try decoder.decode([Todo].self, from: todosData)
            }
            
            if let habitsData = UserDefaults.standard.data(forKey: habitsKey) {
                habits = try decoder.decode([Habit].self, from: habitsData)
            }
            
            if let focusSessionsData = UserDefaults.standard.data(forKey: focusSessionsKey) {
                focusSessions = try decoder.decode([FocusSession].self, from: focusSessionsData)
            }
            
            if let statisticsData = UserDefaults.standard.data(forKey: statisticsKey) {
                statistics = try decoder.decode(Statistics.self, from: statisticsData)
            }
            
        } catch {
            print("Error loading data: \(error)")
            // If loading fails, reset to empty state
            todos = []
            habits = []
            focusSessions = []
            statistics = Statistics()
        }
    }
    
    // MARK: - Widget Data Sharing
    private func shareDataWithWidget() {
        let today = Date()
        let calendar = Calendar.current
        
        // 모든 활성 습관들 (오늘 완료 여부 표시)
        let todayHabits = habits.filter { $0.isActive }.map { habit -> SharedHabit in
            let isCompletedToday = habit.completedDates.contains { completedDate in
                calendar.isDate(completedDate, inSameDayAs: today)
            }
            return SharedHabit(
                id: habit.id.uuidString,
                title: habit.title,
                isCompleted: isCompletedToday,
                date: today
            )
        }
        
        // 모든 할일들 (완료되지 않은 것 우선, 최대 5개)
        let todayTodos = todos
            .sorted { !$0.isCompleted && $1.isCompleted } // 미완료 우선
            .prefix(5)
            .map { todo -> SharedTodo in
                return SharedTodo(
                    id: todo.id.uuidString,
                    title: todo.title,
                    isCompleted: todo.isCompleted,
                    date: todo.createdDate
                )
            }
        
        let sharedData = SharedData(
            habits: Array(todayHabits),
            todos: Array(todayTodos),
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(sharedData) {
            widgetUserDefaults?.set(encoded, forKey: "sharedData")
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    // MARK: - Data Migration
    private func migrateDataIfNeeded() {
        let savedVersion = UserDefaults.standard.string(forKey: dataVersionKey) ?? "0.0"
        
        if savedVersion != currentDataVersion {
            // Perform data migration here if needed
            // For now, just update the version
            UserDefaults.standard.set(currentDataVersion, forKey: dataVersionKey)
        }
    }
    
    // MARK: - Sample Data (only if no data exists)
    private func setupSampleDataIfNeeded() {
        // 처음 다운받은 사용자에게는 빈 상태로 시작
        // 샘플 데이터는 제거하여 사용자가 직접 추가하도록 함
        // guard todos.isEmpty && habits.isEmpty else { return }
        
        // 샘플 데이터 생성 비활성화
        // 사용자가 직접 할일과 습관을 추가할 수 있도록 빈 상태 유지
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
    
    // MARK: - Data Backup and Restore
    func exportData() -> Data? {
        let exportData = ExportData(
            todos: todos,
            habits: habits,
            focusSessions: focusSessions,
            statistics: statistics,
            version: currentDataVersion,
            exportDate: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(exportData)
    }
    
    func importData(_ data: Data) -> Bool {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let importData = try? decoder.decode(ExportData.self, from: data) else {
            return false
        }
        
        // Validate data version compatibility
        guard importData.version == currentDataVersion else {
            return false
        }
        
        todos = importData.todos
        habits = importData.habits
        focusSessions = importData.focusSessions
        statistics = importData.statistics
        
        saveData()
        updateStatistics()
        
        return true
    }
}

// MARK: - Export Data Structure
struct ExportData: Codable {
    let todos: [Todo]
    let habits: [Habit]
    let focusSessions: [FocusSession]
    let statistics: Statistics
    let version: String
    let exportDate: Date
} 