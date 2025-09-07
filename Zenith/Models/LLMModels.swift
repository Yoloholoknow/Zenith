//
//  LLMModels.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation

// MARK: - Gemini Completion Models

struct GeminiCompletionRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
    
    init(contents: [GeminiContent], temperature: Double? = 0.7, maxOutputTokens: Int? = 1000) {
        self.contents = contents
        self.generationConfig = GeminiGenerationConfig(temperature: temperature, maxOutputTokens: maxOutputTokens)
    }
}

struct GeminiGenerationConfig: Codable {
    let temperature: Double?
    let maxOutputTokens: Int?
}

struct GeminiContent: Codable {
    let role: GeminiRole
    let parts: [GeminiPart]
}

struct GeminiPart: Codable {
    let text: String
}

enum GeminiRole: String, Codable {
    case user = "user"
    case model = "model"
}

struct GeminiCompletionResponse: Codable {
    let candidates: [GeminiCandidate]
    let promptFeedback: GeminiPromptFeedback?
}

struct GeminiCandidate: Codable {
    let content: GeminiContent
    let finishReason: String?
}

struct GeminiPromptFeedback: Codable {
    let safetyRatings: [GeminiSafetyRating]
}

struct GeminiSafetyRating: Codable {
    let category: String
    let probability: String
}

// MARK: - Task Generation Models

struct TaskGenerationRequest {
    let userPreferences: UserPreferences
    let currentStreak: Int
    let completedTasks: [Task]
    
    func toPrompt() -> String {
        return """
        Generate \(userPreferences.dailyTaskCount) personalized daily tasks for a user with the following profile:
        
        User Preferences:
        - Preferred categories: \(userPreferences.preferredCategoriesString)
        - Difficulty level: \(userPreferences.preferredDifficulty.rawValue)
        - Time availability: \(userPreferences.timeAvailability.rawValue)
        - Focus areas: \(userPreferences.focusAreas.joined(separator: ", "))
        - Include routine tasks: \(userPreferences.includeRoutineTasks ? "Yes" : "No")
        - Include challenges: \(userPreferences.includeChallenges ? "Yes" : "No")
        - Morning preference: \(userPreferences.preferMorningTasks ? "Yes" : "No")
        - Max duration per task: \(userPreferences.maxTaskDuration) minutes
        - Current Streak: \(currentStreak) days
        
        Recently Completed Tasks:
        \(recentTasksSummary())
        
        Please generate tasks that are:
        1. Achievable within the available time
        2. Appropriate for the difficulty level
        3. Varied and not repetitive of recent tasks
        4. Focused on the specified areas
        5. Motivating to continue the streak
        
        Format your response as a JSON array with this structure:
        [
          {
            "title": "Task title",
            "description": "Detailed description",
            "priority": "Low/Medium/High/Critical",
            "category": "Work/Health/Personal/Learning/Social/Finance/Other"
          }
        ]
        """
    }
    
    private func recentTasksSummary() -> String {
        let recentTasks = completedTasks.suffix(5)
        if recentTasks.isEmpty {
            return "No recent tasks completed."
        }
        return recentTasks.map { "- \($0.title) (\($0.category.rawValue))" }.joined(separator: "\n")
    }
}

// MARK: - Generated Task Response

struct GeneratedTaskResponse: Codable {
    let title: String
    let description: String
    let priority: String
    let category: String
    let estimatedMinutes: Int?
    
    func toTask() -> Task? {
        guard let priority = TaskPriority(rawValue: priority),
              let category = TaskCategory(rawValue: category) else {
            return nil
        }
        
        return Task(
            title: title,
            description: description,
            priority: priority,
            category: category
        )
    }
}
