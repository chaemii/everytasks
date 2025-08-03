import Foundation

// 공유 습관 모델
struct SharedHabit: Codable {
    let id: String
    let title: String
    var isCompleted: Bool
    let date: Date
}

// 공유 할일 모델
struct SharedTodo: Codable {
    let id: String
    let title: String
    var isCompleted: Bool
    let date: Date
}

// 공유 데이터 모델
struct SharedData: Codable {
    var habits: [SharedHabit]
    var todos: [SharedTodo]
    var lastUpdated: Date
} 