import SwiftUI

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
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPeriod == index ? Color.mainPoint : Color.clear)
                        )
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: selectedPeriod == index ? .white : .secondaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Statistics Content
    private var statisticsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Progress
                overallProgressView
                
                // Habit Statistics
                habitStatisticsView
                
                // Focus Time Statistics
                focusTimeStatisticsView
                
                // Todo Statistics
                todoStatisticsView
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
                // Habit Progress
                VStack(spacing: 8) {
                    ADHDTheme.ProgressRing(
                        progress: 0.0, // habitCompletionRate
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(0.0 * 100))%")
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
                        progress: 0.0, // focusTimeProgress
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(0)분")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("집중 시간")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                // Todo Progress
                VStack(spacing: 8) {
                    ADHDTheme.ProgressRing(
                        progress: 0.0, // todoCompletionRate
                        size: 80,
                        thickness: 8
                    )
                    .overlay(
                        VStack(spacing: 2) {
                            Text("\(Int(0.0 * 100))%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primaryText)
                        }
                    )
                    
                    Text("할 일")
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
                    value: "\(0)개", // completedHabitsCount
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "총 습관",
                    value: "\(0)개", // totalHabitsCount
                    icon: "circle.grid.hex.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "가장 긴 연속 기록",
                    value: "\(0)일", // longestStreak
                    icon: "flame.fill",
                    color: Color.warningColor
                )
                
                StatisticRow(
                    title: "완료율",
                    value: "\(Int(0.0 * 100))%", // habitCompletionRate
                    icon: "chart.pie.fill",
                    color: Color.accentColor
                )
            }
            .padding()
            .cardStyle()
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
                    value: "\(0)분", // totalFocusTime
                    icon: "timer.circle.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "완료된 세션",
                    value: "\(0)개", // completedFocusSessionsCount
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "평균 세션 길이",
                    value: "\(0)분", // averageSessionDuration
                    icon: "clock.fill",
                    color: Color.accentColor
                )
                
                StatisticRow(
                    title: "일일 평균",
                    value: "\(0)분", // dailyAverageFocusTime
                    icon: "calendar.circle.fill",
                    color: Color.warningColor
                )
            }
            .padding()
            .cardStyle()
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
                    value: "\(0)개", // completedTodosCount
                    icon: "checkmark.circle.fill",
                    color: Color.successColor
                )
                
                StatisticRow(
                    title: "총 할 일",
                    value: "\(0)개", // totalTodosCount
                    icon: "list.bullet.circle.fill",
                    color: Color.mainPoint
                )
                
                StatisticRow(
                    title: "완료율",
                    value: "\(Int(0.0 * 100))%", // todoCompletionRate
                    icon: "chart.pie.fill",
                    color: Color.accentColor
                )
                
                StatisticRow(
                    title: "미완료 할 일",
                    value: "\(0)개", // incompleteTodosCount
                    icon: "exclamationmark.circle.fill",
                    color: Color.warningColor
                )
            }
            .padding()
            .cardStyle()
        }
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
    
    // MARK: - Computed Properties
    private var habitCompletionRate: Double {
        return 0.0 // dataManager.getHabitCompletionRate(for: .week) // Temporarily using .week
    }
    
    private var todoCompletionRate: Double {
        return 0.0 // dataManager.getTodoCompletionRate(for: .week) // Temporarily using .week
    }
    
    private var totalFocusTime: Int {
        return 0 // dataManager.getTotalFocusTime(for: .week) // Temporarily using .week
    }
    
    private var focusTimeProgress: Double {
        let target = 300 // 5시간 목표
        return min(Double(totalFocusTime) / Double(target), 1.0)
    }
    
    private var completedHabitsCount: Int {
        return 0 // dataManager.habits.reduce(0) { count, habit in
        //     count + (habit.isCompletedFor(Date()) ? 1 : 0)
        // }
    }
    
    private var totalHabitsCount: Int {
        return 0 // dataManager.habits.count
    }
    
    private var longestStreak: Int {
        return 0 // dataManager.habits.map { $0.streak }.max() ?? 0
    }
    
    private var completedFocusSessionsCount: Int {
        return 0 // dataManager.focusSessions.filter { $0.isCompleted }.count
    }
    
    private var averageSessionDuration: Int {
        return 0
    }
    
    private var dailyAverageFocusTime: Int {
        let days = 7 // 일주일 기준
        return totalFocusTime / days
    }
    
    private var completedTodosCount: Int {
        return 0 // dataManager.todos.filter { $0.isCompleted }.count
    }
    
    private var totalTodosCount: Int {
        return 0 // dataManager.todos.count
    }
    
    private var incompleteTodosCount: Int {
        return 0 // dataManager.todos.filter { !$0.isCompleted }.count
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
