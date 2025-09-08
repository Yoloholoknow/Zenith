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

    // ADDED: Published properties to hold active and archived tasks
    @Published var tasks: [Task] = []
    @Published var archivedTasks: [Task] = []

    private let userDefaults = UserDefaults.standard

    // UserDefaults keys
    private let tasksKey = "saved_tasks"
    private let archivedTasksKey = "archived_tasks"
    private let streakKey = "user_streak_data"
    private let pointsKey = "user_points_data"
    private let lastSaveKey = "last_save_date"
    private let preferencesKey = "user_preferences"

    private init() {
        // Private initializer for singleton pattern
        loadAllData()
    }

    // ADDED: A new function to load all data at once
    private func loadAllData() {
        tasks = loadTasksWithValidation()
        archivedTasks = loadArchivedTasks()
    }

    // MARK: - Task Management

    func saveTasks(_ tasks: [Task]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            userDefaults.set(data, forKey: tasksKey)
            updateLastSaveDate()
            self.tasks = tasks
            NotificationCenter.default.post(name: .tasksUpdated, object: nil)
            print("✅ Tasks saved: \(tasks.count) tasks")
        } catch {
            print("❌ Failed to save tasks: \(error.localizedDescription)")
        }
    }

    func loadTasksWithValidation() -> [Task] {
        print("📝 Loading tasks with validation...")
        
        guard let data = userDefaults.data(forKey: tasksKey) else {
            print("📝 No saved tasks found, returning empty array")
            return []
        }
        
        do {
            let loadedTasks = try JSONDecoder().decode([Task].self, from: data)
            print("📝 Loaded \(loadedTasks.count) tasks from storage")
            
            let validatedTasks = try DataValidator.shared.validateTasks(loadedTasks)
            
            if validatedTasks.count != loadedTasks.count {
                print("📝 Validation corrected tasks, saving updated data")
                saveTasks(validatedTasks)
            }
            
            print("✅ Tasks validation completed: \(validatedTasks.count) valid tasks")
            return validatedTasks
            
        } catch let decodingError {
            print("❌ Failed to decode tasks: \(decodingError.localizedDescription)")
            
            if let backupTasks = attemptTaskBackupRestore() {
                print("🔄 Restored \(backupTasks.count) tasks from backup")
                return backupTasks
            }
            
            print("🔄 Falling back to empty tasks array")
            return []
        }
    }

    // Changed from private to internal
    func loadTasks() -> [Task] {
        guard let data = userDefaults.data(forKey: tasksKey),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }

    // MARK: - Archived Task Management

    func archiveTask(_ task: Task) {
       var completedTask = task
       completedTask.isCompleted = true
       completedTask.completedDate = Date()
       archivedTasks.append(completedTask) // UPDATED: Directly append to published property
       
       do {
           let data = try JSONEncoder().encode(archivedTasks)
           userDefaults.set(data, forKey: archivedTasksKey)
           updateLastSaveDate()
           print("✅ Task archived: \(task.title)")
       } catch {
           print("❌ Failed to archive task: \(error.localizedDescription)")
       }
   }
   
   func loadArchivedTasks() -> [Task] {
       guard let data = userDefaults.data(forKey: archivedTasksKey),
             let archivedTasks = try? JSONDecoder().decode([Task].self, from: data) else {
           return []
       }
       return archivedTasks
   }
   
   func unarchiveTask(_ task: Task) {
       if let index = archivedTasks.firstIndex(where: { $0.id == task.id }) {
           let unarchivedTask = archivedTasks.remove(at: index) // UPDATED: Remove from published property
           do {
               let data = try JSONEncoder().encode(archivedTasks)
               userDefaults.set(data, forKey: archivedTasksKey)
               
               // Add to active tasks and save
               var tasksToSave = tasks // UPDATED: Use the published property
               var newTask = unarchivedTask
               newTask.isCompleted = false
               newTask.completedDate = nil
               tasksToSave.append(newTask)
               saveTasks(tasksToSave) // UPDATED: saveTasks now handles the published property update
               
               print("✅ Task unarchived: \(task.title)")
               
           } catch {
               print("❌ Failed to un-archive task: \(error.localizedDescription)")
           }
       }
   }
    
    func loadAllTasks() -> [Task] {
        let activeTasks = loadTasks()
        let archivedTasks = loadArchivedTasks()
        return activeTasks + archivedTasks
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
            
            let validatedStreak = try DataValidator.shared.validateStreak(streak)
            
            if validatedStreak.currentStreak != streak.currentStreak ||
               validatedStreak.bestStreak != streak.bestStreak {
                print("🔥 Validation corrected streak, saving updated data")
                saveStreak(validatedStreak)
            }
            
            print("✅ Streak validation completed: \(validatedStreak.currentStreak) days")
            return validatedStreak
            
        } catch let decodingError {
            print("❌ Failed to decode streak: \(decodingError.localizedDescription)")
            
            if let backupStreak = attemptStreakBackupRestore() {
                print("🔄 Restored streak from backup: \(backupStreak.currentStreak) days")
                return backupStreak
            }
            
            print("🔄 Falling back to new streak")
            let newStreak = Streak()
            saveStreak(newStreak)
            return newStreak
        }
    }
    
    // Private method to load streak without validation
    func loadStreak() -> Streak {
        guard let data = userDefaults.data(forKey: streakKey),
              let streak = try? JSONDecoder().decode(Streak.self, from: data) else {
            return Streak()
        }
        return streak
    }
    
    private func attemptTaskBackupRestore() -> [Task]? {
        guard let data = userDefaults.data(forKey: "app_data_backup"),
              let backup = try? JSONDecoder().decode(AppDataBackup.self, from: data) else {
            return nil
        }
        return backup.tasks
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
            
            let validatedPoints = try DataValidator.shared.validatePoints(points)
            
            if validatedPoints.totalPoints != points.totalPoints ||
               validatedPoints.level != points.level {
                print("🏆 Validation corrected points, saving updated data")
                savePoints(validatedPoints)
            }
            
            print("✅ Points validation completed: \(validatedPoints.totalPoints) total")
            return validatedPoints
            
        } catch let decodingError {
            print("❌ Failed to decode points: \(decodingError.localizedDescription)")
            
            if let backupPoints = attemptPointsBackupRestore() {
                print("🔄 Restored points from backup: \(backupPoints.totalPoints) total")
                return backupPoints
            }
            
            print("🔄 Falling back to new points record")
            let newPoints = UserPoints()
            savePoints(newPoints)
            return newPoints
        }
    }
    
    // Private method to load points without validation
    func loadPoints() -> UserPoints {
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
    
    // Add the new clearPreferences function
    func clearPreferences() {
        userDefaults.removeObject(forKey: preferencesKey)
        print("🗑️ User preferences cleared")
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.removeObject(forKey: archivedTasksKey)
        userDefaults.removeObject(forKey: streakKey)
        userDefaults.removeObject(forKey: pointsKey)
        userDefaults.removeObject(forKey: lastSaveKey)
        clearPreferences()
        print("🗑️ All data cleared")
    }
    
    func hasExistingData() -> Bool {
        return userDefaults.data(forKey: tasksKey) != nil ||
        userDefaults.data(forKey: archivedTasksKey) != nil ||
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
