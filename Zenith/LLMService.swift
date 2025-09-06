//
//  LLMService.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import Combine

class LLMService: ObservableObject {
    static let shared = LLMService()
    
    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isGenerating = false
    @Published var generationError: String?
    @Published var lastGeneratedTasks: [Task] = []
    
    private init() {}
    
    // MARK: - Task Generation
    
    func generateDailyTasks(
        userPreferences: UserPreferences,
        currentStreak: Int,
        completedTasks: [Task],
        focusAreas: [TaskCategory] = [.personal, .health, .work]
    ) -> AnyPublisher<[Task], NetworkError> {
        
        isGenerating = true
        generationError = nil
        
        let request = TaskGenerationRequest(
            userPreferences: userPreferences,
            currentStreak: currentStreak,
            completedTasks: completedTasks,
            focusAreas: focusAreas
        )
        
        let chatRequest = createChatRequest(from: request)
        
        do {
            let requestBody = try JSONEncoder().encode(chatRequest)
            
            return networkManager.makeRequest(
                endpoint: "/chat/completions",
                method: .POST,
                body: requestBody,
                responseType: ChatCompletionResponse.self
            )
            .tryMap { [weak self] response -> [Task] in
                return try self?.parseTasksFromResponse(response) ?? []
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { [weak self] tasks in
                    self?.isGenerating = false
                    self?.lastGeneratedTasks = tasks
                    print("✅ Generated \(tasks.count) tasks successfully")
                },
                receiveCompletion: { [weak self] completion in
                    self?.isGenerating = false
                    if case .failure(let error) = completion {
                        self?.generationError = error.localizedDescription
                        print("❌ Task generation failed: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
            
        } catch {
            isGenerating = false
            return Fail(error: NetworkError.unknown("Failed to encode request"))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Quick Task Generation
    
    func generateQuickTasks(count: Int = 3) -> AnyPublisher<[Task], NetworkError> {
        let defaultPreferences = UserPreferences()
        return generateDailyTasks(
            userPreferences: defaultPreferences,
            currentStreak: 0,
            completedTasks: [],
            focusAreas: [.personal, .health]
        )
    }
    
    // MARK: - Motivational Message Generation
    
    func generateMotivationalMessage(streak: Int, level: Int) -> AnyPublisher<String, NetworkError> {
        let prompt = """
        Generate a short, encouraging message for a user who has:
        - Current streak: \(streak) days
        - Current level: \(level)
        
        The message should be motivational, personal, and under 50 words.
        Respond with just the message text, no quotes or extra formatting.
        """
        
        let chatRequest = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                ChatMessage(role: .system, content: "You are a supportive personal growth coach."),
                ChatMessage(role: .user, content: prompt)
            ],
            maxTokens: 100,
            temperature: 0.8
        )
        
        do {
            let requestBody = try JSONEncoder().encode(chatRequest)
            
            return networkManager.makeRequest(
                endpoint: "/chat/completions",
                method: .POST,
                body: requestBody,
                responseType: ChatCompletionResponse.self
            )
            .tryMap { response -> String in
                guard let message = response.choices.first?.message.content else {
                    throw NetworkError.decodingFailed
                }
                return message.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .mapError { error -> NetworkError in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return NetworkError.unknown(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: NetworkError.unknown("Failed to encode request"))
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createChatRequest(from taskRequest: TaskGenerationRequest) -> ChatCompletionRequest {
        let systemMessage = ChatMessage(
            role: .system,
            content: "You are a helpful personal productivity assistant that generates daily tasks. Always respond with valid JSON matching the requested format."
        )
        
        let userMessage = ChatMessage(
            role: .user,
            content: taskRequest.toPrompt()
        )
        
        return ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [systemMessage, userMessage],
            maxTokens: 1000,
            temperature: 0.7
        )
    }
    
    private func parseTasksFromResponse(_ response: ChatCompletionResponse) throws -> [Task] {
        guard let content = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed
        }
        
        print("📝 Raw LLM Response: \(content)")
        
        // Try to extract JSON from the response
        let jsonString = extractJSON(from: content)
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NetworkError.decodingFailed
        }
        
        do {
            let generatedTasks = try JSONDecoder().decode([GeneratedTaskResponse].self, from: jsonData)
            let tasks = generatedTasks.compactMap { $0.toTask() }
            
            if tasks.isEmpty {
                throw NetworkError.decodingFailed
            }
            
            return tasks
        } catch {
            print("❌ JSON Parsing Error: \(error)")
            print("❌ JSON String: \(jsonString)")
            
            // Fallback: create default tasks if parsing fails
            return createFallbackTasks()
        }
    }
    
    private func extractJSON(from text: String) -> String {
        // Look for JSON array in the response
        if let startRange = text.range(of: "["),
           let endRange = text.range(of: "]", options: .backwards) {
            let jsonRange = startRange.lowerBound..<text.index(after: endRange.lowerBound)
            return String(text[jsonRange])
        }
        return text
    }
    
    private func createFallbackTasks() -> [Task] {
        print("🔄 Using fallback tasks due to parsing failure")
        return [
            Task(title: "Morning Reflection", description: "Take 5 minutes to plan your day", priority: .medium, category: .personal),
            Task(title: "Healthy Snack", description: "Choose a nutritious snack for energy", priority: .low, category: .health),
            Task(title: "Quick Learning", description: "Read or watch something educational for 15 minutes", priority: .medium, category: .learning)
        ]
    }
}
