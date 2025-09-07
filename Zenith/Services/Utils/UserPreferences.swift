//
//  UserPreferences.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation

struct UserPreferences: Codable {
    var preferredCategories: [TaskCategory] = [.work, .health, .personal]
    var preferredDifficulty: TaskDifficulty = .medium
    var dailyTaskCount: Int = 3
    var timeAvailability: TimeAvailability = .moderate
    var focusAreas: [String] = ["Productivity", "Health", "Learning"]
    var avoidCategories: [TaskCategory] = []
    var lastGenerationDate: Date?
    var generationHistory: [String] = []
    
    // Preferences for AI generation
    var includeRoutineTasks: Bool = true
    var includeChallenges: Bool = false
    var preferMorningTasks: Bool = true
    var maxTaskDuration: Int = 60 // minutes
    
    mutating func updateLastGeneration() {
        lastGenerationDate = Date()
    }
    
    mutating func addToHistory(_ prompt: String) {
        generationHistory.append(prompt)
        // Keep only last 10 generations
        if generationHistory.count > 10 {
            generationHistory.removeFirst()
        }
    }
    
    // Check if new tasks should be generated today
    var shouldGenerateToday: Bool {
        guard let lastDate = lastGenerationDate else { return true }
        return !Calendar.current.isDate(lastDate, inSameDayAs: Date())
    }
    
    // Get categories as readable string
    var preferredCategoriesString: String {
        preferredCategories.map { $0.rawValue }.joined(separator: ", ")
    }
}

enum TaskDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    
    var description: String {
        switch self {
        case .easy: return "Simple tasks that take 10-20 minutes"
        case .medium: return "Moderate tasks that take 30-45 minutes"
        case .hard: return "Challenging tasks that take 1-2 hours"
        case .expert: return "Complex tasks that may take several hours"
        }
    }
}

enum TimeAvailability: String, CaseIterable, Codable {
    case limited = "Limited"
    case moderate = "Moderate"
    case flexible = "Flexible"
    
    var description: String {
        switch self {
        case .limited: return "30 minutes or less per day"
        case .moderate: return "1-2 hours per day"
        case .flexible: return "3+ hours per day"
        }
    }
}
