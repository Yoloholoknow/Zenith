//
//  Streak.swift
//  Zenith
//
//  Created by Charles Huang on 9/4/25.
//

import Foundation

struct Streak: Codable {
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var lastCompletionDate: Date?
    var totalDaysCompleted: Int = 0
    var streakStartDate: Date?
    
    // Check if streak should continue based on last completion
    var isStreakActive: Bool {
        guard let lastDate = lastCompletionDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCompletionDay = calendar.startOfDay(for: lastDate)
        
        // Streak is active if last completion was today or yesterday
        let daysDifference = calendar.dateComponents([.day], from: lastCompletionDay, to: today).day ?? 0
        return daysDifference <= 1
    }
    
    // Update streak when tasks are completed for the day
    mutating func updateStreakForCompletion(on date: Date = Date()) {
        let calendar = Calendar.current
        let completionDay = calendar.startOfDay(for: date)
        
        // Check if already completed today
        if let lastDate = lastCompletionDate,
           calendar.isDate(lastDate, inSameDayAs: date) {
            return // Already counted for today
        }
        
        // Update streak logic
        if let lastDate = lastCompletionDate {
            let lastCompletionDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastCompletionDay, to: completionDay).day ?? 0
            
            if daysDifference == 1 {
                // Consecutive day - continue streak
                currentStreak += 1
            } else if daysDifference > 1 {
                // Streak broken - start new streak
                currentStreak = 1
                streakStartDate = date
            }
        } else {
            // First completion ever
            currentStreak = 1
            streakStartDate = date
        }
        
        // Update records
        lastCompletionDate = date
        totalDaysCompleted += 1
        
        // Update best streak if current is better
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
    }
    
    // Reset streak if day was missed
    mutating func checkAndResetIfNeeded() {
        if !isStreakActive && currentStreak > 0 {
            currentStreak = 0
            streakStartDate = nil
        }
    }
}
