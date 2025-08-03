import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let userDefaults = UserDefaults(suiteName: "group.everytasks")
    
    private init() {}
    
    // 공유 데이터 읽기
    func getSharedData() -> SharedData? {
        guard let data = userDefaults?.data(forKey: "sharedData"),
              let sharedData = try? JSONDecoder().decode(SharedData.self, from: data) else {
            // 데이터가 없으면 빈 SharedData 반환
            return SharedData(habits: [], todos: [], lastUpdated: Date())
        }
        return sharedData
    }
    
    // 할일 토글
    func toggleTodo(id: String) {
        guard var sharedData = getSharedData() else { return }
        
        if let index = sharedData.todos.firstIndex(where: { $0.id == id }) {
            sharedData.todos[index].isCompleted.toggle()
            sharedData.lastUpdated = Date()
            saveSharedData(sharedData)
        }
    }
    
    // 습관 토글
    func toggleHabit(id: String) {
        guard var sharedData = getSharedData() else { return }
        
        if let index = sharedData.habits.firstIndex(where: { $0.id == id }) {
            sharedData.habits[index].isCompleted.toggle()
            sharedData.lastUpdated = Date()
            saveSharedData(sharedData)
        }
    }
    
    // 공유 데이터 저장
    private func saveSharedData(_ data: SharedData) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: "sharedData")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
} 