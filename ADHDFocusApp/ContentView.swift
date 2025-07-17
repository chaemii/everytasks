import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    @State private var showingAddTask = false
    
    var body: some View {
        ZStack {
            // 배경색
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main Content
                TabView(selection: $selectedTab) {
                    MainView()
                        .tag(0)
                    
                    HabitView()
                        .tag(1)
                    
                    FocusTimerView()
                        .tag(2)
                    
                    StatisticsView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Tab Bar
                customTabBar
            }
            .ignoresSafeArea(.container, edges: .bottom)
            
            // Floating Action Button (할 일 탭에서만 표시)
            if selectedTab == 0 {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingAddTask = true }) {
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
        }
        .environmentObject(dataManager)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
                .environmentObject(dataManager)
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 20))
                            .foregroundColor(selectedTab == index ? .mainPoint : .secondaryText)
                        
                        Text(tabTitle(for: index))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedTab == index ? .mainPoint : .secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .modernButton(backgroundColor: Color.clear, foregroundColor: .primaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color.cardBackground)
                .shadow(color: Color.charcoal.opacity(0.1), radius: 8, x: 0, y: -4)
        )
    }
    
    // MARK: - Tab Helper Methods
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "checklist"
        case 1: return "calendar.badge.checkmark"
        case 2: return "clock"
        case 3: return "chart.bar"
        default: return "circle"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "할 일"
        case 1: return "습관"
        case 2: return "집중"
        case 3: return "통계"
        default: return ""
        }
    }
}

#Preview {
    ContentView()
} 