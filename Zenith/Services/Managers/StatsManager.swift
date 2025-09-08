//  StatsManager.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import Foundation
import SwiftUI
import Combine

class StatsManager: ObservableObject {
    @Published var currentStats: [CategoryStat] = []
    @Published var radarData: [RadarDataPoint] = []
    @Published var overallScore: Double = 0.0
    @Published var trends: [CategoryTrend] = []
    
    private let dataManager = DataManager.shared
    private let calculator = StatsDataCalculator.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        updateStats()
        setupDataBinding()
    }
    
    private func setupDataBinding() {
        // Update stats when tasks change
        NotificationCenter.default.publisher(for: .tasksUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
    }
    
    func updateStats() {
        let tasks = dataManager.loadAllTasks() // UPDATED: Load all tasks
        updateStatsForTasks(tasks)
    }
    
    private func updateStatsForTasks(_ tasks: [Task]) {
        // Calculate current week stats by default
        currentStats = calculator.calculateCategoryStats(from: tasks, timeframe: .week)
        radarData = calculator.calculateRadarData(from: tasks, timeframe: .week)
        overallScore = calculator.calculateOverallScore(from: tasks, timeframe: .week)
        trends = calculator.calculateTrends(from: tasks)
        
        print("📊 Updated stats: \(currentStats.count) categories, overall score: \(String(format: "%.1f%%", overallScore * 100))")
    }
    
    func getRadarData(for timeframe: StatTimeframe) -> [RadarDataPoint] {
        let tasks = dataManager.loadAllTasks() // UPDATED: Load all tasks
        return calculator.calculateRadarData(from: tasks, timeframe: timeframe)
    }
    
    func getDetailedStats(for timeframe: StatTimeframe) -> [CategoryStat] {
        let tasks = dataManager.loadAllTasks() // UPDATED: Load all tasks
        return calculator.calculateCategoryStats(from: tasks, timeframe: timeframe)
    }
    
    func getInsights(for timeframe: StatTimeframe) -> [String]? {
        let tasks = dataManager.loadAllTasks() // UPDATED: Load all tasks
        let insights = calculator.generateInsights(from: tasks, timeframe: timeframe)
        return insights.isEmpty ? nil : insights
    }
    
    func getOverallScore(for timeframe: StatTimeframe) -> Double {
        let tasks = dataManager.loadAllTasks() // UPDATED: Load all tasks
        return calculator.calculateOverallScore(from: tasks, timeframe: timeframe)
    }
    
    func getTrends() -> [CategoryTrend] {
        return trends
    }
    
    // MARK: - Summary Methods
    
    func getSummaryText(for timeframe: StatTimeframe) -> String {
        let score = getOverallScore(for: timeframe)
        let percentage = Int(score * 100)
        
        switch score {
        case 0.8...1.0:
            return "Excellent performance at \(percentage)%"
        case 0.6..<0.8:
            return "Good progress at \(percentage)%"
        case 0.4..<0.6:
            return "Building momentum at \(percentage)%"
        case 0.1..<0.4:
            return "Getting started at \(percentage)%"
        default:
            return "Ready to begin your journey"
        }
    }
    
    func getTopCategory(for timeframe: StatTimeframe) -> String? {
        let stats = getDetailedStats(for: timeframe)
        return stats.first?.category
    }
    
    func getNeedsImprovementCategory(for timeframe: StatTimeframe) -> String? {
        let stats = getDetailedStats(for: timeframe)
        return stats.last?.category
    }
}

// Notification for data updates
extension Notification.Name {
    static let tasksUpdated = Notification.Name("tasksUpdated")
}

//#Preview {
//    StatsManager()
//}
