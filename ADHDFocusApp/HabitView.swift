import SwiftUI

struct HabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: CalendarPeriod = .weekly
    @State private var showingAddHabit = false
    
    enum CalendarPeriod: String, CaseIterable {
        case weekly = "주간"
        case monthly = "월간"
    }
    
    var body: some View {
        ZStack {
            // 배경색
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Period Selector
                periodSelector
                
                // Progress Header
                progressHeader
                
                // Habit List
                habitListView
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("습관 관리")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let progress = getWeeklyProgress()
                Text("이번주 진행률 \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.cardBackground)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Period Selector
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(CalendarPeriod.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedPeriod = period
                    }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedPeriod == period ? .white : .secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPeriod == period ? Color.mainPoint : Color.clear)
                        )
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: selectedPeriod == period ? .white : .secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Progress Header
    private var progressHeader: some View {
        VStack(spacing: 12) {
            let progress = getWeeklyProgress()
            let completedCount = dataManager.habits.filter { habit in
                let weekDates = getWeekDates()
                return weekDates.contains { date in
                    habit.completedDates.contains { completedDate in
                        Calendar.current.isDate(completedDate, inSameDayAs: date)
                    }
                }
            }.count
            
            Text("이번주 \(Int(progress * 100))% 완료! 조금만 더 힘내세요! 내일이 더 나아질 거예요! 💪")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text("주간 습관 \(completedCount)/\(dataManager.habits.count)")
                .font(.headline)
                .foregroundColor(.primaryText)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Habit List View
    private var habitListView: some View {
        VStack(spacing: 16) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    if dataManager.habits.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(dataManager.habits) { habit in
                            HabitCardView(habit: habit, weekDates: getWeekDates())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // FAB 공간 확보
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 60))
                .foregroundColor(.successColor)
            
            Text("아직 등록된 습관이 없습니다")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Text("새로운 습관을 추가해보세요!")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Button(action: {
                showingAddHabit = true
            }) {
                Text("습관 추가하기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.mainPoint)
                    .cornerRadius(15)
            }
            .modernButton(backgroundColor: Color.mainPoint, foregroundColor: .white)
        }
        .padding(40)
        .cardStyle()
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ADHDTheme.FloatingActionButton(action: {
                    showingAddHabit = true
                }, icon: "plus")
                .padding(.trailing, 20)
                .padding(.bottom, 100) // 탭바 위 공간
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getWeeklyProgress() -> Double {
        let weekDates = getWeekDates()
        var totalCompletions = 0
        var totalPossible = 0
        
        for habit in dataManager.habits {
            for date in weekDates {
                totalPossible += 1
                if habit.completedDates.contains(where: { completedDate in
                    Calendar.current.isDate(completedDate, inSameDayAs: date)
                }) {
                    totalCompletions += 1
                }
            }
        }
        
        return totalPossible > 0 ? Double(totalCompletions) / Double(totalPossible) : 0.0
    }
    
    private func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
}

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: Habit
    let weekDates: [Date]
    
    private let days = ["일", "월", "화", "수", "목", "금", "토"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and streak
            HStack {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("\(getStreakCount())일 연속")
                    .font(.subheadline)
                    .foregroundColor(.mainPoint)
                    .fontWeight(.medium)
            }
            
            // Week days
            HStack(spacing: 12) {
                ForEach(0..<7) { index in
                    HabitDayCircleView(
                        day: days[index],
                        date: weekDates[index],
                        isCompleted: isCompletedForDate(weekDates[index]),
                        color: .mainPoint
                    )
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func isCompletedForDate(_ date: Date) -> Bool {
        return habit.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    private func getStreakCount() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        while true {
            if habit.completedDates.contains(where: { completedDate in
                calendar.isDate(completedDate, inSameDayAs: currentDate)
            }) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Habit Day Circle View
struct HabitDayCircleView: View {
    let day: String
    let date: Date
    let isCompleted: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.caption)
                .foregroundColor(.secondaryText)
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.footnote)
                .foregroundColor(.primaryText)
            
            Circle()
                .fill(isCompleted ? color : Color.gray.opacity(0.1))
                .frame(width: 20, height: 20)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                }
        }
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var category: HabitCategory = .health
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("습관 이름")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    TextField("습관을 입력하세요", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Description Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("설명")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    TextField("추가 설명 (선택사항)", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("카테고리")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Picker("카테고리", selection: $category) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.displayText).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
                
                // Add Button
                Button(action: addHabit) {
                    Text("습관 추가")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainPoint)
                        .cornerRadius(15)
                        .disabled(title.isEmpty)
                }
                .modernButton(backgroundColor: Color.mainPoint, foregroundColor: .white)
            }
            .padding()
            .navigationTitle("새 습관")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addHabit() {
        let newHabit = Habit(
            title: title,
            description: description,
            category: category
        )
        dataManager.addHabit(newHabit)
        dismiss()
    }
}

#Preview {
    HabitView()
        .environmentObject(DataManager())
}
