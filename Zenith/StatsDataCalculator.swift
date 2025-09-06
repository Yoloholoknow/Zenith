//
//  StatsDataCalculator.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import SwiftUI

class StatsDataCalculator {
    static let shared = StatsDataCalculator()
    
    private init() {}
    
    // MARK: - Task Analysis
    
    func calculateCategoryStats(from tasks: [Task], timeframe: StatTimeframe) -> [CategoryStat] {
        let filteredTasks = getTasksForTimeframe(tasks: tasks, timeframe: timeframe)
        
        return TaskCategory.allCases.compactMap { category in
            let categoryTasks = filteredTasks.filter { $0.category == category }
            guard !categoryTasks.isEmpty else { return nil }
            
            let completedTasks = categoryTasks.filter { $0.isCompleted }
            let percentage = Double(completedTasks.count) / Double(categoryTasks.count)
            
            return CategoryStat(
                category: category.rawValue,
                completedTasks: completedTasks.count,
                totalTasks: categoryTasks.count,
                percentage: percentage,
                color: getColorForCategory(category)
            )
        }
        .sorted { $0.percentage > $1.percentage }
    }
    
    func calculateRadarData(from tasks: [Task], timeframe: StatTimeframe) -> [RadarDataPoint] {
        let stats = calculateCategoryStats(from: tasks, timeframe: timeframe)
        
        return stats.map { stat in
            RadarDataPoint(
                label: shortenCategoryLabel(stat.category),
                value: stat.percentage,
                color: stat.color
            )
        }
    }
    
    func calculateOverallScore(from tasks: [Task], timeframe: StatTimeframe) -> Double {
        let stats = calculateCategoryStats(from: tasks, timeframe: timeframe)
        guard !stats.isEmpty else { return 0.0 }
        
        let totalPercentage = stats.reduce(0) { $0 + $1.percentage }
        return totalPercentage / Double(stats.count)
    }
    
    // MARK: - Insights Generation
    
    func generateInsights(from tasks: [Task], timeframe: StatTimeframe) -> [String] {
        let stats = calculateCategoryStats(from: tasks, timeframe: timeframe)
        var insights: [String] = []
        
        guard !stats.isEmpty else {
            insights.append("Start completing tasks to see your growth patterns")
            return insights
        }
        
        // Best performing category
        if let bestCategory = stats.first {
            let percentage = Int(bestCategory.percentage * 100)
            insights.append("🏆 \(bestCategory.category) is your strongest area at \(percentage)% completion")
        }
        
        // Areas needing attention
        let strugglingAreas = stats.filter { $0.percentage < 0.4 && $0.totalTasks >= 2 }
        if !strugglingAreas.isEmpty {
            let category = strugglingAreas.first!.category
            insights.append("⚠️ Focus on \(category) - you have room to grow in this area")
        }
        
        // Balanced growth recognition
        let balancedAreas = stats.filter { $0.percentage >= 0.6 }.count
        if balancedAreas >= 3 {
            insights.append("✨ Great balance! You're performing well across multiple areas")
        }
        
        // Consistency check
        let overallScore = calculateOverallScore(from: tasks, timeframe: timeframe)
        if overallScore >= 0.8 {
            insights.append("🚀 Excellent consistency! Keep up the amazing work")
        } else if overallScore >= 0.6 {
            insights.append("📈 Good progress! Small improvements will make a big difference")
        } else if overallScore > 0 {
            insights.append("🌱 Every completed task is progress - keep building momentum")
        }
        
        return insights
    }
    
    // MARK: - Trend Analysis
    
    func calculateTrends(from tasks: [Task]) -> [CategoryTrend] {
        let thisWeek = getTasksForTimeframe(tasks: tasks, timeframe: .week)
        let lastWeek = getTasksForPreviousTimeframe(tasks: tasks, timeframe: .week)
        
        return TaskCategory.allCases.compactMap { category in
            let thisWeekTasks = thisWeek.filter { $0.category == category }
            let lastWeekTasks = lastWeek.filter { $0.category == category }
            
            guard !thisWeekTasks.isEmpty || !lastWeekTasks.isEmpty else { return nil }
            
            let thisWeekRate = thisWeekTasks.isEmpty ? 0.0 : Double(thisWeekTasks.filter { $0.isCompleted }.count) / Double(thisWeekTasks.count)
            let lastWeekRate = lastWeekTasks.isEmpty ? 0.0 : Double(lastWeekTasks.filter { $0.isCompleted }.count) / Double(lastWeekTasks.count)
            
            let change = thisWeekRate - lastWeekRate
            
            return CategoryTrend(
                category: category.rawValue,
                currentRate: thisWeekRate,
                previousRate: lastWeekRate,
                change: change,
                isImproving: change > 0.1
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTasksForTimeframe(tasks: [Task], timeframe: StatTimeframe) -> [Task] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeframe {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .quarter:
            startDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return tasks.filter { $0.createdDate >= startDate }
    }
    
    private func getTasksForPreviousTimeframe(tasks: [Task], timeframe: StatTimeframe) -> [Task] {
        let calendar = Calendar.current
        let now = Date()
        
        let endDate: Date
        let startDate: Date
        
        switch timeframe {
        case .week:
            endDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            startDate = calendar.date(byAdding: .weekOfYear, value: -2, to: now) ?? now
        case .month:
            endDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            startDate = calendar.date(byAdding: .month, value: -2, to: now) ?? now
        case .quarter:
            endDate = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            startDate = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        }
        
        return tasks.filter { $0.createdDate >= startDate && $0.createdDate < endDate }
    }
    
    private func getColorForCategory(_ category: TaskCategory) -> Color {
        switch category {
        case .work:
            return ThemeColors.primaryBlue
        case .health:
            return ThemeColors.successGreen
        case .personal:
            return ThemeColors.secondaryPurple
        case .learning:
            return ThemeColors.warningOrange
        case .social:
            return Color.pink
        case .finance:
            return ThemeColors.streakGold
        case .other:
            return Color.gray
        }
    }
    
    private func shortenCategoryLabel(_ category: String) -> String {
        switch category {
        case "Personal":
            return "Personal"
        case "Learning":
            return "Learning"
        default:
            return category
        }
    }
    
    // MARK: - Historical Data Tracking
    
    func getDetailedCategoryAnalysis(category: TaskCategory, from tasks: [Task], timeframe: StatTimeframe) -> DetailedCategoryAnalysis {
        let categoryTasks = tasks.filter { $0.category == category }
        let completedTasks = categoryTasks.filter { $0.isCompleted }
        
        let averageCompletionTime = calculateAverageCompletionTime(for: completedTasks)
        let completionStreak = calculateCategoryStreak(for: category, in: tasks)
        let productivityTrend = calculateProductivityTrend(for: category, in: tasks, timeframe: timeframe)
        
        return DetailedCategoryAnalysis(
            category: category,
            totalTasks: categoryTasks.count,
            completedTasks: completedTasks.count,
            completionRate: categoryTasks.isEmpty ? 0.0 : Double(completedTasks.count) / Double(categoryTasks.count),
            averageCompletionTime: averageCompletionTime,
            currentStreak: completionStreak,
            productivityTrend: productivityTrend,
            lastActivity: categoryTasks.last?.createdDate ?? Date.distantPast,
            bestDay: findBestPerformanceDay(for: category, in: completedTasks)
        )
    }
    
    func getWeeklyProgressData(for category: TaskCategory, from tasks: [Task]) -> [WeeklyProgress] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [WeeklyProgress] = []
        
        // Get last 8 weeks of data
        for week in 0..<8 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -week, to: now) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            
            let weekTasks = tasks.filter { task in
                task.category == category &&
                task.createdDate >= weekStart &&
                task.createdDate <= weekEnd
            }
            
            let completedCount = weekTasks.filter { $0.isCompleted }.count
            let completionRate = weekTasks.isEmpty ? 0.0 : Double(completedCount) / Double(weekTasks.count)
            
            weeklyData.append(WeeklyProgress(
                weekStart: weekStart,
                totalTasks: weekTasks.count,
                completedTasks: completedCount,
                completionRate: completionRate
            ))
        }
        
        return weeklyData.reversed() // Return chronological order
    }
    
    private func calculateAverageCompletionTime(for tasks: [Task]) -> TimeInterval {
        let completionTimes = tasks.compactMap { task -> TimeInterval? in
            guard let completedDate = task.completedDate else { return nil }
            return completedDate.timeIntervalSince(task.createdDate)
        }
        
        guard !completionTimes.isEmpty else { return 0 }
        return completionTimes.reduce(0, +) / Double(completionTimes.count)
    }
    
    private func calculateCategoryStreak(for category: TaskCategory, in tasks: [Task]) -> Int {
        let calendar = Calendar.current
        let categoryTasks = tasks.filter { $0.category == category }
            .sorted { $0.createdDate > $1.createdDate }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while streak < 30 { // Max 30 day lookback
            let dayTasks = categoryTasks.filter { calendar.isDate($0.createdDate, inSameDayAs: currentDate) }
            let hasCompletedTask = dayTasks.contains { $0.isCompleted }
            
            if hasCompletedTask {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if !dayTasks.isEmpty {
                break // Had tasks but didn't complete any
            } else {
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            }
        }
        
        return streak
    }
    
    private func calculateProductivityTrend(for category: TaskCategory, in tasks: [Task], timeframe: StatTimeframe) -> ProductivityTrend {
        let recent = getTasksForTimeframe(tasks: tasks, timeframe: timeframe).filter { $0.category == category }
        let previous = getTasksForPreviousTimeframe(tasks: tasks, timeframe: timeframe).filter { $0.category == category }
        
        let recentRate = recent.isEmpty ? 0.0 : Double(recent.filter { $0.isCompleted }.count) / Double(recent.count)
        let previousRate = previous.isEmpty ? 0.0 : Double(previous.filter { $0.isCompleted }.count) / Double(previous.count)
        
        let change = recentRate - previousRate
        
        if change > 0.15 {
            return .improving
        } else if change < -0.15 {
            return .declining
        } else {
            return .stable
        }
    }
    
    private func findBestPerformanceDay(for category: TaskCategory, in tasks: [Task]) -> Date? {
        let calendar = Calendar.current
        var dayPerformance: [Date: Double] = [:]
        
        // Group tasks by day
        for task in tasks {
            let day = calendar.startOfDay(for: task.createdDate)
            if dayPerformance[day] == nil {
                dayPerformance[day] = 0
            }
            
            if task.isCompleted {
                dayPerformance[day]! += 1
            }
        }
        
        return dayPerformance.max(by: { $0.value < $1.value })?.key
    }
}
