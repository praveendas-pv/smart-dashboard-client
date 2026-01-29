import Foundation

struct Item: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let price: Double
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let completed: Bool
    let createdAt: Date
    let updatedAt: Date?

    var statusText: String { completed ? "Completed" : "Pending" }
}

struct HealthResponse: Codable {
    let status: String
}
