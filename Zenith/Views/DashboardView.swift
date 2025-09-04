//
//  DashboardView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var streakManager = StreakManager()
    
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
                        
                        // Streak Counter Card
                        VStack(spacing: 12) {
                            HStack {
                                Text("🔥")
                                    .font(.title)
                                
                                Text("Current Streak")
                                    .cardTitle()
                                
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(streakManager.currentStreakCount)")
                                        .streakCounter()
                                    
                                    Text(streakManager.currentStreakCount == 1 ? "day" : "days")
                                        .captionText()
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Best: \(streakManager.bestStreakCount)")
                                        .bodyText()
                                        .fontWeight(.medium)
                                    
                                    if streakManager.hasActiveStreak {
                                        Text("Active")
                                            .successText()
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(ThemeColors.successGreen.opacity(0.2))
                                            .cornerRadius(4)
                                    } else {
                                        Text("Inactive")
                                            .captionText()
                                    }
                                }
                            }
                            
                            Text(streakManager.streakStatusMessage)
                                .bodyText()
                                .multilineTextAlignment(.center)
                        }
                        .achievementCard()
                        
                        // Quick Actions Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Actions")
                                .cardTitle()
                            
                            Button("Mark Today Complete") {
                                streakManager.markTodayCompleted()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            
                            Button("Reset Streak (Test)") {
                                streakManager.resetStreak()
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .dashboardCard()
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal)
                }
                .background(ThemeColors.backgroundDark)
                .navigationTitle("Dashboard")
                .navigationBarTitleDisplayMode(.inline)
                
                NavigationView {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Main Streak Display
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
                            .primaryCard()
                            
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
                                
                                // Action Buttons
                                VStack(spacing: 8) {
                                    if !streakManager.hasActiveStreak {
                                        Button("Start My Streak Today!") {
                                            streakManager.markTodayCompleted()
                                        }
                                        .buttonStyle(PrimaryButtonStyle())
                                    } else {
                                        Button("Mark Today Complete") {
                                            streakManager.markTodayCompleted()
                                        }
                                        .buttonStyle(SuccessButtonStyle())
                                    }
                                    
                                    Button("Reset Streak") {
                                        streakManager.resetStreak()
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                            .achievementCard()
                            
                            Spacer(minLength: 20)
                        }
                        .padding(.horizontal)
                    }
                    .background(ThemeColors.backgroundDark)
                    .navigationTitle("Streak Tracker")
                }
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
        }
    }
}

#Preview {
    DashboardView()
}
