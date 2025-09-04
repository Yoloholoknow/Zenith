//
//  Task.swift
//  Zenith
//
//  Created by Charles Huang on 9/3/25.
//

import Foundation

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    // Points awarded based on priority
    var pointValue: Int {
        switch self {
        case .low: return 10
        case .medium: return 25
        case .high: return 50
        case .critical: return 100
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case work = "Work"
    case health = "Health"
    case personal = "Personal"
    case learning = "Learning"
    case social = "Social"
    case finance = "Finance"
    case other = "Other"
}

struct Task: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isCompleted: Bool = false
    var createdDate: Date = Date()
    var completedDate: Date?
    var priority: TaskPriority
    var category: TaskCategory = .other
    var pointsEarned: Int = 0
    var experienceValue: Int = 0
    
    // Computed property for potential points
    var potentialPoints: Int {
        return priority.pointValue
    }
    
    // Mark task as completed and award points
    mutating func markAsCompleted() {
        isCompleted = true
        completedDate = Date()
        pointsEarned = priority.pointValue
        experienceValue = priority.pointValue / 2 // Experience is half of points
    }
    
    // Mark task as incomplete and remove points
    mutating func markAsIncomplete() {
        isCompleted = false
        completedDate = nil
        pointsEarned = 0
        experienceValue = 0
    }
    
    // Convenience initializer for creating new tasks
    init(title: String, description: String, priority: TaskPriority = .medium, category: TaskCategory = .other) {
        self.title = title
        self.description = description
        self.priority = priority
        self.category = category
    }
    
    // Create sample tasks for testing
    static func sampleTasks() -> [Task] {
        return [
            Task(title: "Morning Workout", description: "30-minute cardio session", priority: .high, category: .health),
            Task(title: "Review Project Proposal", description: "Check and approve the new client proposal", priority: .critical, category: .work),
            Task(title: "Read 20 Pages", description: "Continue reading current book", priority: .medium, category: .learning),
            Task(title: "Call Mom", description: "Weekly check-in phone call", priority: .medium, category: .social),
            Task(title: "Organize Desk", description: "Clean and organize workspace", priority: .low, category: .personal)
        ]
    }
}
