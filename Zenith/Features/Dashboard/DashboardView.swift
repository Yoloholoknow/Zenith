//
//  DashboardView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var streakManager: StreakManager
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var llmService: LLMService
    @StateObject private var dataManager = DataManager.shared
    @State private var tasks: [Task] = []
    
    @State private var showingAPISettings = false
    @State private var showingAIGeneration = false
    @State private var showingPreferences = false
    @StateObject private var taskGenerator = AITaskGenerator()
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(pointsManager.totalPoints)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(ThemeColors.primaryBlue)
                            
                            Text("Total Points")
                                .captionText()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("Level")
                                    .captionText()
                                Text("\(pointsManager.currentLevel)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(ThemeColors.streakGold)
                            }
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                ProgressView(value: pointsManager.levelProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.successGreen))
                                    .frame(width: 100)
                                
                                Text("\(Int(pointsManager.levelProgress * 100))% to next level")
                                    .font(.caption2)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Today: +\(pointsManager.dailyPoints) points")
                            .successText()
                        
                        Spacer()
                        
                        Text("Next level: \(pointsManager.pointsForNextLevel - Int(pointsManager.levelProgress * Double(pointsManager.pointsForNextLevel))) points")
                            .captionText()
                    }
                }
                .dashboardCard()
                
                // MARK: - Streak Display
                VStack(spacing: 24) {
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
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            
            // MARK: - Celebration overlay
            if pointsManager.showCelebration {
                CelebrationOverlay(
                    pointsAwarded: pointsManager.lastAwardedPoints,
                    isLevelUp: pointsManager.isLevelUp
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
