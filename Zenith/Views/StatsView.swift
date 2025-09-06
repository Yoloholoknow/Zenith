//
//  StatsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

//import SwiftUI
//import Combine
//
//struct StatsView: View {
//    @EnvironmentObject var pointsManager: PointsManager
//    @EnvironmentObject var streakManager: StreakManager
//    
//    var body: some View {
//        ZStack {
//            ThemeColors.backgroundDark.ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    Text("Progress Stats")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundStyle(ThemeColors.textLight)
//                        .padding(.top, 40)
//
//                    // Streak Card
//                    VStack(spacing: 12) {
//                        Image(systemName: "flame.fill")
//                            .font(.system(size: 40))
//                            .foregroundStyle(ThemeColors.warningOrange)
//                        Text("\(streakManager.currentStreakCount) Day Streak")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundStyle(ThemeColors.textLight)
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .dashboardCard()
//
//                    // Weekly Progress Card
//                    VStack(spacing: 16) {
//                        Text("Weekly Progress")
//                            .cardTitle()
//
//                        ProgressRingView(progress: pointsManager.levelProgress, ringColor: ThemeColors.successGreen, textColor: ThemeColors.textLight)
//                            .frame(width: 150, height: 150)
//                            .padding(.vertical, 10)
//
//                        Button("View Chart") {
//                            print("Chart button tapped")
//                        }
//                        .buttonStyle(SecondaryButtonStyle())
//                    }
//                    .statsCard()
//
//                    // Growth Areas Card
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Growth Areas")
//                            .cardTitle()
//
//                        ProgressLine(label: "Productivity", value: 0.75, color: ThemeColors.primaryBlue)
//                        ProgressLine(label: "Health", value: 0.60, color: ThemeColors.successGreen)
//                        ProgressLine(label: "Learning", value: 0.80, color: ThemeColors.secondaryPurple)
//                    }
//                    .statsCard()
//
//                    Spacer()
//                }
//                .padding()
//                
//                VStack(spacing: 24) {
//                   // Main Points Display
//                   VStack(spacing: 16) {
//                       Text("⭐")
//                           .font(.system(size: 60))
//                       
//                       Text("\(pointsManager.totalPoints)")
//                           .font(.system(size: 48, weight: .bold))
//                           .foregroundColor(ThemeColors.primaryBlue)
//                       
//                       Text("Total Points")
//                           .cardTitle()
//                       
//                       // Level Info
//                       VStack(spacing: 8) {
//                           HStack {
//                               Text("Level \(pointsManager.currentLevel)")
//                                   .font(.title2)
//                                   .fontWeight(.bold)
//                                   .foregroundColor(ThemeColors.streakGold)
//                               
//                               Spacer()
//                               
//                               Text("\(Int(pointsManager.levelProgress * 100))%")
//                                   .font(.headline)
//                                   .foregroundColor(ThemeColors.successGreen)
//                           }
//                           
//                           ProgressView(value: pointsManager.levelProgress)
//                               .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.successGreen))
//                               .frame(height: 8)
//                           
//                           Text("\(pointsManager.pointsForNextLevel - Int(pointsManager.levelProgress * Double(pointsManager.pointsForNextLevel))) points to next level")
//                               .captionText()
//                       }
//                   }
//                   .primaryCard()
//                   
//                   // Daily Stats
//                   VStack(spacing: 16) {
//                       Text("Today's Progress")
//                           .cardTitle()
//                       
//                       HStack(spacing: 20) {
//                           VStack {
//                               Text("\(pointsManager.dailyPoints)")
//                                   .font(.title2)
//                                   .fontWeight(.bold)
//                                   .foregroundColor(ThemeColors.successGreen)
//                               Text("Points Today")
//                                   .captionText()
//                           }
//                           .frame(maxWidth: .infinity)
//                           .dashboardCard()
//                           
//                           VStack {
//                               Text("Level \(pointsManager.currentLevel)")
//                                   .font(.title2)
//                                   .fontWeight(.bold)
//                                   .foregroundColor(ThemeColors.streakGold)
//                               Text("Current Level")
//                                   .captionText()
//                           }
//                           .frame(maxWidth: .infinity)
//                           .dashboardCard()
//                       }
//                   }
//                   
//                   // Level Milestones
//                   VStack(alignment: .leading, spacing: 16) {
//                       Text("Level Milestones")
//                           .cardTitle()
//                       
//                       VStack(spacing: 12) {
//                           ForEach(1..<6) { level in
//                               HStack {
//                                   Image(systemName: level <= pointsManager.currentLevel ? "star.fill" : "star")
//                                       .foregroundColor(level <= pointsManager.currentLevel ? ThemeColors.streakGold : .gray)
//                                   
//                                   Text("Level \(level)")
//                                       .font(.subheadline)
//                                       .fontWeight(level <= pointsManager.currentLevel ? .semibold : .regular)
//                                       .foregroundColor(level <= pointsManager.currentLevel ? ThemeColors.textPrimary : .gray)
//                                   
//                                   Spacer()
//                                   
//                                   Text("\(level * 100) pts")
//                                       .font(.caption)
//                                       .foregroundColor(.secondary)
//                               }
//                           }
//                       }
//                   }
//                   .dashboardCard()
//                   
//                   // Recent Transactions
//                   VStack(alignment: .leading, spacing: 16) {
//                       Text("Recent Activity")
//                           .cardTitle()
//                       
//                       if pointsManager.userPoints.recentTransactions.isEmpty {
//                           Text("No activity yet. Complete tasks to earn points!")
//                               .bodyText()
//                               .multilineTextAlignment(.center)
//                       } else {
//                           VStack(spacing: 8) {
//                               ForEach(pointsManager.userPoints.recentTransactions) { transaction in
//                                   HStack {
//                                       VStack(alignment: .leading, spacing: 2) {
//                                           Text(transaction.reason)
//                                               .font(.subheadline)
//                                               .fontWeight(.medium)
//                                           
//                                           Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
//                                               .font(.caption)
//                                               .foregroundColor(.secondary)
//                                       }
//                                       
//                                       Spacer()
//                                       
//                                       Text("+\(transaction.points)")
//                                           .font(.headline)
//                                           .fontWeight(.bold)
//                                           .foregroundColor(ThemeColors.successGreen)
//                                   }
//                                   .padding(.vertical, 4)
//                                   
//                                   if transaction.id != pointsManager.userPoints.recentTransactions.last?.id {
//                                       Divider()
//                                   }
//                               }
//                           }
//                       }
//                   }
//                   .dashboardCard()
//                   
//                   // Actions
//                   VStack(spacing: 12) {
//                       Text("Actions")
//                           .cardTitle()
//                       
//                       Button("Award Bonus (+100 pts)") {
//                           pointsManager.awardBonusPoints(100, reason: "Manual bonus")
//                       }
//                       .buttonStyle(PrimaryButtonStyle())
//                       
//                       Button("Reset Points (Test)") {
//                           pointsManager.resetPoints()
//                       }
//                       .buttonStyle(SecondaryButtonStyle())
//                   }
//                   .dashboardCard()
//                   
//                   Spacer(minLength: 20)
//               }
//               .padding(.horizontal)
//
//            }
//            .background(ThemeColors.backgroundDark.ignoresSafeArea())
//
//            // Celebration overlay
//            if pointsManager.showCelebration {
//                CelebrationOverlay(
//                    pointsAwarded: pointsManager.lastAwardedPoints,
//                    isLevelUp: pointsManager.isLevelUp
//                )
//                .transition(.opacity)
//                .zIndex(1)
//            }
//        }
//    }
//}
//
//// MARK: - Helper Views
//struct ProgressRingView: View {
//    let progress: Double
//    let ringColor: Color
//    let textColor: Color
//    
//    var body: some View {
//        ZStack {
//            // Background ring
//            Circle()
//                .stroke(ringColor.opacity(0.3), style: StrokeStyle(lineWidth: 15, lineCap: .round))
//            
//            // Foreground ring
//            Circle()
//                .trim(from: 0.0, to: progress)
//                .stroke(ringColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
//                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 1.0), value: progress)
//            
//            // Text inside the ring
//            Text("\(Int(progress * 100))%")
//                .font(.system(size: 40, weight: .bold))
//                .foregroundStyle(textColor)
//        }
//    }
//}
//
//struct ProgressLine: View {
//    let label: String
//    let value: Double
//    let color: Color
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            HStack {
//                Text(label)
//                    .bodyText()
//                Spacer()
//                Text("\(Int(value * 100))%")
//                    .fontWeight(.semibold)
//                    .foregroundStyle(color)
//            }
//            ProgressView(value: value)
//                .progressViewStyle(LinearProgressViewStyle(tint: color))
//                .scaleEffect(x: 1, y: 1.5, anchor: .center)
//                .animation(.easeOut(duration: 1.0), value: value)
//        }
//    }
//}
//
//#Preview {
//    StatsView()
//        .environmentObject(PointsManager())
//}

import SwiftUI

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
                            Text("ЁЯУК")
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
                                Text("ЁЯПЖ Strongest: \(topCategory)")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.successGreen)
                            }
                            
                            Spacer()
                            
                            if let weakCategory = statsManager.getNeedsImprovementCategory(for: selectedTimeframe) {
                                Text("ЁЯТк Focus on: \(weakCategory)")
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
                            .foregroundColor(selectedCategory != nil ? ThemeColors.primaryBlue : .secondary)
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
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(categoryStats.completedTasks)/\(categoryStats.totalTasks)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.textPrimary)
                                    
                                    Text("Tasks Done")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                        .achievementCard()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // Rest of the existing content...
                    // (Keep the existing Detailed Stats and Insights sections)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(ThemeColors.backgroundLight)
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
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
