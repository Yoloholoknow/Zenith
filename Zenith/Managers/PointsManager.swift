//
//  PointsManager.swift
//  Zenith
//
//  Created by Charles Huang on 9/4/25.
//

import Foundation
import Combine

class PointsManager: ObservableObject {
    @Published var userPoints = UserPoints()
    @Published var showCelebration = false
    @Published var lastAwardedPoints = 0
    
    private let userDefaults = UserDefaults.standard
    private let pointsKey = "user_points_data"
    
    init() {
        loadPoints()
        checkDailyReset()
    }
    
    // Load points data from UserDefaults
    private func loadPoints() {
        if let data = userDefaults.data(forKey: pointsKey),
           let savedPoints = try? JSONDecoder().decode(UserPoints.self, from: data) {
            userPoints = savedPoints
        }
    }
    
    // Save points data to UserDefaults
    private func savePoints() {
        if let data = try? JSONEncoder().encode(userPoints) {
            userDefaults.set(data, forKey: pointsKey)
        }
    }
    
    // Check if daily points should be reset
    private func checkDailyReset() {
        userPoints.resetDailyPoints()
        savePoints()
    }
    
    // Award points for completing a task
    func awardPointsForTask(_ task: Task) {
        let pointsAwarded = task.potentialPoints
        let oldLevel = userPoints.level
        
        userPoints.awardPoints(pointsAwarded, reason: "Completed: \(task.title)", taskId: task.id)
        lastAwardedPoints = pointsAwarded
        
        // Check if level increased
        if userPoints.level > oldLevel {
            showLevelUpCelebration()
        } else {
            showPointsCelebration()
        }
        
        savePoints()
    }
    
    // Award bonus points
    func awardBonusPoints(_ points: Int, reason: String) {
        let oldLevel = userPoints.level
        
        userPoints.awardPoints(points, reason: reason)
        lastAwardedPoints = points
        
        if userPoints.level > oldLevel {
            showLevelUpCelebration()
        } else {
            showPointsCelebration()
        }
        
        savePoints()
    }
    
    // Show points celebration animation
    private func showPointsCelebration() {
        showCelebration = true
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showCelebration = false
        }
    }
    
    // Show level up celebration
    private func showLevelUpCelebration() {
        showCelebration = true
        
        // Auto-hide after 3 seconds for level up
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCelebration = false
        }
    }
    
    // Get current total points
    var totalPoints: Int {
        return userPoints.totalPoints
    }
    
    // Get current level
    var currentLevel: Int {
        return userPoints.level
    }
    
    // Get daily points
    var dailyPoints: Int {
        return userPoints.dailyPoints
    }
    
    // Get level progress percentage
    var levelProgress: Double {
        return userPoints.levelProgress
    }
    
    // Get points needed for next level
    var pointsForNextLevel: Int {
        return userPoints.pointsForNextLevel
    }
    
    // Reset all points (for testing)
    func resetPoints() {
        userPoints = UserPoints()
        savePoints()
    }
}
