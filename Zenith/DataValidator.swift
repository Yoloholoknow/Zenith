//
//  DataValidator.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation

class DataValidator {
    static let shared = DataValidator()
    
    private init() {}
    
    // MARK: - Task Validation
    
    func validateTasks(_ tasks: [Task]) throws -> [Task] {
        var validatedTasks: [Task] = []
        var errors: [ValidationError] = []
        
        for task in tasks {
            do {
                let validatedTask = try validateTask(task)
                validatedTasks.append(validatedTask)
            } catch let error as ValidationError {
                errors.append(error)
                // Create a corrected version of the task
                if let correctedTask = attemptTaskRepair(task) {
                    validatedTasks.append(correctedTask)
                }
            }
        }
        
        if !errors.isEmpty {
            print("⚠️ Task validation found \(errors.count) issues")
            for error in errors {
                print("  - \(error.description)")
            }
        }
        
        return validatedTasks
    }
    
    private func validateTask(_ task: Task) throws -> Task {
        // Check required fields
        if task.title.isEmpty {
            throw ValidationError.missingRequiredFields("Task title is empty")
        }
        
        // Validate dates
        if task.createdDate > Date() {
            throw ValidationError.invalidDateRange("Task created in future: \(task.title)")
        }
        
        if let completedDate = task.completedDate {
            if completedDate < task.createdDate {
                throw ValidationError.invalidDateRange("Completed before created: \(task.title)")
            }
            if completedDate > Date() {
                throw ValidationError.invalidDateRange("Completed in future: \(task.title)")
            }
        }
        
        // Check consistency
        if task.isCompleted && task.completedDate == nil {
            throw ValidationError.inconsistentData("Task marked complete but no completion date: \(task.title)")
        }
        
        if !task.isCompleted && task.completedDate != nil {
            throw ValidationError.inconsistentData("Task not complete but has completion date: \(task.title)")
        }
        
        // Validate points
        if task.pointsEarned < 0 {
            throw ValidationError.negativeValues("Negative points earned: \(task.title)")
        }
        
        return task
    }
    
    private func attemptTaskRepair(_ task: Task) -> Task? {
        var repairedTask = task
        
        // Fix empty title
        if repairedTask.title.isEmpty {
            repairedTask.title = "Untitled Task"
        }
        
        // Fix future created date
        if repairedTask.createdDate > Date() {
            repairedTask.createdDate = Date()
        }
        
        // Fix completion consistency
        if repairedTask.isCompleted && repairedTask.completedDate == nil {
            repairedTask.completedDate = repairedTask.createdDate
        }
        
        if !repairedTask.isCompleted && repairedTask.completedDate != nil {
            repairedTask.completedDate = nil
            repairedTask.pointsEarned = 0
        }
        
        // Fix negative points
        if repairedTask.pointsEarned < 0 {
            repairedTask.pointsEarned = 0
        }
        
        return repairedTask
    }
    
    // MARK: - Streak Validation
    
    func validateStreak(_ streak: Streak) throws -> Streak {
        var validatedStreak = streak
        
        // Check for negative values
        if streak.currentStreak < 0 {
            print("⚠️ Fixing negative current streak: \(streak.currentStreak)")
            validatedStreak.currentStreak = 0
        }
        
        if streak.bestStreak < 0 {
            print("⚠️ Fixing negative best streak: \(streak.bestStreak)")
            validatedStreak.bestStreak = 0
        }
        
        if streak.totalDaysCompleted < 0 {
            print("⚠️ Fixing negative total days: \(streak.totalDaysCompleted)")
            validatedStreak.totalDaysCompleted = 0
        }
        
        // Check consistency
        if streak.currentStreak > streak.bestStreak {
            print("⚠️ Current streak exceeds best streak, adjusting")
            validatedStreak.bestStreak = streak.currentStreak
        }
        
        // Validate dates
        if let lastCompletion = streak.lastCompletionDate,
           lastCompletion > Date() {
            print("⚠️ Last completion date in future, resetting")
            validatedStreak.lastCompletionDate = nil
            validatedStreak.currentStreak = 0
        }
        
        if let streakStart = streak.streakStartDate,
           streakStart > Date() {
            print("⚠️ Streak start date in future, resetting")
            validatedStreak.streakStartDate = nil
        }
        
        return validatedStreak
    }
    
    // MARK: - Points Validation
    
    func validatePoints(_ points: UserPoints) throws -> UserPoints {
        var validatedPoints = points
        
        // Check for negative values
        if points.totalPoints < 0 {
            print("⚠️ Fixing negative total points: \(points.totalPoints)")
            validatedPoints.totalPoints = 0
        }
        
        if points.dailyPoints < 0 {
            print("⚠️ Fixing negative daily points: \(points.dailyPoints)")
            validatedPoints.dailyPoints = 0
        }
        
        if points.level < 1 {
            print("⚠️ Fixing invalid level: \(points.level)")
            validatedPoints.level = 1
        }
        
        // Validate level consistency
        let expectedLevel = (points.totalPoints / 100) + 1
        if points.level != expectedLevel {
            print("⚠️ Level inconsistent with points, correcting: \(points.level) -> \(expectedLevel)")
            validatedPoints.level = expectedLevel
        }
        
        // Check date consistency
        if points.lastResetDate > Date() {
            print("⚠️ Last reset date in future, correcting")
            validatedPoints.lastResetDate = Date()
        }
        
        // Validate point history
        let validHistory = points.pointHistory.filter { transaction in
            transaction.points >= 0 && transaction.date <= Date()
        }
        
        if validHistory.count != points.pointHistory.count {
            print("⚠️ Removed \(points.pointHistory.count - validHistory.count) invalid transactions")
            validatedPoints.pointHistory = validHistory
        }
        
        return validatedPoints
    }
}
