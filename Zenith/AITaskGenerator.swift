//
//  AITaskGenerator.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import Combine
import SwiftUI // Make sure SwiftUI is imported for preview

class AITaskGenerator: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedTasks: [Task] = []
    @Published var lastGenerationDate: Date?
    @Published var errorMessage: String?
    
    private let dataManager = DataManager.shared
    private let llmService = LLMService.shared
    private var userPreferences = UserPreferences()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPreferences()
    }
    
    // MARK: - Preferences Management
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: "user_preferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            userPreferences = preferences
        }
    }
    
    private func savePreferences() {
        if let data = try? JSONEncoder().encode(userPreferences) {
            UserDefaults.standard.set(data, forKey: "user_preferences")
        }
    }
    
    func updatePreferences(_ newPreferences: UserPreferences) {
        userPreferences = newPreferences
        savePreferences()
    }
    
    // MARK: - Task Generation
    
    func generateDailyTasks() {
        guard userPreferences.shouldGenerateToday else {
            print("⏰ Tasks already generated today")
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        // Get completion history for context
        let recentTasks = getRecentTaskHistory()
        let streakManager = StreakManager()
        let currentStreak = streakManager.currentStreakCount
        
        // Call the LLMService
        llmService.generateDailyTasks(userPreferences: userPreferences, currentStreak: currentStreak, completedTasks: recentTasks)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isGenerating = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        print("❌ Task generation failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] tasks in
                    self?.generatedTasks = tasks
                    self?.lastGenerationDate = Date()
                    self?.userPreferences.updateLastGeneration()
                    self?.userPreferences.addToHistory("Generated \(tasks.count) tasks.")
                    self?.savePreferences()
                    print("✅ Generated \(tasks.count) tasks successfully")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Analytics
    
    private func getRecentTaskHistory() -> [Task] {
        let allTasks = dataManager.loadTasks()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allTasks.filter { $0.createdDate >= sevenDaysAgo }
    }
    
    // MARK: - Public Interface
    
    func canGenerateToday() -> Bool {
        return userPreferences.shouldGenerateToday
    }
    
    func getUserPreferences() -> UserPreferences {
        return userPreferences
    }
    
    func getGenerationStatus() -> String {
        if let lastDate = lastGenerationDate {
            let formatter = RelativeDateTimeFormatter()
            return "Last generated \(formatter.localizedString(for: lastDate, relativeTo: Date()))"
        }
        return "No tasks generated yet"
    }
}

struct AITaskGenerator_Previews: PreviewProvider {
    static var previews: some View {
        Text("No preview available for this file. It contains a class, not a view.")
    }
}
