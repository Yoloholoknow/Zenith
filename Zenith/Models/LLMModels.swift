//
//  LLMModels.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation

// MARK: - OpenAI Chat Completion Models

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let maxTokens: Int?
    let temperature: Double?
    let topP: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
    }
    
    init(model: String = "gpt-3.5-turbo", messages: [ChatMessage], maxTokens: Int? = 1000, temperature: Double? = 0.7, topP: Double? = 1.0) {
        self.model = model
        self.messages = messages
        self.maxTokens = maxTokens
        self.temperature = temperature
        self.topP = topP
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
    
    init(role: MessageRole, content: String) {
        self.role = role.rawValue
        self.content = content
    }
}

enum MessageRole: String, CaseIterable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}

struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [ChatChoice]
    let usage: Usage?
}

struct ChatChoice: Codable {
    let index: Int
    let message: ChatMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct Usage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Task Generation Models

struct TaskGenerationRequest {
    let userPreferences: UserPreferences
    let currentStreak: Int
    let completedTasks: [Task]
    let focusAreas: [TaskCategory]
    
    func toPrompt() -> String {
        return """
        Generate 3-5 personalized daily tasks for a user with the following profile:
        
        User Preferences:
        - Focus Areas: \(focusAreas.map { $0.rawValue }.joined(separator: ", "))
        - Difficulty Level: \(userPreferences.difficultyLevel)
        - Available Time: \(userPreferences.availableTimeMinutes) minutes
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
            "category": "Work/Health/Personal/Learning/Social/Finance/Other",
            "estimatedMinutes": 30
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

struct UserPreferences: Codable {
    let difficultyLevel: DifficultyLevel
    let availableTimeMinutes: Int
    let preferredCategories: [TaskCategory]
    let workSchedule: WorkSchedule
    
    init() {
        self.difficultyLevel = .medium
        self.availableTimeMinutes = 60
        self.preferredCategories = [.personal, .health]
        self.workSchedule = .flexible
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
}

enum WorkSchedule: String, CaseIterable, Codable {
    case morning = "Morning Person"
    case evening = "Evening Person"
    case flexible = "Flexible"
    case busy = "Very Busy"
}

// MARK: - Generated Task Response

struct GeneratedTaskResponse: Codable {
    let title: String
    let description: String
    let priority: String
    let category: String
    let estimatedMinutes: Int
    
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

// MARK: - Error Handling

struct LLMErrorResponse: Codable {
    let error: LLMError
}

struct LLMError: Codable {
    let message: String
    let type: String?
    let param: String?
    let code: String?
}
