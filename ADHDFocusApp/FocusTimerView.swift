import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentSession: FocusSession?
    @State private var timeRemaining = 25 * 60 // 25분 in seconds
    @State private var isTimerRunning = false
    @State private var isBreakTime = false
    @State private var timer: Timer?

    @State private var focusMinutes = 25
    @State private var breakMinutes = 5
    @State private var completedSessions = 0
    @State private var animateProgress = false
    @State private var shadowAnimation = false
    @State private var selectedPreset: TimerPreset = .pomodoro
    @State private var currentMotivationMessage = ""
    
    // 동기부여 메시지 배열
    private var focusMessages: [String] {
        return [
            "focus_message_1".localized,
            "focus_message_2".localized,
            "focus_message_3".localized,
            "focus_message_4".localized,
            "focus_message_5".localized,
            "focus_message_6".localized,
            "focus_message_7".localized,
            "focus_message_8".localized,
            "focus_message_9".localized,
            "focus_message_10".localized
        ]
    }
    
    enum TimerPreset: String, CaseIterable {
        case pomodoro = "pomodoro"
        case ultradeep = "ultradeep"
        case shortfocus = "shortfocus"
        
        var focusMinutes: Int {
            switch self {
            case .pomodoro: return 25
            case .ultradeep: return 45
            case .shortfocus: return 15
            }
        }
        
        var breakMinutes: Int {
            switch self {
            case .pomodoro: return 5
            case .ultradeep: return 15
            case .shortfocus: return 5
            }
        }
        
        var color: Color {
            switch self {
            case .pomodoro: return Color(hex: "F68566") // 다홍계열
            case .ultradeep: return Color(hex: "A4D0B4") // 민트계열
            case .shortfocus: return Color(hex: "99CFFF") // 블루계열
            }
        }
        
        var displayName: String {
            switch self {
            case .pomodoro: return "pomodoro".localized + " (25분/5분)"
            case .ultradeep: return "ultradeep".localized + " (45분/15분)"
            case .shortfocus: return "shortfocus".localized + " (15분/5분)"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 배경색
            Color.appBackground
                .ignoresSafeArea(.all, edges: .all)
            
            ScrollView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Preset Selection (only when timer is not running)
                if !isTimerRunning {
                    presetSelectionView
                }
                
                // Timer Display
                timerDisplay
                
                // Control Buttons
                controlButtons
                
                // Session Info
                sessionInfo
                
                Spacer(minLength: 100)
            }
            }
        }
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            stopTimer()
        }

    }
    
    // MARK: - Preset Selection View
    private var presetSelectionView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(TimerPreset.allCases, id: \.self) { preset in
                    Button(action: {
                        selectedPreset = preset
                        focusMinutes = preset.focusMinutes
                        breakMinutes = preset.breakMinutes
                        timeRemaining = preset.focusMinutes * 60
                    }) {
                        Text(preset.rawValue.localized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedPreset == preset ? .white : preset.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedPreset == preset ? preset.color : preset.color.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(preset.color.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("focus_timer".localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text(isBreakTime ? "break_time".localized : "focus_time".localized)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Timer Display
    private var timerDisplay: some View {
        VStack(spacing: 40) {
            // Main Timer Circle
            ZStack {
                // Background Circle
                Circle()
                    .stroke(Color.charcoal.opacity(0.1), lineWidth: 8)
                    .frame(width: 280, height: 280)
                
                // Progress Circle
                Circle()
                    .trim(from: 0.0, to: CGFloat(progressValue))
                    .stroke(
                        isBreakTime ? Color.successColor : selectedPreset.color,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 280, height: 280)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut(duration: 0.5), value: progressValue)
                
                // Inner Content
                VStack(spacing: 16) {
                    // Timer Text
                    Text(timeString)
                        .font(.system(size: 42, weight: .light, design: .rounded))
                        .foregroundColor(.primaryText)
                        .monospacedDigit()
                    
                    // Status Text
                    Text(isBreakTime ? "break_time".localized : "focus_in_progress".localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondaryText)
                        .opacity(isTimerRunning ? 1.0 : 0.6)
                    
                    // Add Time Buttons (only when focusing)
                    if isTimerRunning && !isBreakTime {
                        HStack(spacing: 12) {
                            Button(action: {
                                timeRemaining += 5 * 60 // Add 5 minutes
                            }) {
                                Text("add_5_minutes".localized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedPreset.color.opacity(0.8))
                                    )
                            }
                            
                            Button(action: {
                                timeRemaining += 10 * 60 // Add 10 minutes
                            }) {
                                Text("add_10_minutes".localized)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedPreset.color.opacity(0.8))
                                    )
                            }
                        }
                    }
                    
                    // Pulse Effect
                    if isTimerRunning {
                        Circle()
                            .fill(isBreakTime ? Color.successColor : selectedPreset.color)
                            .frame(width: 12, height: 12)
                            .opacity(animateProgress ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateProgress)
                    }
                }
            }
            .padding()
            .background(
                ZStack {
                    // 그라데이션 애니메이션 레이어 (집중 중일 때만)
                    if isTimerRunning && !isBreakTime {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        selectedPreset.color.opacity(0.3),
                                        selectedPreset.color.opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 110 + (shadowAnimation ? 20 : 0),
                                    endRadius: 180 + (shadowAnimation ? 30 : 0)
                                )
                            )
                            .frame(width: 400, height: 400)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: shadowAnimation)
                    }
                    
                    // 메인 원형 배경
                    Circle()
                        .fill(Color(hex: "#FFFDFA"))
                        .frame(width: 320, height: 320)
                        .shadow(
                            color: Color.charcoal.opacity(0.08),
                            radius: 20, 
                            x: 0, 
                            y: 10
                        )
                }
            )
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 32) {
            // Reset Button
            Button(action: resetTimer) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(Color.mainPoint.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .background(.clear)
            
            // Play/Pause Button
            Button(action: toggleTimer) {
                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(isBreakTime ? Color.successColor : selectedPreset.color)
                    )
            }
            .background(.clear)
            .scaleEffect(isTimerRunning ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isTimerRunning)
            
            // Skip Button
            Button(action: skipSession) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.cardBackground)
                            .overlay(
                                Circle()
                                    .stroke(Color.mainPoint.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .background(.clear)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Session Info
    private var sessionInfo: some View {
        VStack(spacing: 16) {
            // Session Counter
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(completedSessions)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("focus_completed_sessions".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Vertical Divider
                Rectangle()
                    .fill(Color.charcoal.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("\(focusMinutes)m")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("focus_duration".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
                
                // Vertical Divider
                Rectangle()
                    .fill(Color.charcoal.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 4) {
                    Text("\(breakMinutes)m")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("break_duration".localized)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBackground)
                    .shadow(color: Color.charcoal.opacity(0.03), radius: 2, x: 0, y: 1)
            )
            
            // Motivation Message
            if isTimerRunning {
                Text(isBreakTime ? "잠시 휴식을 취하세요 😌" : currentMotivationMessage)
                    .font(.subheadline)
                    .foregroundColor(isBreakTime ? .successColor : getMotivationTextColor())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill((isBreakTime ? Color.successColor : getMotivationBackgroundColor()).opacity(0.12))
                    )
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progressValue: Double {
        let totalTime = isBreakTime ? breakMinutes * 60 : focusMinutes * 60
        return 1.0 - (Double(timeRemaining) / Double(totalTime))
    }
    
    // MARK: - Timer Methods
    private func setupTimer() {
        timeRemaining = focusMinutes * 60
        isBreakTime = false
        animateProgress = true
        syncPresetWithTimer()
        updateMotivationMessage()
    }
    
    private func syncPresetWithTimer() {
        // 현재 타이머 설정에 맞는 프리셋 찾기
        for preset in TimerPreset.allCases {
            if preset.focusMinutes == focusMinutes && preset.breakMinutes == breakMinutes {
                selectedPreset = preset
                break
            }
        }
    }
    
    private func updateMotivationMessage() {
        if !isBreakTime && isTimerRunning {
            currentMotivationMessage = focusMessages.randomElement() ?? "집중하고 있어요! 🎯"
        }
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isTimerRunning = true
        animateProgress = true
        shadowAnimation = true
        updateMotivationMessage()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                // 30초마다 메시지 변경
                if timeRemaining % 30 == 0 && !isBreakTime {
                    updateMotivationMessage()
                }
            } else {
                completeSession()
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        animateProgress = false
        shadowAnimation = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = isBreakTime ? breakMinutes * 60 : focusMinutes * 60
    }
    
    private func skipSession() {
        completeSession()
    }
    
    private func completeSession() {
        stopTimer()
        
        if !isBreakTime {
            // Focus session completed
            completedSessions += 1
            
            // Save to data manager
            let session = FocusSession(
                title: "집중 세션",
                duration: TimeInterval(focusMinutes * 60)
            )
            dataManager.addFocusSession(session)
            
            // Switch to break
            isBreakTime = true
            timeRemaining = breakMinutes * 60
        } else {
            // Break completed
            isBreakTime = false
            timeRemaining = focusMinutes * 60
        }
    }
}



// MARK: - Helper Methods for Motivation Message Colors
extension FocusTimerView {
    private func getMotivationTextColor() -> Color {
        switch selectedPreset {
        case .pomodoro:
            return selectedPreset.color
        case .ultradeep:
            return Color(hex: "2E7D32") // 더 진한 초록색으로 가시성 향상
        case .shortfocus:
            return Color(hex: "1565C0") // 더 진한 파란색으로 가시성 향상
        }
    }
    
    private func getMotivationBackgroundColor() -> Color {
        switch selectedPreset {
        case .pomodoro:
            return selectedPreset.color
        case .ultradeep:
            return Color(hex: "4CAF50") // 밝은 초록색 배경
        case .shortfocus:
            return Color(hex: "2196F3") // 밝은 파란색 배경
        }
    }
}

#Preview {
    FocusTimerView()
        .environmentObject(DataManager())
} 
