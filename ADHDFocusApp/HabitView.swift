import SwiftUI

struct HabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedPeriod: CalendarPeriod = .weekly
    @State private var showingAddHabit = false
    @State private var showingEditHabit = false
    @State private var editingHabit: Habit?
    @State private var currentWeekOffset = 0
    
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
                
                // Week Navigation
                weekNavigation
                
                // Progress Header
                progressHeader
                
                // Habit List
                habitListView
                
                Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.mainPoint)
                            )
                    }
                    .modernButton(backgroundColor: Color.clear, foregroundColor: .white)
                    .padding(.trailing, 20)
                    .padding(.bottom, 100) // 탭바 위 공간
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView()
        }
        .sheet(isPresented: $showingEditHabit) {
            if let habit = editingHabit {
                EditHabitView(habit: habit)
            }
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
    
    // MARK: - Week Navigation
    private var weekNavigation: some View {
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
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            
            Spacer()
            
            Text(weekFormatter.string(from: getWeekDates().first ?? Date()) + " - " + weekFormatter.string(from: getWeekDates().last ?? Date()))
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
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
        }
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
                .font(.caption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(hex: "E5EEE8"))
                .cornerRadius(8)
                .padding(.horizontal, 20)
            
            HStack {
                Text("주간 습관")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("\(completedCount)/\(dataManager.habits.count)")
                    .font(.headline)
                    .foregroundColor(.primaryText)
            }
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
                            HabitCardView(
                                habit: habit, 
                                weekDates: getWeekDates(),
                                onToggle: { date in
                                    dataManager.completeHabit(habit, for: date)
                                },
                                onEdit: {
                                    editingHabit = habit
                                    showingEditHabit = true
                                },
                                onDelete: {
                                    dataManager.deleteHabit(habit)
                                }
                            )
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
                .font(.system(size: 15))
                .foregroundColor(.successColor)
            
            Text("아직 등록된 습관이 없습니다")
                .font(.system(size: 16))
                .foregroundColor(.secondaryText)
            
            Text("새로운 습관을 추가해보세요!")
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
        let adjustedDate = calendar.date(byAdding: .weekOfYear, value: currentWeekOffset, to: today) ?? today
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: adjustedDate)?.start ?? adjustedDate
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: weekStart)
        }
    }
    
    private var weekFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }
}

// MARK: - Habit Card View
struct HabitCardView: View {
    let habit: Habit
    let weekDates: [Date]
    let onToggle: (Date) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingActions = false
    
    private let days = ["일", "월", "화", "수", "목", "금", "토"]
    
    private var habitBackgroundColor: Color {
        switch habit.color {
        case "C1E2FF":
            return Color(hex: "E2EEF6")
        case "A4D0B4":
            return Color(hex: "E5EEE8")
        case "F68566":
            return Color(hex: "F9EAE6")
        case "FBEACC":
            return Color(hex: "F7EFE2")
        default:
            return Color(hex: habit.color).opacity(0.1)
        }
    }
    
    private var habitTextColor: Color {
        if habit.color == "FBEACC" {
            return Color(hex: "F7D394")
        } else {
            return Color(hex: habit.color)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and streak
            HStack {
                Text(habit.title)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(habitTextColor)
                    
                    Text("\(getStreakCount())")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(habitTextColor)
                }
            }
            
            // Week days - 요일만 표시, 간격 조정
            HStack(spacing: 8) {
                ForEach(0..<7) { index in
                    HabitDayCircleView(
                        day: days[index],
                        date: weekDates[index],
                        isCompleted: isCompletedForDate(weekDates[index]),
                        color: habitTextColor,
                        onToggle: {
                            onToggle(weekDates[index])
                        },
                        habit: habit
                    )
                }
            }
            .padding(.trailing, 40) // 우측 점 버튼과의 여백
        }
        .padding()
        .background(Color(hex: "FFFDFA"))
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
        .overlay(
            HStack {
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
            .padding(.trailing, 16)
        )
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
    let onToggle: () -> Void
    let habit: Habit // 습관 정보 추가
    
    private var isFutureDate: Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedDescending
    }
    
    private var isApplicableDate: Bool {
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
    
    private var isDisabled: Bool {
        return isFutureDate || !isApplicableDate
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.caption)
                .foregroundColor(.secondaryText)
            
            Button(action: {
                if !isDisabled {
                    onToggle()
                }
            }) {
                Circle()
                    .fill(isCompleted ? color : (isDisabled ? Color(hex: "D9D9D9") : Color.gray.opacity(0.1)))
                    .frame(width: 34, height: 34) // 1.2배 크기 증가 (28 * 1.2 ≈ 34)
                    .overlay {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.caption2)
                        }
                    }
            }
            .disabled(isDisabled)
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
        }
    }
}

// MARK: - Add Habit View
struct AddHabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var selectedColor: Color = ADHDTheme.mainPoint
    @State private var selectedWeekdays: [Int] = []
    @State private var selectedDayOfMonth: Int = 1
    
    private let colorOptions: [Color] = [
        ADHDTheme.mainPoint,
        ADHDTheme.subColor1,
        ADHDTheme.subColor2,
        ADHDTheme.subColor3
    ]
    
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let monthDays = Array(1...31)
    
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
                            
                            TextField("습관을 입력하세요", text: $title)
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
                        
                        // Frequency Selection
                        HStack(spacing: 12) {
                            Text("반복")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequencyOption in
                                    Button(action: {
                                        frequency = frequencyOption
                                        // 초기값 설정
                                        if frequencyOption == .weekly && selectedWeekdays.isEmpty {
                                            selectedWeekdays = [1, 2, 3, 4, 5] // 월-금 기본 선택
                                        }
                                    }) {
                                        Text(frequencyOption.displayName)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(frequency == frequencyOption ? .white : .mainPoint)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(frequency == frequencyOption ? Color.mainPoint : Color.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(Color.mainPoint, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Weekly Selection
                        if frequency == .weekly {
                            HStack(spacing: 12) {
                                Text("요일")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                HStack(spacing: 4) {
                                    ForEach(0..<7) { index in
                                        Button(action: {
                                            if selectedWeekdays.contains(index) {
                                                selectedWeekdays.removeAll { $0 == index }
                                            } else {
                                                selectedWeekdays.append(index)
                                            }
                                        }) {
                                            Text(weekdays[index])
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(selectedWeekdays.contains(index) ? .white : .mainPoint)
                                                .frame(width: 28, height: 28)
                                                .background(
                                                    Circle()
                                                        .fill(selectedWeekdays.contains(index) ? Color.mainPoint : Color.clear)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.mainPoint, lineWidth: 1)
                                                        )
                                                )
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Monthly Selection
                        if frequency == .monthly {
                            HStack(spacing: 12) {
                                Text("일자")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                Picker("일자 선택", selection: $selectedDayOfMonth) {
                                    ForEach(monthDays, id: \.self) { day in
                                        Text("\(day)일").tag(day)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Color Selection
                        HStack(spacing: 12) {
                            Text("컬러")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.charcoal.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                
                // Add Button
                Button(action: addHabit) {
                    Text("습관 추가")
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
            .navigationTitle("새 습관")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        addHabit()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addHabit() {
        let newHabit = Habit(
            title: title,
            description: description,
            category: .health, // 기본 카테고리
            frequency: frequency,
            color: selectedColor.toHex() ?? "F68566",
            selectedWeekdays: selectedWeekdays,
            selectedDayOfMonth: frequency == .monthly ? selectedDayOfMonth : nil
        )
        dataManager.addHabit(newHabit)
        dismiss()
    }
}

// MARK: - Edit Habit View
struct EditHabitView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    
    @State private var title: String
    @State private var description: String
    @State private var frequency: HabitFrequency
    @State private var selectedColor: Color
    @State private var selectedWeekdays: [Int]
    @State private var selectedDayOfMonth: Int
    
    private let colorOptions: [Color] = [
        ADHDTheme.mainPoint,
        ADHDTheme.subColor1,
        ADHDTheme.subColor2,
        ADHDTheme.subColor3
    ]
    
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let monthDays = Array(1...31)
    
    init(habit: Habit) {
        self.habit = habit
        self._title = State(initialValue: habit.title)
        self._description = State(initialValue: habit.description)
        self._frequency = State(initialValue: habit.frequency)
        self._selectedColor = State(initialValue: Color(hex: habit.color))
        self._selectedWeekdays = State(initialValue: habit.selectedWeekdays)
        self._selectedDayOfMonth = State(initialValue: habit.selectedDayOfMonth ?? 1)
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
                            
                            TextField("습관을 입력하세요", text: $title)
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
                        
                        // Frequency Selection
                        HStack(spacing: 12) {
                            Text("반복")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequencyOption in
                                    Button(action: {
                                        frequency = frequencyOption
                                        // 초기값 설정
                                        if frequencyOption == .weekly && selectedWeekdays.isEmpty {
                                            selectedWeekdays = [1, 2, 3, 4, 5] // 월-금 기본 선택
                                        }
                                    }) {
                                        Text(frequencyOption.displayName)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(frequency == frequencyOption ? .white : .mainPoint)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(frequency == frequencyOption ? Color.mainPoint : Color.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(Color.mainPoint, lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Weekly Selection
                        if frequency == .weekly {
                            HStack(spacing: 12) {
                                Text("요일")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                HStack(spacing: 4) {
                                    ForEach(0..<7) { index in
                                        Button(action: {
                                            if selectedWeekdays.contains(index) {
                                                selectedWeekdays.removeAll { $0 == index }
                                            } else {
                                                selectedWeekdays.append(index)
                                            }
                                        }) {
                                            Text(weekdays[index])
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(selectedWeekdays.contains(index) ? .white : .mainPoint)
                                                .frame(width: 28, height: 28)
                                                .background(
                                                    Circle()
                                                        .fill(selectedWeekdays.contains(index) ? Color.mainPoint : Color.clear)
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.mainPoint, lineWidth: 1)
                                                        )
                                                )
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Monthly Selection
                        if frequency == .monthly {
                            HStack(spacing: 12) {
                                Text("일자")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primaryText)
                                    .frame(width: 60, alignment: .leading)
                                
                                Picker("일자 선택", selection: $selectedDayOfMonth) {
                                    ForEach(monthDays, id: \.self) { day in
                                        Text("\(day)일").tag(day)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Color Selection
                        HStack(spacing: 12) {
                            Text("컬러")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primaryText)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                ForEach(colorOptions, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.charcoal.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                
                // Update Button
                Button(action: updateHabit) {
                    Text("습관 수정")
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
            .navigationTitle("습관 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        updateHabit()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func updateHabit() {
        var updatedHabit = habit
        updatedHabit.title = title
        updatedHabit.description = description
        updatedHabit.frequency = frequency
        updatedHabit.color = selectedColor.toHex() ?? "F68566"
        updatedHabit.selectedWeekdays = selectedWeekdays
        updatedHabit.selectedDayOfMonth = frequency == .monthly ? selectedDayOfMonth : nil
        
        dataManager.updateHabit(updatedHabit)
        dismiss()
    }
}

#Preview {
    HabitView()
        .environmentObject(DataManager())
}
