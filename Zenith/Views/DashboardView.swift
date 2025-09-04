//
//  DashboardView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var streakManager = StreakManager()
    @EnvironmentObject var pointsManager: PointsManager
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Dashboard Header
                    VStack(spacing: 8) {
                        Text("Zenith")
                            .font(.system(size: 60, weight: .heavy, design: .rounded))
                            .foregroundStyle(ThemeColors.secondaryPurple)
                            .shadow(color: ThemeColors.secondaryPurple.opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Text("the time at which something is most powerful or successful")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(ThemeColors.primaryBlue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: 20) {
                        // Welcome Header
                        VStack(spacing: 8) {
                            Text("Welcome Back!")
                                .dashboardTitle()
                            
                            Text("Track your daily progress and build lasting habits")
                                .bodyText()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                    }
                    
                    // Points & Level Card
                    VStack(spacing: 12) {
                        HStack {
                            Text("⭐")
                                .font(.title)
                            
                            Text("Points & Level")
                                .cardTitle()
                            
                            Spacer()
                        }
                        
                        HStack {
                            // Total Points
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(pointsManager.totalPoints)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(ThemeColors.primaryBlue)
                                
                                Text("Total Points")
                                    .captionText()
                            }
                            
                            Spacer()
                            
                            // Level & Progress
                            VStack(alignment: .trailing, spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("Level")
                                        .captionText()
                                    Text("\(pointsManager.currentLevel)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.streakGold)
                                }
                                
                                // Progress Bar
                                VStack(alignment: .trailing, spacing: 4) {
                                    ProgressView(value: pointsManager.levelProgress)
                                        .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.successGreen))
                                        .frame(width: 100)
                                    
                                    Text("\(Int(pointsManager.levelProgress * 100))% to next level")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Daily Points
                        HStack {
                            Text("Today: +\(pointsManager.dailyPoints) points")
                                .successText()
                            
                            Spacer()
                            
                            Text("Next level: \(pointsManager.pointsForNextLevel - Int(pointsManager.levelProgress * Double(pointsManager.pointsForNextLevel))) points")
                                .captionText()
                        }
                    }
                    .primaryCard()
                    
                    // MARK: - Streak Display
                    VStack(spacing: 24) {
                        // Main Streak Display
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                streakManager.markTodayCompleted()
                            }
                        }) {
                            VStack(spacing: 16) {
                                Text("🔥")
                                    .font(.system(size: 60))
                                
                                Text("\(streakManager.currentStreakCount)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(ThemeColors.streakGold)
                                
                                Text(streakManager.currentStreakCount == 1 ? "Day Streak" : "Day Streak")
                                    .cardTitle()
                                
                                Text(streakManager.streakStatusMessage)
                                    .bodyText()
                                    .multilineTextAlignment(.center)
                            }
                            .achievementCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Statistics Grid
                        VStack(spacing: 16) {
                            Text("Streak Statistics")
                                .cardTitle()
                            
                            HStack(spacing: 16) {
                                // Current Streak
                                VStack(spacing: 8) {
                                    Text("\(streakManager.currentStreakCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.primaryBlue)
                                    
                                    Text("Current")
                                        .captionText()
                                }
                                .frame(maxWidth: .infinity)
                                .dashboardCard()
                                
                                // Best Streak
                                VStack(spacing: 8) {
                                    Text("\(streakManager.bestStreakCount)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.successGreen)
                                    
                                    Text("Best Ever")
                                        .captionText()
                                }
                                .frame(maxWidth: .infinity)
                                .dashboardCard()
                                
                                // Total Days
                                VStack(spacing: 8) {
                                    Text("\(streakManager.streak.totalDaysCompleted)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.secondaryPurple)
                                    
                                    Text("Total Days")
                                        .captionText()
                                }
                                .frame(maxWidth: .infinity)
                                .dashboardCard()
                            }
                        }
                        
                        // Motivational Section
                        VStack(spacing: 12) {
                            Text("Keep Going!")
                                .cardTitle()
                            
                            if streakManager.currentStreakCount >= 7 {
                                Text("🏆 Week Warrior! You've maintained your streak for a full week!")
                                    .achievementText()
                                    .multilineTextAlignment(.center)
                            } else if streakManager.currentStreakCount >= 3 {
                                Text("⭐ Great momentum! You're building a solid habit!")
                                    .bodyText()
                                    .multilineTextAlignment(.center)
                            } else if streakManager.currentStreakCount > 0 {
                                Text("🌱 Every journey starts with a single step. Keep it up!")
                                    .bodyText()
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("🚀 Ready to start your streak? Complete your daily tasks to begin!")
                                    .bodyText()
                                    .multilineTextAlignment(.center)
                            }
                            
                            // MARK: - Testing
                            VStack(spacing: 8) {
                                Button("Reset Streak (Test)") {
                                    streakManager.resetStreak()
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                Button("Award Bonus Points (+50)") {
                                    pointsManager.awardBonusPoints(50, reason: "Daily bonus")
                                }
                                .buttonStyle(PrimaryButtonStyle())

                                Button("Reset Points (Test)") {
                                    pointsManager.resetPoints()
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                        .achievementCard()
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            
            // Celebration overlay
            if pointsManager.showCelebration {
                CelebrationOverlay(
                    pointsAwarded: pointsManager.lastAwardedPoints,
                    isLevelUp: pointsManager.currentLevel > 1 && pointsManager.levelProgress < 0.5
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(PointsManager())
}
            
            
//                    // Sample Achievement Card
//                    VStack(spacing: 8) {
//                        Text("🔥 Current Streak")
//                            .cardTitle()
//
//                        Text("7")
//                            .streakCounter()
//
//                        Text("Days completed!")
//                            .achievementText()
//                    }
//                    .achievementCard()
//
//                    // Sample Task Card
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Today's Tasks")
//                            .cardTitle()
//                        
//                        Text("Complete 3 daily goals to maintain your streak")
//                            .bodyText()
//                        
//                        Button("View Tasks") {
//                            print("Tasks button tapped")
//                        }
//                        .buttonStyle(PrimaryButtonStyle())
//                    }
//                    .dashboardCard()
//                    
//                    // Sample Stats Card
//                    VStack(spacing: 12) {
//                        Text("Weekly Progress")
//                            .cardTitle()
//                        
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text("85%")
//                                    .font(.title2)
//                                    .fontWeight(.bold)
//                                    .foregroundStyle(ThemeColors.successGreen)
//                                Text("Completed")
//                                    .captionText()
//                            }
//                            
//                            Spacer()
//                            
//                            Button("View Chart") {
//                                print("Chart button tapped")
//                            }
//                            .buttonStyle(SecondaryButtonStyle())
//                        }
//                    }
//                    .statsCard()
                    
//                    Spacer(minLength: 20)
//                }
//                .padding(.horizontal, 16)
//            }
//        }
//    }
//}
//
//#Preview {
//    DashboardView()
//        .environmentObject(PointsManager())
//}
