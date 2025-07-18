import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod = 0 // 0: 이번 주, 1: 이번 달, 2: 전체
    @State private var selectedTab = 0 // 0: 습관, 1: 집중 시간
    @State private var currentWeekOffset = 0 // 주간 오프셋 추가
    @State private var currentMonthOffset = 0 // 월간 오프셋 추가
    
    var body: some View {
        ZStack {
            // 배경색
            Color.appBackground
                .ignoresSafeArea(.all, edges: .all)
            
            VStack(spacing: 0) {
            // Header
            headerView
            
            // Period Selector
            periodSelector
            
            // Statistics Content
            statisticsContent
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("statistics_title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("statistics_subtitle".localized)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { index in
                Button(action: {
                    selectedPeriod = index
                }) {
                    Text(periodTitle(for: index))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedPeriod == index ? .white : .secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedPeriod == index ? Color.mainPoint : Color.clear)
                            }
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .padding(.top, 16)
    }
    
    // MARK: - Statistics Content
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: 40) { // 20에서 40으로 변경 (두 배)
                // Week Navigation (이번주 선택시에만 표시)
                if selectedPeriod == 0 {
                    weekNavigationView
                }
                
                // Month Navigation (이번달 선택시에만 표시)
                if selectedPeriod == 1 {
                    monthNavigationView
                }
                
                // Overall Progress
                overallProgressView
                
                // Todo Statistics with Chart
                todoStatisticsWithChartView
                
                // Habit Statistics with Chart
                habitStatisticsWithChartView
                
                // Focus Time Statistics with Chart
                focusTimeStatisticsWithChartView
            }
            .padding()
        }
    }
    
    // MARK: - Overall Progress View
    private var overallProgressView: some View {
        VStack(spacing: 16) {
            Text("statistics_overall_progress".localized)
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(spacing: 20) {
                // Todo Progress
                VStack(spacing: 8) {
                    ADHDTheme.ProgressRing(
                        progress: todoCompletionRate,
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(todoCompletionRate * 100))%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("todos".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                // Habit Progress
                VStack(spacing: 8) {
                    ADHDTheme.ProgressRing(
                        progress: habitCompletionRate,
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(habitCompletionRate * 100))%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("habits".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                // Focus Time Progress
                VStack(spacing: 8) {
                    ADHDTheme.ProgressRing(
                        progress: focusTimeProgress,
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(totalFocusTime)\(Locale.current.identifier.hasPrefix("ko") ? "분" : "m")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("focus_time".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding()
            .cardStyle()
        }
    }
    
    // MARK: - Todo Statistics with Chart View
    private var todoStatisticsWithChartView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("statistics_todo_statistics".localized)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Chart first
                weeklyTodoChart
                
                // Simplified statistics
                HStack(spacing: 20) {
                    // Completed/Total
                    VStack(spacing: 4) {
                        Text("\(completedTodosCount)/\(totalTodosCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        Text("daily_todo_completion_rate".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Completion Rate
                    VStack(spacing: 4) {
                        Text("\(Int(todoCompletionRate * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.successColor)
                        Text("completion_rate".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Incomplete
                    VStack(spacing: 4) {
                        Text("\(incompleteTodosCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.warningColor)
                        Text("incomplete_todos".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.horizontal, 20) // 20으로 증가
                .padding(.bottom, 20) // 20으로 증가
            }
            .cardStyle()
        }
    }
    
    // MARK: - Habit Statistics with Chart View
    private var habitStatisticsWithChartView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("statistics_habit_statistics".localized)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Chart first
                weeklyHabitChart
                
                // Simplified statistics
                HStack(spacing: 20) {
                    // Completed/Total
                    VStack(spacing: 4) {
                        Text("\(completedHabitsCount)/\(totalHabitsCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        Text("daily_habit_completion_rate".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Completion Rate
                    VStack(spacing: 4) {
                        Text("\(Int(habitCompletionRate * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.successColor)
                        Text("completion_rate".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Longest Streak
                    VStack(spacing: 4) {
                        Text("\(longestStreak)\(Locale.current.identifier.hasPrefix("ko") ? "일" : "d")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.warningColor)
                        Text("longest_streak".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.horizontal, 20) // 20으로 증가
                .padding(.bottom, 20) // 20으로 증가
            }
            .cardStyle()
        }
    }
    
    // MARK: - Focus Time Statistics with Chart View
    private var focusTimeStatisticsWithChartView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("statistics_focus_statistics".localized)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 16) {
                // Chart first
                weeklyFocusChart
                
                // Simplified statistics
                HStack(spacing: 20) {
                    // Total Focus Time
                    VStack(spacing: 4) {
                        Text("\(totalFocusTime)\(Locale.current.identifier.hasPrefix("ko") ? "분" : "m")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        Text("focus_duration_total".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Completed Sessions
                    VStack(spacing: 4) {
                        Text("\(completedFocusSessionsCount)개")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.successColor)
                        Text("focus_sessions_completed".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                    
                    // Average Duration
                    VStack(spacing: 4) {
                        Text("\(averageSessionDuration)\(Locale.current.identifier.hasPrefix("ko") ? "분" : "m")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        Text("focus_duration_average".localized)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                .padding(.horizontal, 20) // 20으로 증가
                .padding(.bottom, 20) // 20으로 증가
            }
            .cardStyle()
        }
    }
    
    // MARK: - Weekly Data Models
    struct WeeklyTodoData: Identifiable {
        let id = UUID()
        let weekday: String
        let totalCount: Int
        let completedCount: Int
        let completionRate: Double
    }
    
    struct WeeklyHabitData: Identifiable {
        let id = UUID()
        let weekday: String
        let totalCount: Int
        let completedCount: Int
        let completionRate: Double
    }
    
    struct WeeklyFocusData: Identifiable {
        let id = UUID()
        let weekday: String
        let sessionCount: Int
        let averageDuration: Int
    }
    
    // MARK: - Helper Methods
    private func periodTitle(for index: Int) -> String {
        switch index {
        case 0: return "this_week".localized
        case 1: return "this_month".localized
        case 2: return "all".localized
        default: return ""
        }
    }
    
    // MARK: - Week Navigation for Statistics
    private var weekNavigationView: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentWeekOffset -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primaryText)
                    .font(.system(size: 16, weight: .medium))
            }
            .background(.clear)
            
            Spacer()
            
            Text(getCurrentWeekRange())
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentWeekOffset += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primaryText)
                    .font(.system(size: 16, weight: .medium))
            }
            .background(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Month Navigation for Statistics
    private var monthNavigationView: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonthOffset -= 1
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.primaryText)
                    .font(.system(size: 16, weight: .medium))
            }
            .background(.clear)
            
            Spacer()
            
            Text(getCurrentMonthRange())
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    currentMonthOffset += 1
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primaryText)
                    .font(.system(size: 16, weight: .medium))
            }
            .background(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    private func getCurrentWeekRange() -> String {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? selectedDate
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = Locale.current.identifier.hasPrefix("ko") ? "M월 d일" : "M/d"
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    private func getCurrentMonthRange() -> String {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = Locale.current.identifier.hasPrefix("ko") ? "yyyy년 M월" : "MMM yyyy"
        
        return formatter.string(from: selectedDate)
    }
    
    private func getDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case 0: // 이번 주
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            return (weekStart, weekEnd)
        case 1: // 이번 달
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now
            return (monthStart, monthEnd)
        case 2: // 전체
            let distantPast = calendar.date(byAdding: .year, value: -10, to: now) ?? now
            return (distantPast, now)
        default:
            return (now, now)
        }
    }
    
    private func getTodosInRange() -> [Todo] {
        let (start, end) = getDateRange()
        return dataManager.todos.filter { todo in
            todo.targetDate >= start && todo.targetDate <= end
        }
    }
    
    private func getHabitsInRange() -> [Habit] {
        return dataManager.habits.filter { habit in
            // 활성화된 습관만 포함
            habit.isActive
        }
    }
    
    private func getFocusSessionsInRange() -> [FocusSession] {
        let (start, end) = getDateRange()
        return dataManager.focusSessions.filter { session in
            // 완료된 세션만 포함하고, endTime이 범위 내에 있는지 확인
            session.isCompleted && session.endTime != nil && 
            session.endTime! >= start && session.endTime! <= end
        }
    }
    
    // MARK: - Weekly Data Calculation
    private func getWeeklyTodoData() -> [WeeklyTodoData] {
        let weekdays = [
            "weekday_sun_short".localized,
            "weekday_mon_short".localized,
            "weekday_tue_short".localized,
            "weekday_wed_short".localized,
            "weekday_thu_short".localized,
            "weekday_fri_short".localized,
            "weekday_sat_short".localized
        ]
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? selectedDate
            let todosForDay = dataManager.todos.filter { todo in
                calendar.isDate(todo.targetDate, inSameDayAs: date)
            }
            
            let totalCount = todosForDay.count
            let completedCount = todosForDay.filter { $0.isCompleted }.count
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyTodoData(
                weekday: weekday,
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getWeeklyHabitData() -> [WeeklyHabitData] {
        let weekdays = [
            "weekday_sun_short".localized,
            "weekday_mon_short".localized,
            "weekday_tue_short".localized,
            "weekday_wed_short".localized,
            "weekday_thu_short".localized,
            "weekday_fri_short".localized,
            "weekday_sat_short".localized
        ]
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? selectedDate
            let activeHabits = dataManager.habits.filter { $0.isActive }
            
            var totalCount = 0
            var completedCount = 0
            
            for habit in activeHabits {
                if dataManager.isHabitApplicableForDate(habit, date: date) {
                    totalCount += 1
                    if habit.completedDates.contains(where: { completedDate in
                        calendar.isDate(completedDate, inSameDayAs: date)
                    }) {
                        completedCount += 1
                    }
                }
            }
            
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyHabitData(
                weekday: weekday,
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getWeeklyFocusData() -> [WeeklyFocusData] {
        let weekdays = [
            "weekday_sun_short".localized,
            "weekday_mon_short".localized,
            "weekday_tue_short".localized,
            "weekday_wed_short".localized,
            "weekday_thu_short".localized,
            "weekday_fri_short".localized,
            "weekday_sat_short".localized
        ]
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? selectedDate
            let sessionsForDay = dataManager.focusSessions.filter { session in
                session.isCompleted && session.endTime != nil &&
                calendar.isDate(session.endTime!, inSameDayAs: date)
            }
            
            let sessionCount = sessionsForDay.count
            let totalDuration = sessionsForDay.reduce(0) { total, session in
                total + Int(session.duration / 60)
            }
            let averageDuration = sessionCount > 0 ? totalDuration / sessionCount : 0
            
            return WeeklyFocusData(
                weekday: weekday,
                sessionCount: sessionCount,
                averageDuration: averageDuration
            )
        }
    }
    
    // MARK: - Period-based Data Calculation
    private func getTodoData() -> [WeeklyTodoData] {
        switch selectedPeriod {
        case 0: return getWeeklyTodoData()
        case 1: return getMonthlyTodoData()
        case 2: return getOverallTodoData()
        default: return getWeeklyTodoData()
        }
    }
    
    private func getHabitData() -> [WeeklyHabitData] {
        switch selectedPeriod {
        case 0: return getWeeklyHabitData()
        case 1: return getMonthlyHabitData()
        case 2: return getOverallHabitData()
        default: return getWeeklyHabitData()
        }
    }
    
    private func getFocusData() -> [WeeklyFocusData] {
        switch selectedPeriod {
        case 0: return getWeeklyFocusData()
        case 1: return getMonthlyFocusData()
        case 2: return getOverallFocusData()
        default: return getWeeklyFocusData()
        }
    }
    
    // MARK: - Monthly Data Calculation
    private func getMonthlyTodoData() -> [WeeklyTodoData] {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let monthStart = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        return (1...daysInMonth).map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? selectedDate
            
            let todosForDay = dataManager.todos.filter { todo in
                calendar.isDate(todo.targetDate, inSameDayAs: date)
            }
            
            let totalCount = todosForDay.count
            let completedCount = todosForDay.filter { $0.isCompleted }.count
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyTodoData(
                weekday: "\(day)일",
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getMonthlyHabitData() -> [WeeklyHabitData] {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let monthStart = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        return (1...daysInMonth).map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? selectedDate
            let activeHabits = dataManager.habits.filter { $0.isActive }
            
            var totalCount = 0
            var completedCount = 0
            
            for habit in activeHabits {
                if dataManager.isHabitApplicableForDate(habit, date: date) {
                    totalCount += 1
                    if habit.completedDates.contains(where: { completedDate in
                        calendar.isDate(completedDate, inSameDayAs: date)
                    }) {
                        completedCount += 1
                    }
                }
            }
            
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyHabitData(
                weekday: "\(day)일",
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getMonthlyFocusData() -> [WeeklyFocusData] {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let monthStart = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        return (1...daysInMonth).map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? selectedDate
            
            let sessionsForDay = dataManager.focusSessions.filter { session in
                session.isCompleted && session.endTime != nil &&
                calendar.isDate(session.endTime!, inSameDayAs: date)
            }
            
            let sessionCount = sessionsForDay.count
            let totalDuration = sessionsForDay.reduce(0) { total, session in
                total + Int(session.duration / 60)
            }
            let averageDuration = sessionCount > 0 ? totalDuration / sessionCount : 0
            
            return WeeklyFocusData(
                weekday: "\(day)일",
                sessionCount: sessionCount,
                averageDuration: averageDuration
            )
        }
    }
    
    // MARK: - Overall Data Calculation
    private func getOverallTodoData() -> [WeeklyTodoData] {
        let categories = ["할일", "습관", "집중"]
        
        return categories.enumerated().map { index, category in
            let todos = dataManager.todos
            let totalCount = todos.count
            let completedCount = todos.filter { $0.isCompleted }.count
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyTodoData(
                weekday: category,
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getOverallHabitData() -> [WeeklyHabitData] {
        let categories = ["할일", "습관", "집중"]
        
        return categories.enumerated().map { index, category in
            let habits = dataManager.habits.filter { $0.isActive }
            let totalCount = habits.count
            let completedCount = habits.filter { !$0.completedDates.isEmpty }.count
            let completionRate = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
            
            return WeeklyHabitData(
                weekday: category,
                totalCount: totalCount,
                completedCount: completedCount,
                completionRate: completionRate
            )
        }
    }
    
    private func getOverallFocusData() -> [WeeklyFocusData] {
        let categories = ["할일", "습관", "집중"]
        
        return categories.enumerated().map { index, category in
            let sessions = dataManager.focusSessions.filter { $0.isCompleted }
            let sessionCount = sessions.count
            let totalDuration = sessions.reduce(0) { total, session in
                total + Int(session.duration / 60)
            }
            let averageDuration = sessionCount > 0 ? totalDuration / sessionCount : 0
            
            return WeeklyFocusData(
                weekday: category,
                sessionCount: sessionCount,
                averageDuration: averageDuration
            )
        }
    }
    
    // MARK: - Computed Properties
    private var habitCompletionRate: Double {
        let habits = getHabitsInRange()
        guard !habits.isEmpty else { return 0.0 }
        
        let (start, end) = getDateRange()
        var totalCompletions = 0
        var totalPossible = 0
        
        for habit in habits {
            let calendar = Calendar.current
            var currentDate = start
            
            while currentDate <= end {
                if dataManager.isHabitApplicableForDate(habit, date: currentDate) {
                    totalPossible += 1
                    if habit.completedDates.contains(where: { completedDate in
                        calendar.isDate(completedDate, inSameDayAs: currentDate)
                    }) {
                        totalCompletions += 1
                    }
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        return totalPossible > 0 ? Double(totalCompletions) / Double(totalPossible) : 0.0
    }
    
    private var todoCompletionRate: Double {
        let todos = getTodosInRange()
        guard !todos.isEmpty else { return 0.0 }
        
        let completedCount = todos.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(todos.count)
    }
    
    private var totalFocusTime: Int {
        let sessions = getFocusSessionsInRange()
        return sessions.reduce(0) { total, session in
            total + Int(session.duration / 60) // 초를 분으로 변환
        }
    }
    
    private var focusTimeProgress: Double {
        let target = 300 // 5시간 목표
        return min(Double(totalFocusTime) / Double(target), 1.0)
    }
    
    private var completedHabitsCount: Int {
        let habits = getHabitsInRange()
        let (start, end) = getDateRange()
        
        return habits.reduce(0) { count, habit in
            let hasCompletedInRange = habit.completedDates.contains { completedDate in
                completedDate >= start && completedDate <= end
            }
            return count + (hasCompletedInRange ? 1 : 0)
        }
    }
    
    private var totalHabitsCount: Int {
        return getHabitsInRange().count
    }
    
    private var longestStreak: Int {
        let habits = getHabitsInRange()
        return habits.map { habit in
            let calendar = Calendar.current
            let today = Date()
            var streak = 0
            var currentDate = today
            
            while true {
                let startOfDay = calendar.startOfDay(for: currentDate)
                let isCompleted = habit.completedDates.contains { completedDate in
                    calendar.isDate(completedDate, inSameDayAs: startOfDay)
                }
                
                if isCompleted {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
                } else {
                    break
                }
            }
            
            return streak
        }.max() ?? 0
    }
    
    private var completedFocusSessionsCount: Int {
        return getFocusSessionsInRange().count
    }
    
    private var averageSessionDuration: Int {
        let sessions = getFocusSessionsInRange()
        guard !sessions.isEmpty else { return 0 }
        
        let totalDuration = sessions.reduce(0) { total, session in
            total + Int(session.duration / 60)
        }
        return totalDuration / sessions.count
    }
    
    private var dailyAverageFocusTime: Int {
        let sessions = getFocusSessionsInRange()
        guard !sessions.isEmpty else { return 0 }
        
        let (start, end) = getDateRange()
        let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 1
        
        let totalTime = sessions.reduce(0) { total, session in
            total + Int(session.duration / 60)
        }
        
        return totalTime / max(days, 1)
    }
    
    private var completedTodosCount: Int {
        return getTodosInRange().filter { $0.isCompleted }.count
    }
    
    private var totalTodosCount: Int {
        return getTodosInRange().count
    }
    
    private var incompleteTodosCount: Int {
        return getTodosInRange().filter { !$0.isCompleted }.count
    }
    
    // MARK: - Weekly Charts
    private var weeklyTodoChart: some View {
        VStack(spacing: 12) {
            Text(chartTitle(for: "할일 완료율"))
                .font(.caption)
                .foregroundColor(.secondaryText)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            Chart(getTodoData()) { data in
                BarMark(
                    x: .value("요일", data.weekday),
                    y: .value("완료율", Int(data.completionRate * 100))
                )
                .foregroundStyle(Color.mainPoint.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    if selectedPeriod == 1 {
                        // 월별일 때는 주요 일자만 표시
                        if let dayString = value.as(String.self),
                           let day = Int(dayString.replacingOccurrences(of: "일", with: "")),
                           shouldShowDayLabel(day: day) {
                            AxisValueLabel()
                        }
                    } else {
                        AxisValueLabel()
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var weeklyHabitChart: some View {
        VStack(spacing: 12) {
            Text(chartTitle(for: "습관 완료율"))
                .font(.caption)
                .foregroundColor(.secondaryText)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            Chart(getHabitData()) { data in
                BarMark(
                    x: .value("요일", data.weekday),
                    y: .value("완료율", Int(data.completionRate * 100))
                )
                .foregroundStyle(Color.successColor.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    if selectedPeriod == 1 {
                        // 월별일 때는 주요 일자만 표시
                        if let dayString = value.as(String.self),
                           let day = Int(dayString.replacingOccurrences(of: "일", with: "")),
                           shouldShowDayLabel(day: day) {
                            AxisValueLabel()
                        }
                    } else {
                        AxisValueLabel()
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private var weeklyFocusChart: some View {
        VStack(spacing: 12) {
            Text(chartTitle(for: "집중 세션"))
                .font(.caption)
                .foregroundColor(.secondaryText)
                .padding(.top, 16)
                .padding(.horizontal, 16)
            
            Chart(getFocusData()) { data in
                BarMark(
                    x: .value("요일", data.weekday),
                    y: .value("세션 수", data.sessionCount)
                )
                .foregroundStyle(Color.accentColor.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    if selectedPeriod == 1 {
                        // 월별일 때는 주요 일자만 표시
                        if let dayString = value.as(String.self),
                           let day = Int(dayString.replacingOccurrences(of: "일", with: "")),
                           shouldShowDayLabel(day: day) {
                            AxisValueLabel()
                        }
                    } else {
                        AxisValueLabel()
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    // MARK: - Helper Methods
    private func chartTitle(for type: String) -> String {
        switch selectedPeriod {
        case 0: return "요일별 \(type)"
        case 1: return "월별 \(type)"
        case 2: return "전체 \(type)"
        default: return "\(type)"
        }
    }
    
    private func shouldShowDayLabel(day: Int) -> Bool {
        let calendar = Calendar.current
        let selectedDate = calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        // 주요 일자들: 1, 5, 10, 15, 20, 25, 30, 마지막날
        let importantDays = [1, 5, 10, 15, 20, 25, 30, daysInMonth]
        return importantDays.contains(day)
    }
}



#Preview {
    StatisticsView()
        .environmentObject(DataManager())
} 
