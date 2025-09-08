//
//  StreakManager.swift
//  Zenith
//
//  Created by Charles Huang on 9/4/25.
//

import Foundation
import Combine

class StreakManager: ObservableObject {
    @Published var streak = Streak()
    
    private let userDefaults = UserDefaults.standard
    private let streakKey = "user_streak_data"
    
    init() {
        // Load streak data using validated DataManager methods
        print("🔥 StreakManager: Loading validated streak data")
        streak = DataManager.shared.loadStreakWithValidation()
        print("🔥 StreakManager: Loaded streak - Current: \(streak.currentStreak), Best: \(streak.bestStreak)")
        
        checkDailyReset()
    }
    
    // Save streak data to UserDefaults
    private func saveStreak() {
        DataManager.shared.saveStreak(streak)
    }
    
    // Check if streak should be reset due to missed days
    private func checkDailyReset() {
        streak.checkAndResetIfNeeded()
        saveStreak()
    }
    
    // Mark today as completed (call when user completes daily tasks)
    func markTodayCompleted() {
        let previousStreak = streak.currentStreak
        streak.updateStreakForCompletion()
        
        // Log streak update
        if streak.currentStreak > previousStreak {
            print("🔥 Streak increased to \(streak.currentStreak) days!")
        } else {
            print("✅ Today already completed")
        }
        
        saveStreak()
    }
    
    // ADDED: New function to remove a completion and decrement streak if needed
    func removeCompletion(on date: Date) {
        let allTasks = DataManager.shared.loadTasks() + DataManager.shared.loadArchivedTasks()
        let calendar = Calendar.current
        
        // Count how many tasks were completed on the specified date
        let completedOnDateCount = allTasks.filter { task in
            guard task.isCompleted, let completedDate = task.completedDate else { return false }
            return calendar.isDate(completedDate, inSameDayAs: date)
        }.count
        
        // Only decrement streak if this was the last task for that day
        if completedOnDateCount <= 1 {
            streak.currentStreak = max(0, streak.currentStreak - 1)
            streak.totalDaysCompleted = max(0, streak.totalDaysCompleted - 1)
            print("🔥 Streak decremented to \(streak.currentStreak) days.")
            
            if streak.currentStreak == 0 {
                streak.lastCompletionDate = nil
                streak.streakStartDate = nil
            } else {
                // Find the new last completion date
                let tasksBeforeRemovedDay = allTasks.filter { task in
                    guard let completedDate = task.completedDate else { return false }
                    return completedDate < date
                }.sorted { $0.completedDate! > $1.completedDate! }
                
                streak.lastCompletionDate = tasksBeforeRemovedDay.first?.completedDate
            }
        }
        
        saveStreak()
    }
    
    // Get current streak count
    var currentStreakCount: Int {
        return streak.currentStreak
    }
    
    // Get best streak count
    var bestStreakCount: Int {
        return streak.bestStreak
    }
    
    // Check if user has active streak
    var hasActiveStreak: Bool {
        return streak.isStreakActive && streak.currentStreak > 0
    }
    
    // Get streak status message
    var streakStatusMessage: String {
        if streak.currentStreak == 0 {
            return "Start your streak today!"
        } else if streak.currentStreak == 1 {
            return "Great start! Keep it going tomorrow."
        } else if streak.currentStreak >= 7 {
            return "Incredible! You're on a week-long streak! 🔥"
        } else if streak.currentStreak >= 3 {
            return "Amazing momentum! You're building a solid habit! ⭐"
        } else {
            return "Great progress! Keep the momentum going! 💪"
        }
    }
    
    // Reset streak (for testing purposes)
    func resetStreak() {
        print("🗑️ Resetting streak data")
        streak = Streak()
        saveStreak()
    }
    
    // Get days since last completion
    var daysSinceLastCompletion: Int {
        guard let lastDate = streak.lastCompletionDate else { return -1 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCompletionDay = calendar.startOfDay(for: lastDate)
        return calendar.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
    }
    
    // Check if today is already completed
    var isTodayCompleted: Bool {
        guard let lastDate = streak.lastCompletionDate else { return false }
        return Calendar.current.isDate(lastDate, inSameDayAs: Date())
    }
    
}
