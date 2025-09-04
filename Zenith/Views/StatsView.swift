//
//  StatsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct StatsView: View {
    @State private var progress: Double = 0.85 // Example value
    @State private var streakCount = 5 // Example value
    @EnvironmentObject var pointsManager: PointsManager
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Progress Stats")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(ThemeColors.textLight)
                        .padding(.top, 40)

                    // Streak Card
                    VStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(ThemeColors.warningOrange)
                        Text("\(streakCount) Day Streak")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(ThemeColors.textLight)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .dashboardCard()

                    // Weekly Progress Card
                    VStack(spacing: 16) {
                        Text("Weekly Progress")
                            .cardTitle()

                        ProgressRingView(progress: progress, ringColor: ThemeColors.successGreen, textColor: ThemeColors.textLight)
                            .frame(width: 150, height: 150)
                            .padding(.vertical, 10)

                        Button("View Chart") {
                            print("Chart button tapped")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .statsCard()

                    // Growth Areas Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Growth Areas")
                            .cardTitle()

                        ProgressLine(label: "Productivity", value: 0.75, color: ThemeColors.primaryBlue)
                        ProgressLine(label: "Health", value: 0.60, color: ThemeColors.successGreen)
                        ProgressLine(label: "Learning", value: 0.80, color: ThemeColors.secondaryPurple)
                    }
                    .statsCard()

                    Spacer()
                }
                .padding()
                
                VStack(spacing: 24) {
                   // Main Points Display
                   VStack(spacing: 16) {
                       Text("⭐")
                           .font(.system(size: 60))
                       
                       Text("\(pointsManager.totalPoints)")
                           .font(.system(size: 48, weight: .bold))
                           .foregroundColor(ThemeColors.primaryBlue)
                       
                       Text("Total Points")
                           .cardTitle()
                       
                       // Level Info
                       VStack(spacing: 8) {
                           HStack {
                               Text("Level \(pointsManager.currentLevel)")
                                   .font(.title2)
                                   .fontWeight(.bold)
                                   .foregroundColor(ThemeColors.streakGold)
                               
                               Spacer()
                               
                               Text("\(Int(pointsManager.levelProgress * 100))%")
                                   .font(.headline)
                                   .foregroundColor(ThemeColors.successGreen)
                           }
                           
                           ProgressView(value: pointsManager.levelProgress)
                               .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.successGreen))
                               .frame(height: 8)
                           
                           Text("\(pointsManager.pointsForNextLevel - Int(pointsManager.levelProgress * Double(pointsManager.pointsForNextLevel))) points to next level")
                               .captionText()
                       }
                   }
                   .primaryCard()
                   
                   // Daily Stats
                   VStack(spacing: 16) {
                       Text("Today's Progress")
                           .cardTitle()
                       
                       HStack(spacing: 20) {
                           VStack {
                               Text("\(pointsManager.dailyPoints)")
                                   .font(.title2)
                                   .fontWeight(.bold)
                                   .foregroundColor(ThemeColors.successGreen)
                               Text("Points Today")
                                   .captionText()
                           }
                           .frame(maxWidth: .infinity)
                           .dashboardCard()
                           
                           VStack {
                               Text("Level \(pointsManager.currentLevel)")
                                   .font(.title2)
                                   .fontWeight(.bold)
                                   .foregroundColor(ThemeColors.streakGold)
                               Text("Current Level")
                                   .captionText()
                           }
                           .frame(maxWidth: .infinity)
                           .dashboardCard()
                       }
                   }
                   
                   // Level Milestones
                   VStack(alignment: .leading, spacing: 16) {
                       Text("Level Milestones")
                           .cardTitle()
                       
                       VStack(spacing: 12) {
                           ForEach(1..<6) { level in
                               HStack {
                                   Image(systemName: level <= pointsManager.currentLevel ? "star.fill" : "star")
                                       .foregroundColor(level <= pointsManager.currentLevel ? ThemeColors.streakGold : .gray)
                                   
                                   Text("Level \(level)")
                                       .font(.subheadline)
                                       .fontWeight(level <= pointsManager.currentLevel ? .semibold : .regular)
                                       .foregroundColor(level <= pointsManager.currentLevel ? ThemeColors.textPrimary : .gray)
                                   
                                   Spacer()
                                   
                                   Text("\(level * 100) pts")
                                       .font(.caption)
                                       .foregroundColor(.secondary)
                               }
                           }
                       }
                   }
                   .dashboardCard()
                   
                   // Recent Transactions
                   VStack(alignment: .leading, spacing: 16) {
                       Text("Recent Activity")
                           .cardTitle()
                       
                       if pointsManager.userPoints.recentTransactions.isEmpty {
                           Text("No activity yet. Complete tasks to earn points!")
                               .bodyText()
                               .multilineTextAlignment(.center)
                       } else {
                           VStack(spacing: 8) {
                               ForEach(pointsManager.userPoints.recentTransactions) { transaction in
                                   HStack {
                                       VStack(alignment: .leading, spacing: 2) {
                                           Text(transaction.reason)
                                               .font(.subheadline)
                                               .fontWeight(.medium)
                                           
                                           Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                                               .font(.caption)
                                               .foregroundColor(.secondary)
                                       }
                                       
                                       Spacer()
                                       
                                       Text("+\(transaction.points)")
                                           .font(.headline)
                                           .fontWeight(.bold)
                                           .foregroundColor(ThemeColors.successGreen)
                                   }
                                   .padding(.vertical, 4)
                                   
                                   if transaction.id != pointsManager.userPoints.recentTransactions.last?.id {
                                       Divider()
                                   }
                               }
                           }
                       }
                   }
                   .dashboardCard()
                   
                   // Actions
                   VStack(spacing: 12) {
                       Text("Actions")
                           .cardTitle()
                       
                       Button("Award Bonus (+100 pts)") {
                           pointsManager.awardBonusPoints(100, reason: "Manual bonus")
                       }
                       .buttonStyle(PrimaryButtonStyle())
                       
                       Button("Reset Points (Test)") {
                           pointsManager.resetPoints()
                       }
                       .buttonStyle(SecondaryButtonStyle())
                   }
                   .dashboardCard()
                   
                   Spacer(minLength: 20)
               }
               .padding(.horizontal)

            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
        }
    }
}

// MARK: - Helper Views
struct ProgressRingView: View {
    let progress: Double
    let ringColor: Color
    let textColor: Color
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(ringColor.opacity(0.3), style: StrokeStyle(lineWidth: 15, lineCap: .round))
            
            // Foreground ring
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(ringColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: progress)
            
            // Text inside the ring
            Text("\(Int(progress * 100))%")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(textColor)
        }
    }
}

struct ProgressLine: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .bodyText()
                Spacer()
                Text("\(Int(value * 100))%")
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            ProgressView(value: value)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                .animation(.easeOut(duration: 1.0), value: value)
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(PointsManager())
}
