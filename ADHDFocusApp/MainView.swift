import SwiftUI
import Foundation
import Lottie

struct MainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTodo = false
    @State private var editingTodo: Todo?
    @State private var selectedPeriod: CalendarPeriod = .daily
    @State private var selectedDate = Date()
    @State private var currentWeekOffset = 0
    @State private var currentMonthOffset = 0
    @State private var showingCelebration = false
    @State private var lastProgress = 0.0
    @State private var showingActionsForTodo: UUID? = nil
    

    
    enum CalendarPeriod: String, CaseIterable {
        case daily = "daily"
        case monthly = "monthly"
        
        var localizedString: String {
            switch self {
            case .daily:
                return "daily".localized
            case .monthly:
                return "monthly".localized
            }
        }
    }
    
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
            
            // Content View (Calendar + Task List)
            ScrollView {
                VStack(spacing: 0) {
                    calendarView
                    taskListView
                }
                .padding(.bottom, 120)
            }
            
            Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddTodo = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.mainPoint)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTaskView(selectedDate: selectedDate)
        }
        .sheet(item: $editingTodo) { todo in
            EditTaskView(todo: todo)
        }
        .overlay(
            CelebrationView(isShowing: $showingCelebration)
        )
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
                Text("message_today_progress".localized(with: "\(Int(progress * 100))"))
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color.clear)
                        }
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
                    Text(period.localizedString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedPeriod == period ? .white : .secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedPeriod == period ? Color.mainPoint : Color.clear)
                            }
                        )
                }
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .padding(.top, 2)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#FFFDFA"))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
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
        .padding(.top, 20) // 다시 20으로 복원
        .padding(.bottom, 16) // 하단 패딩을 16으로 늘림
    }
    
    // MARK: - Daily Calendar View
    private var dailyCalendarView: some View {
        VStack(spacing: 16) {
            // Week Navigation
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentWeekOffset -= 1
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .background(.clear)
                
                Spacer()
                
                Text(weekFormatter.string(from: getWeekDates().first ?? selectedDate) + " - " + weekFormatter.string(from: getWeekDates().last ?? selectedDate))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentWeekOffset += 1
                        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: currentWeekOffset, to: Date()) ?? Date()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
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
                            Text(getShortWeekday(Calendar.current.component(.weekday, from: date) - 1))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondaryText)
                            
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .mainPoint : .primaryText))
                            
                            if hasEvents {
                                Circle()
                                    .fill(Color.subColor3)
                                    .frame(width: 4, height: 4)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.mainPoint.opacity(0.4) : Color.clear)
                            }
                        )
                    }
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
                        selectedDate = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
                .background(.clear)
                
                Spacer()
                
                Text(monthFormatter.string(from: selectedDate))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentMonthOffset += 1
                        selectedDate = Calendar.current.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primaryText)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Weekday headers
                ForEach(0..<7, id: \.self) { index in
                                        Text(getShortWeekday(index))
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
                        VStack(spacing: 0) {
                            // Date text at top (fixed position)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .mainPoint : .primaryText))
                                .frame(maxWidth: .infinity, alignment: .top)
                                .frame(height: 20) // 고정 높이
                            
                            // Todo items (max 2 + count) - 상단에 붙임
                            if hasEvents {
                                let todos = todosForDate(date)
                                VStack(spacing: 2) {
                                    // Show first 2 todos
                                    ForEach(todos.prefix(2), id: \.id) { todo in
                                        Text(String(todo.title.prefix(4)) + (todo.title.count > 4 ? "..." : ""))
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.charcoal)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(getPriorityColor(todo.priority))
                                            )
                                    }
                                    
                                    // Show +N if there are more than 2 todos
                                    if todos.count > 2 {
                                        Text("+\(todos.count - 2)")
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundColor(.charcoal)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .top)
                            }
                            
                            Spacer() // 하단에 Spacer 추가하여 상단 정렬
                        }
                        .frame(height: 80) // 높이 증가 (50 → 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.mainPoint.opacity(0.4) : Color.clear)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Task List View
    private var taskListView: some View {
        VStack(spacing: 16) { // 8에서 16으로 다시 늘림
            // Header
            HStack {
                Text("\(weekFormatter.string(from: selectedDate)) \("todos".localized)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                let selectedDateTodos = todosForDate(selectedDate)
                let selectedDateHabits = habitsForDate(selectedDate)
                let totalItems = selectedDateTodos.count + selectedDateHabits.count
                let completedCount = selectedDateTodos.filter { $0.isCompleted }.count + selectedDateHabits.filter { isHabitCompletedForDate($0, date: selectedDate) }.count
                Text("\(completedCount)/\(totalItems)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondaryText)
            }
            .padding(.horizontal, 20)
            .padding(.top, 0) // 0으로 설정하여 최대한 위로 올림
            
            // Task List
            LazyVStack(spacing: 12) {
                let selectedDateTodos = todosForDate(selectedDate)
                let selectedDateHabits = habitsForDate(selectedDate)
                
                if selectedDateTodos.isEmpty && selectedDateHabits.isEmpty {
                    emptyStateView
                } else {
                    // Habits first (if any)
                    ForEach(selectedDateHabits) { habit in
                        HabitTaskCard(habit: habit, date: selectedDate) {
                            toggleHabitCompletion(habit, date: selectedDate)
                        }
                    }
                    
                    // Then todos
                    ForEach(selectedDateTodos) { todo in
                        TodoTaskCard(
                            todo: todo,
                            onToggle: {
                                toggleTodoCompletion(todo)
                            },
                            onEdit: {
                                editingTodo = todo
                            },
                            onDelete: {
                                dataManager.deleteTodo(todo)
                            },
                            isShowingActions: $showingActionsForTodo
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.successColor)
            
            Text("empty_todos_title".localized)
                .font(.system(size: 16))
                .foregroundColor(.secondaryText)
            
            Text("empty_todos_subtitle".localized)
                .font(.system(size: 14))
                .foregroundColor(.secondaryText.opacity(0.7))
        }
        .padding(40)
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
        let selectedDateTodos = todosForDate(selectedDate)
        let selectedDateHabits = habitsForDate(selectedDate)
        let totalItems = selectedDateTodos.count + selectedDateHabits.count
        
        guard totalItems > 0 else { return 0.0 }
        
        let completedCount = selectedDateTodos.filter { $0.isCompleted }.count + selectedDateHabits.filter { isHabitCompletedForDate($0, date: selectedDate) }.count
        return Double(completedCount) / Double(totalItems)
    }
    
    private func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? Date()
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    private func getMonthDates() -> [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let monthInterval = calendar.dateInterval(of: .month, for: today)
        
        guard let monthStart = monthInterval?.start else {
            return []
        }
        
        let daysInMonthRange = calendar.range(of: .day, in: .month, for: today)
        let daysInMonth = daysInMonthRange?.count ?? 30
        
        var dates: [Date] = []
        
        // Add current month's days only (1~31일)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func todosForDate(_ date: Date) -> [Todo] {
        return dataManager.todos.filter { todo in
            Calendar.current.isDate(todo.targetDate, inSameDayAs: date)
        }
    }
    
    private func habitsForDate(_ date: Date) -> [Habit] {
        return dataManager.habits.filter { habit in
            habit.isActive && dataManager.isHabitApplicableForDate(habit, date: date)
        }
    }
    
    private func isHabitCompletedForDate(_ habit: Habit, date: Date) -> Bool {
        return habit.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    private func toggleHabitCompletion(_ habit: Habit, date: Date) {
        dataManager.completeHabit(habit, for: date)
        checkProgressForCelebration()
    }
    
    private func toggleTodoCompletion(_ todo: Todo) {
        dataManager.toggleTodoCompletion(todo)
        checkProgressForCelebration()
    }
    
    private func checkProgressForCelebration() {
        let currentProgress = getTodayProgress()
        if currentProgress >= 1.0 && lastProgress < 1.0 {
            showingCelebration = true
        }
        lastProgress = currentProgress
    }
    
    private func getPriorityColor(_ priority: TodoPriority) -> Color {
        switch priority {
        case .urgent:
            return Color(hex: "F68566") // 긴급 - #F68566로 변경
        case .high:
            return Color(hex: "F68566") // 높음 - 빨간색
        case .medium:
            return Color(hex: "FBEACC") // 보통 - 노란색
        case .low:
            return Color(hex: "A4D0B4") // 낮음 - 초록색
        }
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    @Binding var isShowing: Bool
    @State private var animationOffset: CGFloat = 1000
    @State private var confettiOffset: CGFloat = -100
    
    var body: some View {
        if isShowing {
            ZStack {
                // 배경 오버레이
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideCelebration()
                    }
                
                // 메인 셀러브레이션 카드
                VStack(spacing: 16) {
                    // 체크마크 아이콘
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.successColor)
                        .scaleEffect(animationOffset == 0 ? 1.2 : 0.8)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animationOffset)
                    
                    // 축하 메시지
                    VStack(spacing: 6) {
                        Text("축하합니다! 🎉")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(hex: "FFFDFA"))
                        
                        Text("오늘의 모든 할 일을 완료했습니다!")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FFFDFA"))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(30)
                .offset(y: animationOffset)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animationOffset = 0
                    }
                    
                    // 3초 후 자동 종료
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        hideCelebration()
                    }
                }
                
                // X 버튼 (하단에 별도 배치)
                VStack {
                    Spacer()
                    Button(action: hideCelebration) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "FFFDFA").opacity(0.7))
                    }
                    .padding(.bottom, 50)
                }
                .padding(30)
                .offset(y: animationOffset)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        animationOffset = 0
                    }
                    
                    // 3초 후 자동 종료
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        hideCelebration()
                    }
                }
                
                // 컨페티 애니메이션 항상 중앙에 고정
                AnimationView()
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    private func hideCelebration() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            animationOffset = 1000
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isShowing = false
        }
    }
}

struct AnimationView: View {
    var body: some View {
        LottieJSONView()
            .frame(width: 400, height: 400)
    }
}

struct LottieJSONView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        // JSON 파일에서 애니메이션 로드
        if let path = Bundle.main.path(forResource: "confetti", ofType: "json"),
           let animation = LottieAnimation.filepath(path) {
            animationView.animation = animation
            animationView.loopMode = .playOnce
            animationView.play()
        }
        
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 업데이트가 필요하지 않음
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TodoPriority = .medium
    @State private var targetDate: Date
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        self._targetDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Title Input
                        HStack(spacing: 12) {
                            Text("form_title".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("form_title_placeholder".localized, text: $title)
                                .font(.system(size: 14))
                                .padding()
                                .background(Color(hex: "#FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Description Input
                        HStack(alignment: .top, spacing: 12) {
                            Text("form_description".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("form_description_placeholder".localized, text: $description, axis: .vertical)
                                .font(.system(size: 14))
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(hex: "#FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Priority Selection
                        HStack(spacing: 12) {
                            Text("form_priority".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(TodoPriority.allCases, id: \.self) { priorityOption in
                                    Button(action: {
                                        priority = priorityOption
                                    }) {
                                        Text(priorityOption.displayName)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(priority == priorityOption ? .white : priorityOption.color)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(priority == priorityOption ? priorityOption.color : Color.cardBackground)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(priorityOption.color, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Date Selection
                        HStack(spacing: 12) {
                            Text("form_target_date".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                
                // Add Button
                Button(action: addTask) {
                    Text("add_todo_button".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.isEmpty ? Color(hex: "D9D9D9") : Color.mainPoint)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(hex: "#F7F5F2"))
            .navigationTitle("add_new_todo".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        let todo = Todo(
            title: title,
            description: description,
            priority: priority,
            category: .personal, // 기본 카테고리로 설정
            targetDate: targetDate
        )
        dataManager.addTodo(todo)
        dismiss()
    }
}

// MARK: - Edit Task View
struct EditTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let todo: Todo
    
    @State private var title: String
    @State private var description: String
    @State private var priority: TodoPriority
    @State private var targetDate: Date
    
    init(todo: Todo) {
        self.todo = todo
        self._title = State(initialValue: todo.title)
        self._description = State(initialValue: todo.description)
        self._priority = State(initialValue: todo.priority)
        self._targetDate = State(initialValue: todo.targetDate)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Title Input
                        HStack(spacing: 12) {
                            Text("edit_form_title".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("edit_form_title_placeholder".localized, text: $title)
                                .font(.system(size: 14))
                                .padding()
                                .background(Color(hex: "#FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Description Input
                        HStack(alignment: .top, spacing: 12) {
                            Text("edit_form_description".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("edit_form_description_placeholder".localized, text: $description, axis: .vertical)
                                .font(.system(size: 14))
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(hex: "#FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Priority Selection
                        HStack(spacing: 12) {
                            Text("edit_form_priority".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(TodoPriority.allCases, id: \.self) { priorityOption in
                                    Button(action: {
                                        priority = priorityOption
                                    }) {
                                        Text(priorityOption.displayName)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(priority == priorityOption ? .white : priorityOption.color)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(priority == priorityOption ? priorityOption.color : Color.cardBackground)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(priorityOption.color, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Date Selection
                        HStack(spacing: 12) {
                            Text("edit_form_date".localized)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                
                // Update Button
                Button(action: updateTask) {
                    Text("edit_todo_button".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(title.isEmpty ? Color(hex: "D9D9D9") : Color.mainPoint)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(hex: "#F7F5F2"))
            .navigationTitle("edit_todo".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save".localized) {
                        updateTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func updateTask() {
        var updatedTodo = todo
        updatedTodo.title = title
        updatedTodo.description = description
        updatedTodo.priority = priority
        updatedTodo.targetDate = targetDate
        
        dataManager.updateTodo(updatedTodo)
        dismiss()
    }
}

#Preview {
    MainView()
        .environmentObject(DataManager())
}

// MARK: - Habit Task Card
struct HabitTaskCard: View {
    let habit: Habit
    let date: Date
    let onToggle: () -> Void
    
    private var habitColor: Color {
        return Color(hex: habit.color)
    }
    
    private var backgroundColor: Color {
        let trimmedColor = habit.color.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmedColor {
        case "C1E2FF":
            return Color(hex: "#E7EEF4")
        case "A4D0B4":
            return Color(hex: "#E5EEE8")
        case "F68566", "F3876B":
            return Color(hex: "#F9EAE6") // 다홍색 계열에 대한 배경색
        case "FBEACC":
            return Color(hex: "#F7EFE2")
        default:
            // 다홍색 계열 색상들을 더 포괄적으로 처리
            if trimmedColor.hasPrefix("F6") || trimmedColor.hasPrefix("F3") {
                return Color(hex: "#F9EAE6")
            }
            return Color.cardBackground
        }
    }
    
    private var textColor: Color {
        return .primaryText
    }
    
    private var checkColor: Color {
        let trimmedColor = habit.color.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedColor == "FBEACC" {
            return Color(hex: "#F7D394")
        }
        return isCompleted ? habitColor : .secondaryText
    }
    
    private func getStreakColor() -> Color {
        let trimmedColor = habit.color.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmedColor {
        case "C1E2FF":
            return Color(hex: "#99CFFF") // #E7EEF4 배경색일 때 연속일수 색상
        case "FBEACC":
            return Color(hex: "#FFC662") // #F7EFE2 배경색일 때 연속일수 색상
        default:
            return habitColor
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(checkColor)
                    .scaleEffect(isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCompleted)
            }
            .background(.clear)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(getStreakColor())
                        
                        Text("\(habitStreak)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(getStreakColor())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(habitColor.opacity(0.1))
                    )
                }
                
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var isCompleted: Bool {
        return habit.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    private var habitStreak: Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        // 오늘부터 과거로 거슬러 올라가면서 연속일수 계산
        while true {
            let startOfDay = calendar.startOfDay(for: currentDate)
            let isCompleted = habit.completedDates.contains { completedDate in
                calendar.isDate(completedDate, inSameDayAs: startOfDay)
            }
            
            if isCompleted {
                streak += 1
                // 하루 전으로 이동
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? Date()
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Todo Task Card
struct TodoTaskCard: View {
    let todo: Todo
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    @Binding var isShowingActions: UUID?
    
    private var showingActions: Bool {
        return isShowingActions == todo.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.isCompleted ? .successColor : .secondaryText)
                    .scaleEffect(todo.isCompleted ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: todo.isCompleted)
            }
            .background(.clear)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Text(todo.priority.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(todo.priority.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(todo.priority.color.opacity(0.1))
                        )
                }
                
                if !todo.description.isEmpty {
                    Text(todo.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Three dots menu button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if showingActions {
                        isShowingActions = nil
                    } else {
                        isShowingActions = todo.id
                    }
                }
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .rotationEffect(.degrees(90))
            }
            .background(.clear)
        }
        .padding()
        .background(Color(hex: "#FFFDFA"))
        .cornerRadius(16)
        .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        .offset(x: showingActions ? -120 : 0)
        .overlay(
            HStack {
                Spacer()
                
                if showingActions {
                    HStack(spacing: 8) {
                        Button(action: {
                            isShowingActions = nil
                            onEdit()
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "B3D3BD"))
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            isShowingActions = nil
                            onDelete()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "282828"))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.trailing, 16)
                    .transition(.move(edge: .trailing))
                }
            }
        )
        .onTapGesture {
            if showingActions {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingActions = nil
                }
            }
        }
    }
}

// MARK: - DateFormatters
extension MainView {
    var weekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = Locale.current.identifier.hasPrefix("ko") ? "M월 d일" : "M/d"
        return formatter
    }
    
    var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = Locale.current.identifier.hasPrefix("ko") ? "yyyy년 M월" : "MMM yyyy"
        return formatter
    }
    
    var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter
    }
    
    func getShortWeekday(_ weekday: Int) -> String {
        let weekdays = [
            "weekday_sun_short".localized,
            "weekday_mon_short".localized,
            "weekday_tue_short".localized,
            "weekday_wed_short".localized,
            "weekday_thu_short".localized,
            "weekday_fri_short".localized,
            "weekday_sat_short".localized
        ]
        return weekdays[weekday]
    }
} 
