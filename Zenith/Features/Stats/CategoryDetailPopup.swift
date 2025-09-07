//
//  CategoryDetailPopup.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct CategoryDetailPopup: View {
    let category: RadarDataPoint
    let categoryStats: CategoryStat
    let trends: CategoryTrend?
    let timeframe: StatTimeframe
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView { // Wrap the view in a NavigationView
            ScrollView {
                VStack(spacing: 20) {
                    // Performance Overview
                    VStack(spacing: 16) {
                        // Circular progress indicator
                        ZStack {
                            Circle()
                                .stroke(ThemeColors.textSecondary.opacity(0.3), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: categoryStats.percentage)
                                .stroke(category.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: categoryStats.percentage)
                            
                            VStack(spacing: 2) {
                                Text(String(format: "%.0f%%", categoryStats.percentage * 100))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(category.color)
                                
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                        }
                        
                        // Stats grid
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(categoryStats.completedTasks)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.successGreen)
                                Text("Completed")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Text("\(categoryStats.totalTasks)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.primaryBlue)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Text("\(categoryStats.totalTasks - categoryStats.completedTasks)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.warningOrange)
                                Text("Remaining")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(ThemeColors.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    // Progress Over Time Chart
                    VStack(alignment: .leading, spacing: 12) {
                        ProgressLineChart(
                            data: getProgressData(),
                            color: category.color
                        )
                    }
                    
                    // Trend information
                    if let trends = trends {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trend Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(ThemeColors.textPrimary)
                            
                            HStack {
                                Image(systemName: trends.isImproving ? "arrow.up.circle.fill" : trends.change < -0.1 ? "arrow.down.circle.fill" : "minus.circle.fill")
                                    .foregroundColor(trends.isImproving ? ThemeColors.successGreen : trends.change < -0.1 ? .red : ThemeColors.textSecondary)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(getTrendDescription(trends))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(ThemeColors.textPrimary)
                                    
                                    Text("Previous \(timeframe.rawValue.lowercased()): \(Int(trends.previousRate * 100))%")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(ThemeColors.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    // Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(getRecommendations(), id: \.self) { recommendation in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(ThemeColors.primaryBlue)
                                        .fontWeight(.bold)
                                    
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .foregroundColor(ThemeColors.textSecondary)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("\(category.label) Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func getProgressData() -> [WeeklyProgress] {
        let allTasks = DataManager.shared.loadTasks()
        let calculator = StatsDataCalculator.shared
        
        guard let taskCategory = TaskCategory(rawValue: category.label) else {
            return []
        }
        return calculator.getWeeklyProgressData(for: taskCategory, from: allTasks)
    }
    
    private func getTrendDescription(_ trends: CategoryTrend) -> String {
        let changePercentage = Int(abs(trends.change * 100))
        
        if trends.isImproving {
            return "Improving by \(changePercentage)%"
        } else if trends.change < -0.1 {
            return "Declined by \(changePercentage)%"
        } else {
            return "Staying consistent"
        }
    }
    
    private func getRecommendations() -> [String] {
        var recommendations: [String] = []
        
        if categoryStats.percentage < 0.3 {
            recommendations.append("Start small - focus on completing 1-2 \(category.label.lowercased()) tasks per day")
            recommendations.append("Break larger tasks into smaller, manageable steps")
            recommendations.append("Set a specific time each day for \(category.label.lowercased()) activities")
        } else if categoryStats.percentage < 0.6 {
            recommendations.append("You're making progress! Try to maintain consistency")
            recommendations.append("Consider increasing your \(category.label.lowercased()) task difficulty slightly")
            recommendations.append("Track what helps you succeed in this category")
        } else if categoryStats.percentage < 0.8 {
            recommendations.append("Great work! You're performing well in this area")
            recommendations.append("Consider helping others or sharing your success strategies")
            recommendations.append("Look for ways to optimize your \(category.label.lowercased()) routine")
        } else {
            recommendations.append("Excellent performance! You're mastering this area")
            recommendations.append("Consider taking on leadership or mentoring roles")
            recommendations.append("Explore advanced challenges in \(category.label.lowercased())")
        }
        
        return recommendations
    }
}
