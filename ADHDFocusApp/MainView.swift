import SwiftUI
import Foundation

struct MainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTodo = false
    @State private var selectedPeriod: CalendarPeriod = .daily
    @State private var selectedDate = Date()
    @State private var currentWeekOffset = 0
    @State private var currentMonthOffset = 0
    
    // 샘플 데이터
    @State private var sampleTasks: [Task] = [
        Task(title: "물마시기", subtitle: "", priority: .normal, streak: 3),
        Task(title: "운동하기", subtitle: "", priority: .normal, streak: 1),
        Task(title: "색상선택", subtitle: "", priority: .normal, streak: 3),
        Task(title: "매일 블로그", subtitle: "3개 쓰기", priority: .normal, streak: 3),
        Task(title: "카레 요리하기", subtitle: "맛있겠당", priority: .low, streak: 0)
    ]
    
    enum CalendarPeriod: String, CaseIterable {
        case daily = "일간"
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
                
                // Calendar View
                calendarView
                
                // Task List
                taskListView
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTaskView()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(weekFormatter.string(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                let progress = getTodayProgress()
                Text("오늘의 진행률 \(Int(progress * 100))%")
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
    
    // MARK: - Calendar View
    private var calendarView: some View {
        VStack(spacing: 0) {
            switch selectedPeriod {
            case .daily:
                dailyCalendarView
            case .monthly:
                monthlyCalendarView
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Daily Calendar View
    private var dailyCalendarView: some View {
        VStack(spacing: 16) {
            // Week Navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentWeekOffset -= 1
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                
                Spacer()
                
                Text(weekFormatter.string(from: getWeekDates().first ?? selectedDate) + " - " + weekFormatter.string(from: getWeekDates().last ?? selectedDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentWeekOffset += 1
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            }
            
            // Week Days
            HStack(spacing: 0) {
                ForEach(getWeekDates(), id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                    let hasEvents = !todosForDate(date).isEmpty
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = date
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(weekdayFormatter.string(from: date))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondaryText)
                            
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .mainPoint : .primaryText))
                            
                            if hasEvents {
                                HStack(spacing: 2) {
                                    Circle()
                                        .fill(Color.subColor2)
                                        .frame(width: 4, height: 4)
                                    Circle()
                                        .fill(Color.subColor3)
                                        .frame(width: 4, height: 4)
                                }
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 8, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.mainPoint : Color.clear)
                        )
                    }
                    .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                }
            }
        }
    }
    
    // MARK: - Monthly Calendar View
    private var monthlyCalendarView: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentMonthOffset -= 1
                        selectedDate = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                
                Spacer()
                
                Text(monthFormatter.string(from: selectedDate))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentMonthOffset += 1
                        selectedDate = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondaryText)
                        .frame(height: 30)
                }
                
                // Calendar days
                ForEach(getMonthDates(), id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    let isToday = Calendar.current.isDate(date, inSameDayAs: Date())
                    let hasEvents = !todosForDate(date).isEmpty
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedDate = date
                        }
                    }) {
                        VStack(spacing: 2) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .mainPoint : .primaryText))
                            
                            if hasEvents {
                                VStack(spacing: 1) {
                                    Text("일정있음..")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.subColor2)
                                    Text("다른 건없")
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.subColor3)
                                }
                            }
                        }
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background(
                            Circle()
                                .fill(isSelected ? Color.mainPoint : Color.clear)
                        )
                    }
                    .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                }
            }
        }
    }
    
    // MARK: - Task List View
    private var taskListView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("오늘 할 일")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                let completedCount = sampleTasks.filter { $0.isCompleted }.count
                Text("\(completedCount)/\(sampleTasks.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Task List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if sampleTasks.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(sampleTasks) { task in
                            ADHDTheme.TaskCard(task: task) {
                                toggleTask(task)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // FAB 공간 확보
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.successColor)
            
            Text("선택된 날짜에 할 일이 없습니다")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Text("새로운 할 일을 추가해보세요!")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Button(action: {
                showingAddTodo = true
            }) {
                Text("할 일 추가하기")
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
                    showingAddTodo = true
                }, icon: "plus")
                .padding(.trailing, 20)
                .padding(.bottom, 100) // 탭바 위 공간
            }
        }
    }
    
    // MARK: - Helper Methods
    private func getTodayProgress() -> Double {
        guard !sampleTasks.isEmpty else { return 0.0 }
        let completedCount = sampleTasks.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(sampleTasks.count)
    }
    
    private func toggleTask(_ task: Task) {
        if let index = sampleTasks.firstIndex(where: { $0.id == task.id }) {
            sampleTasks[index].isCompleted.toggle()
        }
    }
    
    private func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    private func getMonthDates() -> [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
        
        var dates: [Date] = []
        
        // Add previous month's days
        for i in (1..<firstWeekday).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: monthStart) {
                dates.append(date)
            }
        }
        
        // Add current month's days
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append(date)
            }
        }
        
        // Add next month's days to fill the grid
        let remainingDays = 42 - dates.count // 6 weeks * 7 days
        for day in 1...remainingDays {
            if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func todosForDate(_ date: Date) -> [Todo] {
        return dataManager.todos.filter { todo in
            Calendar.current.isDate(todo.createdDate, inSameDayAs: date)
        }
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var subtitle = ""
    @State private var priority: TaskPriority = .normal
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Title Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("제목")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    TextField("할 일을 입력하세요", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Subtitle Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("부제목")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    TextField("추가 설명 (선택사항)", text: $subtitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Priority Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("우선순위")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Picker("우선순위", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.displayText).tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Spacer()
                
                // Add Button
                Button(action: addTask) {
                    Text("할 일 추가")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mainPoint)
                        .cornerRadius(15)
                        .disabled(title.isEmpty)
                }
                .modernButton(backgroundColor: .mainPoint, foregroundColor: .white)
            }
            .padding()
            .navigationTitle("새 할 일")
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
    
    private func addTask() {
        let newTask = Task(
            title: title,
            subtitle: subtitle,
            priority: priority
        )
        // 여기서 실제 데이터 매니저에 추가
        dataManager.addTask(newTask)
        dismiss()
    }
}

#Preview {
    MainView()
        .environmentObject(DataManager())
}

// MARK: - DateFormatters
extension MainView {
    var weekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }
    
    var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.yyyy"
        return formatter
    }
    
    var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter
    }
} 
