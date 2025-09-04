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
        loadStreak()
        checkDailyReset()
    }
    
    // Load streak data from UserDefaults
    private func loadStreak() {
        if let data = userDefaults.data(forKey: streakKey),
           let savedStreak = try? JSONDecoder().decode(Streak.self, from: data) {
            streak = savedStreak
        }
    }
    
    // Save streak data to UserDefaults
    private func saveStreak() {
        if let data = try? JSONEncoder().encode(streak) {
            userDefaults.set(data, forKey: streakKey)
        }
    }
    
    // Check if streak should be reset due to missed days
    private func checkDailyReset() {
        streak.checkAndResetIfNeeded()
        saveStreak()
    }
    
    // Mark today as completed (call when user completes daily tasks)
    func markTodayCompleted() {
        streak.updateStreakForCompletion()
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
        } else {
            return "Amazing! You're on fire! 🔥"
        }
    }
    
    // Reset streak (for testing purposes)
    func resetStreak() {
        streak = Streak()
        saveStreak()
    }
}
