//  UserPoints.swift
//  Zenith
//
//  Created by Charles Huang on 9/4/25.
//

import Foundation

struct PointTransaction: Codable, Identifiable {
    var id = UUID()
    let points: Int
    let reason: String
    let date: Date
    let taskId: UUID?

    init(points: Int, reason: String, taskId: UUID? = nil) {
        self.points = points
        self.reason = reason
        self.date = Date()
        self.taskId = taskId
    }
}

struct UserPoints: Codable {
    var totalPoints: Int = 0
    var dailyPoints: Int = 0
    var lastResetDate: Date = Date()
    var pointHistory: [PointTransaction] = []
    var level: Int = 1

    // Points needed for next level (exponential growth)
    var pointsForNextLevel: Int {
        return level * 100
    }

    // Progress toward next level as percentage
    var levelProgress: Double {
        let pointsInCurrentLevel = totalPoints % pointsForNextLevel
        return Double(pointsInCurrentLevel) / Double(pointsForNextLevel)
    }

    // Award points and update level
    mutating func awardPoints(_ points: Int, reason: String, taskId: UUID? = nil) {
        totalPoints += points
        dailyPoints += points

        // Add to history
        let transaction = PointTransaction(points: points, reason: reason, taskId: taskId)
        pointHistory.append(transaction)

        // Update level if necessary
        updateLevel()
    }

    // ADDED: The `updateLevel` function is now accessible.
    mutating func updateLevel() {
        let newLevel = (totalPoints / 100) + 1
        if newLevel > level {
            level = newLevel
        }
    }

    // Reset daily points (call at start of new day)
    mutating func resetDailyPoints() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastReset = calendar.startOfDay(for: lastResetDate)

        if !calendar.isDate(today, inSameDayAs: lastReset) {
            dailyPoints = 0
            lastResetDate = Date()
        }
    }

    // Get recent transactions (last 10)
    var recentTransactions: [PointTransaction] {
        return Array(pointHistory.suffix(10).reversed())
    }
}
