//
//  AITaskGenerator.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import Combine

class AITaskGenerator: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedTasks: [Task] = []
    @Published var lastGenerationDate: Date?
    @Published var errorMessage: String?
    
    private let dataManager = DataManager.shared
    private var userPreferences = UserPreferences()
    
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
        let completionRate = calculateCompletionRate(from: recentTasks)
        
        // Generate task prompt
        let prompt = createTaskGenerationPrompt(completionRate: completionRate, recentTasks: recentTasks)
        
        // Simulate AI generation (in real app, this would call an AI API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateAIGeneration(with: prompt)
        }
    }
    
    private func createTaskGenerationPrompt(completionRate: Double, recentTasks: [Task]) -> String {
        let preferences = userPreferences
        
        var prompt = """
        Generate \(preferences.dailyTaskCount) personalized daily tasks based on these preferences:
        
        **User Profile:**
        - Preferred categories: \(preferences.preferredCategoriesString)
        - Difficulty level: \(preferences.preferredDifficulty.rawValue)
        - Time availability: \(preferences.timeAvailability.rawValue)
        - Focus areas: \(preferences.focusAreas.joined(separator: ", "))
        - Include routine tasks: \(preferences.includeRoutineTasks ? "Yes" : "No")
        - Include challenges: \(preferences.includeChallenges ? "Yes" : "No")
        - Morning preference: \(preferences.preferMorningTasks ? "Yes" : "No")
        - Max duration per task: \(preferences.maxTaskDuration) minutes
        
        **Performance Context:**
        - Recent completion rate: \(Int(completionRate * 100))%
        """
        
        // Add recent task context
        if !recentTasks.isEmpty {
            let recentTaskTitles = recentTasks.prefix(5).map { $0.title }.joined(separator: ", ")
            prompt += "\n- Recent tasks: \(recentTaskTitles)"
        }
        
        // Add adaptive suggestions based on completion rate
        if completionRate < 0.5 {
            prompt += "\n\n**Adaptation:** User has low completion rate. Focus on simpler, shorter tasks to build momentum."
        } else if completionRate > 0.8 {
            prompt += "\n\n**Adaptation:** User has high completion rate. Consider slightly more challenging tasks."
        }
        
        prompt += "\n\nGenerate varied, actionable tasks that will help the user grow in their focus areas."
        
        return prompt
    }
    
    private func simulateAIGeneration(with prompt: String) {
        print("🤖 AI Prompt: \(prompt)")
        
        // Simulate AI-generated tasks based on preferences
        let simulatedTasks = createSimulatedTasks()
        
        self.generatedTasks = simulatedTasks
        self.lastGenerationDate = Date()
        self.userPreferences.updateLastGeneration()
        self.userPreferences.addToHistory(prompt)
        self.savePreferences()
        self.isGenerating = false
        
        print("✅ Generated \(simulatedTasks.count) AI tasks")
    }
    
    private func createSimulatedTasks() -> [Task] {
        let preferences = userPreferences
        var tasks: [Task] = []
        
        // Task templates based on categories
        let taskTemplates: [TaskCategory: [(String, String)]] = [
            .work: [
                ("Review and organize email inbox", "Process emails and archive completed items"),
                ("Plan tomorrow's priorities", "Identify top 3 tasks for tomorrow"),
                ("Update project documentation", "Document recent progress and next steps")
            ],
            .health: [
                ("30-minute walk or exercise", "Get moving with your preferred physical activity"),
                ("Prepare a nutritious meal", "Cook something healthy and delicious"),
                ("Practice mindfulness for 10 minutes", "Take time for meditation or deep breathing")
            ],
            .learning: [
                ("Read for 20 minutes", "Continue with your current book or article"),
                ("Watch an educational video", "Learn something new in your area of interest"),
                ("Practice a new skill", "Spend time developing a skill you want to improve")
            ],
            .personal: [
                ("Declutter one area of living space", "Organize a drawer, shelf, or small area"),
                ("Call or message a friend", "Reconnect with someone important to you"),
                ("Plan a weekend activity", "Research and plan something enjoyable")
            ],
            .social: [
                ("Reach out to a colleague", "Have a meaningful conversation with a coworker"),
                ("Plan time with family", "Schedule quality time with family members"),
                ("Join a community activity", "Participate in a local or online community event")
            ]
        ]
        
        // Generate tasks from preferred categories
        var usedCategories: [TaskCategory] = []
        for _ in 0..<preferences.dailyTaskCount {
            let availableCategories = preferences.preferredCategories.filter { !usedCategories.contains($0) || usedCategories.count < preferences.preferredCategories.count }
            
            guard let category = availableCategories.randomElement(),
                  let templates = taskTemplates[category],
                  let template = templates.randomElement() else {
                continue
            }
            
            let priority = getRandomPriority(basedOn: preferences.preferredDifficulty)
            let task = Task(
                title: template.0,
                description: template.1,
                priority: priority,
                category: category
            )
            
            tasks.append(task)
            usedCategories.append(category)
        }
        
        return tasks
    }
    
    private func getRandomPriority(basedOn difficulty: TaskDifficulty) -> TaskPriority {
        switch difficulty {
        case .easy:
            return Bool.random() ? .low : .medium
        case .medium:
            return [.low, .medium, .high].randomElement() ?? .medium
        case .hard:
            return Bool.random() ? .high : .critical
        case .expert:
            return .critical
        }
    }
    
    // MARK: - Analytics
    
    private func getRecentTaskHistory() -> [Task] {
        let allTasks = dataManager.loadTasks()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allTasks.filter { $0.createdDate >= sevenDaysAgo }
    }
    
    private func calculateCompletionRate(from tasks: [Task]) -> Double {
        guard !tasks.isEmpty else { return 0.5 } // Default neutral rate
        let completed = tasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(tasks.count)
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
