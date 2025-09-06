//
//  StatsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI
import Combine

struct StatsView: View {
    @StateObject private var statsManager = StatsManager()
    @State private var selectedTimeframe: StatTimeframe = .week
    @State private var selectedCategory: RadarDataPoint?
    @State private var showingCategoryDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with real-time score
                    VStack(spacing: 8) {
                        Text("Personal Growth Stats")
                            .dashboardTitle()
                        
                        Text(statsManager.getSummaryText(for: selectedTimeframe))
                            .font(.headline)
                            .foregroundColor(ThemeColors.primaryBlue)
                        
                        Text(selectedCategory != nil ? "Tap chart areas for detailed insights" : "Real-time insights from your completed tasks")
                            .bodyText()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Overall Score Card
                    VStack(spacing: 12) {
                        HStack {
                            Text("📊")
                                .font(.title)
                            
                            Text("Overall Score")
                                .cardTitle()
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%%", statsManager.getOverallScore(for: selectedTimeframe) * 100))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ThemeColors.successGreen)
                        }
                        
                        ProgressView(value: statsManager.getOverallScore(for: selectedTimeframe))
                            .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.primaryBlue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                        
                        HStack {
                            if let topCategory = statsManager.getTopCategory(for: selectedTimeframe) {
                                Text("🏆 Strongest: \(topCategory)")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.successGreen)
                            }
                            
                            Spacer()
                            
                            if let weakCategory = statsManager.getNeedsImprovementCategory(for: selectedTimeframe) {
                                Text("⚠️ Focus on: \(weakCategory)")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.warningOrange)
                            }
                        }
                    }
                    .primaryCard()
                    
                    // Timeframe Selector
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(StatTimeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .onChange(of: selectedTimeframe) { _ in
                        selectedCategory = nil // Clear selection when timeframe changes
                    }
                    
                    // Interactive Radar Chart
                    VStack(spacing: 16) {
                        HStack {
                            Text("Growth Overview")
                                .cardTitle()
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(ThemeColors.successGreen)
                                    .frame(width: 8, height: 8)
                                
                                Text("Interactive")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.successGreen)
                            }
                        }
                        
                        RadarChartView(
                            data: statsManager.getRadarData(for: selectedTimeframe),
                            maxValue: 1.0,
                            onCategorySelected: { category in
                                selectedCategory = category
                                showingCategoryDetail = true
                            }
                        )
                        .frame(height: 300)
                        .padding()
                        
                        Text(selectedCategory != nil ? "\(selectedCategory!.label) selected - Tap for details" : "Tap on categories to see detailed information")
                            .font(.caption)
                            .foregroundColor(selectedCategory != nil ? ThemeColors.primaryBlue : ThemeColors.textSecondary)
                            .animation(.easeInOut(duration: 0.3), value: selectedCategory)
                    }
                    .statsCard()
                    
                    // Quick Category Insights (when category is selected)
                    if let selectedCategory = selectedCategory {
                        let categoryStats = getCategoryStats(for: selectedCategory)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(selectedCategory.label) Insights")
                                    .cardTitle()
                                
                                Spacer()
                                
                                Button("View Details") {
                                    showingCategoryDetail = true
                                }
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryBlue)
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(String(format: "%.0f%%", categoryStats.percentage * 100))
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(selectedCategory.color)
                                    
                                    Text("Completion Rate")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(categoryStats.completedTasks)/\(categoryStats.totalTasks)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.textPrimary)
                                    
                                    Text("Tasks Done")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .achievementCard()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $showingCategoryDetail) {
            if let selectedCategory = selectedCategory {
                let categoryStats = getCategoryStats(for: selectedCategory)
                let categoryTrend = getCategoryTrend(for: selectedCategory)
                
                CategoryDetailPopup(
                    category: selectedCategory,
                    categoryStats: categoryStats,
                    trends: categoryTrend,
                    timeframe: selectedTimeframe,
                    isPresented: $showingCategoryDetail
                )
                .preferredColorScheme(.dark)
            }
        }
    }
    
    private func getCategoryStats(for category: RadarDataPoint) -> CategoryStat {
        let allStats = statsManager.getDetailedStats(for: selectedTimeframe)
        return allStats.first { $0.category == category.label } ??
            CategoryStat(category: category.label, completedTasks: 0, totalTasks: 0, percentage: 0.0, color: category.color)
    }
    
    private func getCategoryTrend(for category: RadarDataPoint) -> CategoryTrend? {
        let trends = statsManager.getTrends()
        return trends.first { $0.category == category.label }
    }
}
