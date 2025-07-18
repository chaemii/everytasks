import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod = 0 // 0: 이번 주, 1: 이번 달, 2: 전체
    @State private var selectedTab = 0 // 0: 습관, 1: 집중 시간
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Period Selector
                periodSelector
                
                // Statistics Content
                statisticsContent
                
                Spacer()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("통계")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("나의 성장을 확인해보세요")
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
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPeriod == index ? Color.mainPoint : Color.clear)
                        )
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: selectedPeriod == index ? .white : .secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Statistics Content
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Progress
                overallProgressView
                
                // Todo Statistics
                todoStatisticsView
                
                // Habit Statistics
                habitStatisticsView
                
                // Focus Time Statistics
                focusTimeStatisticsView
            }
            .padding()
        }
    }
    
    // MARK: - Overall Progress View
    private var overallProgressView: some View {
        VStack(spacing: 16) {
            Text("전체 진행률")
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
                    
                    Text("할 일")
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
                    
                    Text("습관")
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
                            Text("\(totalFocusTime)분")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("집중 시간")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .padding()
            .cardStyle()
        }
    }
    
    // MARK: - Habit Statistics View
    private var habitStatisticsView: some View {
        VStack(spacing: 16) {
            Text("습관 통계")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 12) {
                StatisticRow(
                    title: "완료된 습관",
                    value: "\(completedHabitsCount)개",
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "총 습관",
                    value: "\(totalHabitsCount)개",
                    icon: "circle.grid.hex.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "가장 긴 연속 기록",
                    value: "\(longestStreak)일",
                    icon: "flame.fill",
                    color: Color.warningColor
                )
                
                StatisticRow(
                    title: "완료율",
                    value: "\(Int(habitCompletionRate * 100))%",
                    icon: "chart.pie.fill",
                    color: Color.accentColor
                )
            }
            .padding()
            .cardStyle()
            
            // 요일별 습관 차트 (이번주 선택시에만 표시)
            if selectedPeriod == 0 {
                weeklyHabitChart
            }
        }
    }
    
    // MARK: - Focus Time Statistics View
    private var focusTimeStatisticsView: some View {
        VStack(spacing: 16) {
            Text("집중 시간 통계")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 12) {
                StatisticRow(
                    title: "총 집중 시간",
                    value: "\(totalFocusTime)분",
                    icon: "timer.circle.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "완료된 세션",
                    value: "\(completedFocusSessionsCount)개",
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "평균 세션 길이",
                    value: "\(averageSessionDuration)분",
                    icon: "clock.fill",
                    color: Color.accentColor
                )
                
                StatisticRow(
                    title: "일일 평균",
                    value: "\(dailyAverageFocusTime)분",
                    icon: "calendar.circle.fill",
                    color: Color.warningColor
                )
            }
            .padding()
            .cardStyle()
            
            // 요일별 집중 시간 차트 (이번주 선택시에만 표시)
            if selectedPeriod == 0 {
                weeklyFocusChart
            }
        }
    }
    
    // MARK: - Todo Statistics View
    private var todoStatisticsView: some View {
        VStack(spacing: 16) {
            Text("할 일 통계")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 12) {
                StatisticRow(
                    title: "완료된 할 일",
                    value: "\(completedTodosCount)개",
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "총 할 일",
                    value: "\(totalTodosCount)개",
                    icon: "list.bullet.circle.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "완료율",
                    value: "\(Int(todoCompletionRate * 100))%",
                    icon: "chart.pie.fill",
                    color: Color.accentColor
                )
                
                StatisticRow(
                    title: "미완료 할 일",
                    value: "\(incompleteTodosCount)개",
                    icon: "exclamationmark.circle.fill",
                    color: Color.warningColor
                )
            }
            .padding()
            .cardStyle()
            
            // 요일별 할일 차트 (이번주 선택시에만 표시)
            if selectedPeriod == 0 {
                weeklyTodoChart
            }
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
        case 0: return "이번 주"
        case 1: return "이번 달"
        case 2: return "전체"
        default: return ""
        }
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
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? Date()
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
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? Date()
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
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        return weekdays.enumerated().map { index, weekday in
            let date = calendar.date(byAdding: .day, value: index, to: weekStart) ?? Date()
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
            Text("요일별 할일 완료율")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Chart(getWeeklyTodoData()) { data in
                BarMark(
                    x: .value("요일", data.weekday),
                    y: .value("완료율", data.completionRate * 100)
                )
                .foregroundStyle(Color.mainPoint.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .number.scale(100).suffix("%"))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var weeklyHabitChart: some View {
        VStack(spacing: 12) {
            Text("요일별 습관 완료율")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Chart(getWeeklyHabitData()) { data in
                BarMark(
                    x: .value("요일", data.weekday),
                    y: .value("완료율", data.completionRate * 100)
                )
                .foregroundStyle(Color.successColor.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .number.scale(100).suffix("%"))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private var weeklyFocusChart: some View {
        VStack(spacing: 12) {
            Text("요일별 집중 세션")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Chart(getWeeklyFocusData()) { data in
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
                AxisMarks { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Statistic Row
struct StatisticRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondaryText)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(DataManager())
} 
