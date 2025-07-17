import SwiftUI
import Foundation

struct MainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTodo = false
    @State private var showingEditTodo = false
    @State private var editingTodo: Todo?
    @State private var selectedPeriod: CalendarPeriod = .daily
    @State private var selectedDate = Date()
    @State private var currentWeekOffset = 0
    @State private var currentMonthOffset = 0
    

    
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
                
                // Content View (Calendar + Task List)
                if selectedPeriod == .monthly {
                    ScrollView {
                        VStack(spacing: 0) {
                            calendarView
                            taskListView
                        }
                    }
                } else {
                    calendarView
                    taskListView
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingAddTodo) {
            AddTaskView()
        }
        .sheet(isPresented: $showingEditTodo) {
            if let todo = editingTodo {
                EditTaskView(todo: todo)
            }
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
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedPeriod == period ? Color.mainPoint : Color.clear)
                        )
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: selectedPeriod == period ? .white : .secondaryText)
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
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.mainPoint.opacity(0.4) : Color.clear)
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
                        VStack(spacing: 4) {
                            // Date text at top
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 14, weight: isToday ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : (isToday ? .mainPoint : .primaryText))
                                .frame(maxWidth: .infinity, alignment: .top)
                            
                            Spacer()
                            
                            // Todo items (up to 4 characters)
                            if hasEvents {
                                let todos = todosForDate(date)
                                let displayText = todos.prefix(2).map { String($0.title.prefix(2)) }.joined()
                                if !displayText.isEmpty {
                                    Text(displayText)
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundColor(.secondaryText)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .bottom)
                                }
                            }
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.mainPoint.opacity(0.4) : Color.clear)
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
                Text("\(weekFormatter.string(from: selectedDate)) 할 일")
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
            .padding(.top, 20)
            
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
                                showingEditTodo = true
                            },
                            onDelete: {
                                dataManager.deleteTodo(todo)
                            }
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
            Calendar.current.isDate(todo.targetDate, inSameDayAs: date)
        }
    }
    
    private func habitsForDate(_ date: Date) -> [Habit] {
        return dataManager.habits.filter { habit in
            habit.isActive
        }
    }
    
    private func isHabitCompletedForDate(_ habit: Habit, date: Date) -> Bool {
        return habit.completedDates.contains { completedDate in
            Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
    
    private func toggleHabitCompletion(_ habit: Habit, date: Date) {
        dataManager.completeHabit(habit, for: date)
    }
    
    private func toggleTodoCompletion(_ todo: Todo) {
        dataManager.toggleTodoCompletion(todo)
    }
}

// MARK: - Add Task View
struct AddTaskView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TodoPriority = .medium
    @State private var targetDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Title Input
                        HStack(spacing: 12) {
                            Text("제목")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("할 일을 입력하세요", text: $title)
                                .font(.system(size: 14))
                                .padding()
                                .background(Color(hex: "FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Description Input
                        HStack(alignment: .top, spacing: 12) {
                            Text("설명")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("추가 설명 (선택사항)", text: $description, axis: .vertical)
                                .font(.system(size: 14))
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(hex: "FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Priority Selection
                        HStack(spacing: 12) {
                            Text("우선순위")
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
                                                    .fill(priority == priorityOption ? priorityOption.color : Color.clear)
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
                            Text("날짜")
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
                    Text("새 할 일 추가")
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
            .background(Color(hex: "F7F5F2"))
            .navigationTitle("새 할 일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
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
                            Text("제목")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("할 일을 입력하세요", text: $title)
                                .font(.system(size: 14))
                                .padding()
                                .background(Color(hex: "FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Description Input
                        HStack(alignment: .top, spacing: 12) {
                            Text("설명")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            TextField("추가 설명 (선택사항)", text: $description, axis: .vertical)
                                .font(.system(size: 14))
                                .lineLimit(3...6)
                                .padding()
                                .background(Color(hex: "FFFDFA"))
                                .cornerRadius(8)
                        }
                        
                        // Priority Selection
                        HStack(spacing: 12) {
                            Text("우선순위")
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
                                                    .fill(priority == priorityOption ? priorityOption.color : Color.clear)
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
                            Text("날짜")
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
                    Text("할 일 수정")
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
            .background(Color(hex: "F7F5F2"))
            .navigationTitle("할 일 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
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
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .successColor : .secondaryText)
            }
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.mainPoint)
                        
                        Text("\(habitStreak)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.mainPoint)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.mainPoint.opacity(0.1))
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
        .background(Color.cardBackground)
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
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
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
    @State private var showingActions = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(todo.isCompleted ? .successColor : .secondaryText)
            }
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            
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
                    showingActions.toggle()
                }
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .rotationEffect(.degrees(90))
            }
            .modernButton(backgroundColor: Color.clear, foregroundColor: .secondaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.charcoal.opacity(0.05), radius: 2, x: 0, y: 1)
        .offset(x: showingActions ? -120 : 0)
        .overlay(
            HStack {
                Spacer()
                
                if showingActions {
                    HStack(spacing: 8) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "B3D3BD"))
                                .cornerRadius(8)
                        }
                        
                        Button(action: onDelete) {
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
    }
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
