import SwiftUI

struct FocusTimerView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentSession: FocusSession?
    @State private var timeRemaining = 25 * 60 // 25분 in seconds
    @State private var isTimerRunning = false
    @State private var isBreakTime = false
    @State private var timer: Timer?
    @State private var showingSettings = false
    @State private var focusMinutes = 25
    @State private var breakMinutes = 5
    @State private var completedSessions = 0
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Timer Display
                timerDisplay
                
                // Control Buttons
                controlButtons
                
                // Session Info
                sessionInfo
                
                Spacer()
            }
        }
        .onAppear {
            setupTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showingSettings) {
            TimerSettingsView(
                focusMinutes: $focusMinutes,
                breakMinutes: $breakMinutes
            )
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("집중 타이머")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text(isBreakTime ? "휴식 시간" : "집중 시간")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .font(.title2)
                    .foregroundColor(.primaryText)
            }
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
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
                        isBreakTime ? Color.successColor : Color.mainPoint,
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
                    Text(isBreakTime ? "휴식 중" : "집중 중")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondaryText)
                        .opacity(isTimerRunning ? 1.0 : 0.6)
                    
                    // Pulse Effect
                    if isTimerRunning {
                        Circle()
                            .fill(isBreakTime ? Color.successColor : Color.mainPoint)
                            .frame(width: 12, height: 12)
                            .opacity(animateProgress ? 0.3 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateProgress)
                    }
                }
            }
            .padding()
            .background(
                Circle()
                    .fill(Color.cardBackground)
                    .frame(width: 320, height: 320)
                    .shadow(color: Color.charcoal.opacity(0.08), radius: 20, x: 0, y: 10)
            )
        }
        .padding(.vertical, 40)
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
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            
            // Play/Pause Button
            Button(action: toggleTimer) {
                Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(isBreakTime ? Color.successColor : Color.mainPoint)
                            .shadow(color: Color.charcoal.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
            }
            .modernButton(backgroundColor: Color.clear, foregroundColor: .white)
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
            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Session Info
    private var sessionInfo: some View {
        VStack(spacing: 16) {
            // Session Counter
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(completedSessions)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("완료된 세션")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(minWidth: 80)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground)
                        .shadow(color: Color.charcoal.opacity(0.03), radius: 2, x: 0, y: 1)
                )
                
                VStack(spacing: 4) {
                    Text("\(focusMinutes)분")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("집중 시간")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(minWidth: 80)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground)
                        .shadow(color: Color.charcoal.opacity(0.03), radius: 2, x: 0, y: 1)
                )
                
                VStack(spacing: 4) {
                    Text("\(breakMinutes)분")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("휴식 시간")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                .frame(minWidth: 80)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground)
                        .shadow(color: Color.charcoal.opacity(0.03), radius: 2, x: 0, y: 1)
                )
            }
            
            // Motivation Message
            if isTimerRunning {
                Text(isBreakTime ? "잠시 휴식을 취하세요 😌" : "집중하고 있어요! 🎯")
                    .font(.subheadline)
                    .foregroundColor(isBreakTime ? .successColor : .mainPoint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill((isBreakTime ? Color.successColor : Color.mainPoint).opacity(0.12))
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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
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

// MARK: - Timer Settings View
struct TimerSettingsView: View {
    @Binding var focusMinutes: Int
    @Binding var breakMinutes: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Focus Time Setting
                    VStack(alignment: .leading, spacing: 12) {
                        Text("집중 시간")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Button(action: {
                                if focusMinutes > 5 {
                                    focusMinutes -= 5
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .foregroundColor(.primaryText)
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                            
                            Spacer()
                            
                            Text("\(focusMinutes)분")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            Spacer()
                            
                            Button(action: {
                                if focusMinutes < 60 {
                                    focusMinutes += 5
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.primaryText)
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                        }
                        .padding()
                        .cardStyle()
                    }
                    
                    // Break Time Setting
                    VStack(alignment: .leading, spacing: 12) {
                        Text("휴식 시간")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        HStack {
                            Button(action: {
                                if breakMinutes > 5 {
                                    breakMinutes -= 5
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .foregroundColor(.primaryText)
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                            
                            Spacer()
                            
                            Text("\(breakMinutes)분")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            Spacer()
                            
                            Button(action: {
                                if breakMinutes < 30 {
                                    breakMinutes += 5
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.primaryText)
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                        }
                        .padding()
                        .cardStyle()
                    }
                    
                    // Preset Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("프리셋")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        VStack(spacing: 8) {
                            Button(action: {
                                focusMinutes = 25
                                breakMinutes = 5
                            }) {
                                HStack {
                                    Text("포모도로 (25분/5분)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    if focusMinutes == 25 && breakMinutes == 5 {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.successColor)
                                    }
                                }
                                .padding()
                                .cardStyle()
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                            
                            Button(action: {
                                focusMinutes = 45
                                breakMinutes = 15
                            }) {
                                HStack {
                                    Text("울트라딥 (45분/15분)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    if focusMinutes == 45 && breakMinutes == 15 {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.successColor)
                                    }
                                }
                                .padding()
                                .cardStyle()
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                            
                            Button(action: {
                                focusMinutes = 15
                                breakMinutes = 5
                            }) {
                                HStack {
                                    Text("숏 포커스 (15분/5분)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primaryText)
                                    Spacer()
                                    if focusMinutes == 15 && breakMinutes == 5 {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.successColor)
                                    }
                                }
                                .padding()
                                .cardStyle()
                            }
                            .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("타이머 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                    .foregroundColor(.primaryText)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    FocusTimerView()
        .environmentObject(DataManager())
} 
