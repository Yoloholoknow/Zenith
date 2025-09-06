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
    
    func loadTasksWithValidation() -> [Task] {
        print("📝 Loading tasks with validation...")
        
        guard let data = userDefaults.data(forKey: tasksKey) else {
            print("📝 No saved tasks found, returning sample tasks")
            let sampleTasks = Task.sampleTasks()
            saveTasks(sampleTasks) // Save sample tasks for future use
            return sampleTasks
        }
        
        do {
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            print("📝 Loaded \(tasks.count) tasks from storage")
            
            // Validate loaded tasks
            let validatedTasks = try DataValidator.shared.validateTasks(tasks)
            
            // If validation made changes, save the corrected data
            if validatedTasks.count != tasks.count {
                print("📝 Validation corrected tasks, saving updated data")
                saveTasks(validatedTasks)
            }
            
            print("✅ Tasks validation completed: \(validatedTasks.count) valid tasks")
            return validatedTasks
            
        } catch let decodingError {
            print("❌ Failed to decode tasks: \(decodingError.localizedDescription)")
            
            // Attempt to restore from backup
            if let backupTasks = attemptTaskBackupRestore() {
                print("🔄 Restored \(backupTasks.count) tasks from backup")
                return backupTasks
            }
            
            // Fall back to sample tasks
            print("🔄 Falling back to sample tasks")
            let sampleTasks = Task.sampleTasks()
            saveTasks(sampleTasks)
            return sampleTasks
        }
    }
    
    // Private method to load tasks without validation, used for internal checks
    private func loadTasks() -> [Task] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    private func attemptTaskBackupRestore() -> [Task]? {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            return nil
        }
        return backup.tasks
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
    
    func loadStreakWithValidation() -> Streak {
        print("🔥 Loading streak with validation...")
        
        guard let data = userDefaults.data(forKey: streakKey) else {
            print("🔥 No saved streak found, creating new streak")
            let newStreak = Streak()
            saveStreak(newStreak)
            return newStreak
        }
        
        do {
            let streak = try JSONDecoder().decode(Streak.self, from: data)
            print("🔥 Loaded streak from storage: \(streak.currentStreak) days")
            
            // Validate loaded streak
            let validatedStreak = try DataValidator.shared.validateStreak(streak)
            
            // If validation made changes, save the corrected data
            if validatedStreak.currentStreak != streak.currentStreak ||
               validatedStreak.bestStreak != streak.bestStreak {
                print("🔥 Validation corrected streak, saving updated data")
                saveStreak(validatedStreak)
            }
            
            print("✅ Streak validation completed: \(validatedStreak.currentStreak) days")
            return validatedStreak
            
        } catch let decodingError {
            print("❌ Failed to decode streak: \(decodingError.localizedDescription)")
            
            // Attempt backup restore
            if let backupStreak = attemptStreakBackupRestore() {
                print("🔄 Restored streak from backup: \(backupStreak.currentStreak) days")
                return backupStreak
            }
            
            // Fall back to new streak
            print("🔄 Falling back to new streak")
            let newStreak = Streak()
            saveStreak(newStreak)
            return newStreak
        }
    }
    
    // Private method to load streak without validation
    private func loadStreak() -> Streak {
        guard let data = userDefaults.data(forKey: streakKey),
              let streak = try? JSONDecoder().decode(Streak.self, from: data) else {
            return Streak()
        }
        return streak
    }
    
    private func attemptStreakBackupRestore() -> Streak? {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            return nil
        }
        return backup.streak
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
    
    func loadPointsWithValidation() -> UserPoints {
        print("🏆 Loading points with validation...")
        
        guard let data = userDefaults.data(forKey: pointsKey) else {
            print("🏆 No saved points found, creating new points record")
            let newPoints = UserPoints()
            savePoints(newPoints)
            return newPoints
        }
        
        do {
            let points = try JSONDecoder().decode(UserPoints.self, from: data)
            print("🏆 Loaded points from storage: \(points.totalPoints) total, Level \(points.level)")
            
            // Validate loaded points
            let validatedPoints = try DataValidator.shared.validatePoints(points)
            
            // If validation made changes, save the corrected data
            if validatedPoints.totalPoints != points.totalPoints ||
               validatedPoints.level != points.level {
                print("🏆 Validation corrected points, saving updated data")
                savePoints(validatedPoints)
            }
            
            print("✅ Points validation completed: \(validatedPoints.totalPoints) total")
            return validatedPoints
            
        } catch let decodingError {
            print("❌ Failed to decode points: \(decodingError.localizedDescription)")
            
            // Attempt backup restore
            if let backupPoints = attemptPointsBackupRestore() {
                print("🔄 Restored points from backup: \(backupPoints.totalPoints) total")
                return backupPoints
            }
            
            // Fall back to new points
            print("🔄 Falling back to new points record")
            let newPoints = UserPoints()
            savePoints(newPoints)
            return newPoints
        }
    }
    
    // Private method to load points without validation
    private func loadPoints() -> UserPoints {
        guard let data = userDefaults.data(forKey: pointsKey),
              let points = try? JSONDecoder().decode(UserPoints.self, from: data) else {
            return UserPoints()
        }
        return points
    }
    
    private func attemptPointsBackupRestore() -> UserPoints? {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            return nil
        }
        return backup.points
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
        
        let tasks = loadTasks()
        let validTasks = tasks.filter { task in
            !task.title.isEmpty && task.createdDate <= Date()
        }
        
        if validTasks.count != tasks.count {
            print("⚠️ Found \(tasks.count - validTasks.count) invalid tasks, cleaning up")
            saveTasks(validTasks)
            hasIssues = true
        }
        
        let points = loadPoints()
        if points.totalPoints < 0 || points.level < 1 {
            print("⚠️ Found invalid points data, resetting")
            let repairedPoints = UserPoints()
            savePoints(repairedPoints)
            hasIssues = true
        }
        
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
