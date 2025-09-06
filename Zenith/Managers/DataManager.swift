//
//  DataManager.swift
//  Zenith
//
//  Created by Charles Huang on 9/5/25.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    // UserDefaults keys
    private let tasksKey = "saved_tasks"
    private let streakKey = "user_streak_data"
    private let pointsKey = "user_points_data"
    private let lastSaveKey = "last_save_date"
    
    private init() {
        // Private initializer for singleton pattern
    }
    
    // MARK: - Task Management
    
    func saveTasks(_ tasks: [Task]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
            updateLastSaveDate()
            print("✅ Tasks saved: \(tasks.count) tasks")
        } catch {
            print("❌ Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = userDefaults.data(forKey: tasksKey) else {
            print("📝 No saved tasks found, returning sample tasks")
            return Task.sampleTasks()
        }
        
        do {
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            print("✅ Tasks loaded: \(tasks.count) tasks")
            return tasks
        } catch {
            print("❌ Failed to load tasks: \(error.localizedDescription)")
            return Task.sampleTasks()
        }
    }
    
    // MARK: - Streak Management
    
    func saveStreak(_ streak: Streak) {
        do {
            let data = try JSONEncoder().encode(streak)
            userDefaults.set(data, forKey: streakKey)
            updateLastSaveDate()
            print("✅ Streak saved: \(streak.currentStreak) day streak")
        } catch {
            print("❌ Failed to save streak: \(error.localizedDescription)")
        }
    }
    
    func loadStreak() -> Streak {
        guard let data = userDefaults.data(forKey: streakKey) else {
            print("🔥 No saved streak found, creating new streak")
            return Streak()
        }
        
        do {
            let streak = try JSONDecoder().decode(Streak.self, from: data)
            print("✅ Streak loaded: \(streak.currentStreak) day streak")
            return streak
        } catch {
            print("❌ Failed to load streak: \(error.localizedDescription)")
            return Streak()
        }
    }
    
    // MARK: - Points Management
    
    func savePoints(_ points: UserPoints) {
        do {
            let data = try JSONEncoder().encode(points)
            userDefaults.set(data, forKey: pointsKey)
            updateLastSaveDate()
            print("✅ Points saved: \(points.totalPoints) total points, Level \(points.level)")
        } catch {
            print("❌ Failed to save points: \(error.localizedDescription)")
        }
    }
    
    func loadPoints() -> UserPoints {
        guard let data = userDefaults.data(forKey: pointsKey) else {
            print("🏆 No saved points found, creating new points record")
            return UserPoints()
        }
        
        do {
            let points = try JSONDecoder().decode(UserPoints.self, from: data)
            print("✅ Points loaded: \(points.totalPoints) total points, Level \(points.level)")
            return points
        } catch {
            print("❌ Failed to load points: \(error.localizedDescription)")
            return UserPoints()
        }
    }
    
    // MARK: - Utility Methods
    
    private func updateLastSaveDate() {
        userDefaults.set(Date(), forKey: lastSaveKey)
    }
    
    func getLastSaveDate() -> Date? {
        return userDefaults.object(forKey: lastSaveKey) as? Date
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.removeObject(forKey: streakKey)
        userDefaults.removeObject(forKey: pointsKey)
        userDefaults.removeObject(forKey: lastSaveKey)
        print("🗑️ All data cleared")
    }
    
    func hasExistingData() -> Bool {
        return userDefaults.data(forKey: tasksKey) != nil ||
               userDefaults.data(forKey: streakKey) != nil ||
               userDefaults.data(forKey: pointsKey) != nil
    }
    
    // MARK: - Data Validation and Backup
    
    func validateAndRepairData() -> Bool {
        var hasIssues = false
        
        // Validate tasks
        let tasks = loadTasks()
        let validTasks = tasks.filter { task in
            !task.title.isEmpty && task.createdDate <= Date()
        }
        
        if validTasks.count != tasks.count {
            print("⚠️ Found \(tasks.count - validTasks.count) invalid tasks, cleaning up")
            saveTasks(validTasks)
            hasIssues = true
        }
        
        // Validate points
        let points = loadPoints()
        if points.totalPoints < 0 || points.level < 1 {
            print("⚠️ Found invalid points data, resetting")
            let repairedPoints = UserPoints()
            savePoints(repairedPoints)
            hasIssues = true
        }
        
        // Validate streak
        let streak = loadStreak()
        if streak.currentStreak < 0 || streak.bestStreak < streak.currentStreak {
            print("⚠️ Found invalid streak data, repairing")
            var repairedStreak = streak
            repairedStreak.currentStreak = max(0, streak.currentStreak)
            repairedStreak.bestStreak = max(streak.bestStreak, streak.currentStreak)
            saveStreak(repairedStreak)
            hasIssues = true
        }
        
        if !hasIssues {
            print("✅ Data validation passed")
        }
        
        return !hasIssues
    }
    
    func createBackup() -> Bool {
        do {
            let backup = AppDataBackup(
                tasks: loadTasks(),
                streak: loadStreak(),
                points: loadPoints(),
                backupDate: Date()
            )
            
            let data = try JSONEncoder().encode(backup)
            userDefaults.set(data, forKey: "app_data_backup")
            print("✅ Backup created successfully")
            return true
        } catch {
            print("❌ Failed to create backup: \(error.localizedDescription)")
            return false
        }
    }
    
    func restoreFromBackup() -> Bool {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            print("❌ No backup found or backup corrupted")
            return false
        }
        
        // Restore data from backup
        saveTasks(backup.tasks)
        saveStreak(backup.streak)
        savePoints(backup.points)
        
        print("✅ Data restored from backup (created: \(backup.backupDate))")
        return true
    }
    
    func getBackupInfo() -> (exists: Bool, date: Date?) {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            return (false, nil)
        }
        return (true, backup.backupDate)
    }
    
    func exportDataSummary() -> String {
        let tasks = loadTasks()
        let streak = loadStreak()
        let points = loadPoints()
        
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let totalTasks = tasks.count
        
        return """
        📊 GrowthDash Data Summary
        
        📝 Tasks: \(completedTasks)/\(totalTasks) completed
        🔥 Streak: \(streak.currentStreak) days (best: \(streak.bestStreak))
        🏆 Points: \(points.totalPoints) total (Level \(points.level))
        📅 Total days active: \(streak.totalDaysCompleted)
        
        Last updated: \(getLastSaveDate()?.formatted() ?? "Never")
        """
    }
    
}

struct AppDataBackup: Codable {
    let tasks: [Task]
    let streak: Streak
    let points: UserPoints
    let backupDate: Date
}
