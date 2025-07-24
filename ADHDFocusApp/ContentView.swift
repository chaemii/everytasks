import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // 앱 전체 배경색
            Color.appBackground
                .ignoresSafeArea(.all, edges: .all)
            
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
        }
        .environmentObject(dataManager)
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
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .shadow(color: Color.charcoal.opacity(0.1), radius: 8, x: 0, y: -4)
            }
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
        case 0: return "todos".localized
        case 1: return "habits".localized
        case 2: return "focus_timer".localized
        case 3: return "statistics".localized
        default: return ""
        }
    }
}

#Preview {
    ContentView()
} 