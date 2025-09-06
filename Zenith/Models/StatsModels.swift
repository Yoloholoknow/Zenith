//
//  StatsModels.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import SwiftUI

enum StatTimeframe: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
}

struct CategoryStat {
    let category: String
    let completedTasks: Int
    let totalTasks: Int
    let percentage: Double
    let color: Color
}

struct WeeklyProgress {
    let weekStart: Date
    let totalTasks: Int
    let completedTasks: Int
    let completionRate: Double
}

enum ProductivityTrend {
    case improving
    case stable
    case declining
    
    var description: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        }
    }
    
    var color: Color {
        switch self {
        case .improving: return ThemeColors.successGreen
        case .stable: return ThemeColors.primaryBlue
        case .declining: return ThemeColors.warningOrange
        }
    }
}

struct CategoryTrend {
    let category: String
    let currentRate: Double
    let previousRate: Double
    let change: Double
    let isImproving: Bool
}

struct DetailedCategoryAnalysis {
    let category: TaskCategory
    let totalTasks: Int
    let completedTasks: Int
    let completionRate: Double
    let averageCompletionTime: TimeInterval
    let currentStreak: Int
    let productivityTrend: ProductivityTrend
    let lastActivity: Date
    let bestDay: Date?
}
