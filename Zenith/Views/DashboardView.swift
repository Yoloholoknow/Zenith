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
    @StateObject private var dataManager = DataManager.shared
    
    private func formatLastSaveDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func runManualDataValidation() {
        print("🔍 Running manual data validation...")
        
        // Validate tasks
        let currentTasks = DataManager.shared.loadTasks()
        do {
            let validatedTasks = try DataValidator.shared.validateTasks(currentTasks)
            if validatedTasks.count != currentTasks.count {
                print("⚠️ Manual validation corrected \(currentTasks.count - validatedTasks.count) task issues")
                DataManager.shared.saveTasks(validatedTasks)
            } else {
                print("✅ All tasks passed validation")
            }
        } catch {
            print("❌ Task validation error: \(error.localizedDescription)")
        }
        
        // Validate streak
        let currentStreak = DataManager.shared.loadStreak()
        do {
            let validatedStreak = try DataValidator.shared.validateStreak(currentStreak)
            if validatedStreak.currentStreak != currentStreak.currentStreak ||
               validatedStreak.bestStreak != currentStreak.bestStreak {
                print("⚠️ Manual validation corrected streak data")
                DataManager.shared.saveStreak(validatedStreak)
                streakManager.streak = validatedStreak
            } else {
                print("✅ Streak data passed validation")
            }
        } catch {
            print("❌ Streak validation error: \(error.localizedDescription)")
        }
        
        // Validate points
        let currentPoints = DataManager.shared.loadPoints()
        do {
            let validatedPoints = try DataValidator.shared.validatePoints(currentPoints)
            if validatedPoints.totalPoints != currentPoints.totalPoints ||
               validatedPoints.level != currentPoints.level {
                print("⚠️ Manual validation corrected points data")
                DataManager.shared.savePoints(validatedPoints)
                pointsManager.userPoints = validatedPoints
            } else {
                print("✅ Points data passed validation")
            }
        } catch {
            print("❌ Points validation error: \(error.localizedDescription)")
        }
        
        // Create backup after validation
        let backupSuccess = DataManager.shared.createBackup()
        if backupSuccess {
            print("✅ Backup created after validation")
        }
        
        print("🔍 Manual data validation completed")
    }
    
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
                            
                            // MARK: - Data Sync Status Card
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: dataManager.hasExistingData() ? "checkmark.circle.fill" : "exclamationmark.circle")
                                        .foregroundColor(dataManager.hasExistingData() ? ThemeColors.successGreen : ThemeColors.warningOrange)
                                        .font(.title3)
                                    
                                    Text("Data Status")
                                        .cardTitle()
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(dataManager.hasExistingData() ? "✅ Data Saved" : "📝 No Data Yet")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(dataManager.hasExistingData() ? ThemeColors.successGreen : ThemeColors.textSecondary)
                                        
                                        if let lastSave = dataManager.getLastSaveDate() {
                                            Text("Last saved: \(formatLastSaveDate(lastSave))")
                                                .captionText()
                                        } else {
                                            Text("Complete tasks to save progress")
                                                .captionText()
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Clear All") {
                                        dataManager.clearAllData()
                                        // Refresh managers
                                        pointsManager.resetPoints()
                                        streakManager.resetStreak()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.red, lineWidth: 1)
                                    )
                                }
                            }
                            .dashboardCard()
                            
                            Spacer(minLength: 20)
                            
                            // MARK: - Data Health Monitor Card
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.shield")
                                        .foregroundColor(ThemeColors.successGreen)
                                        .font(.title3)
                                    
                                    Text("Data Health")
                                        .cardTitle()
                                    
                                    Spacer()
                                    
                                    Text("Validated")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(ThemeColors.successGreen)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(ThemeColors.successGreen.opacity(0.2))
                                        .cornerRadius(4)
                                }
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("📝")
                                        Text("Tasks: \(tasks.count) validated")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ThemeColors.successGreen)
                                            .font(.caption)
                                    }
                                    
                                    HStack {
                                        Text("🔥")
                                        Text("Streak: Data integrity confirmed")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ThemeColors.successGreen)
                                            .font(.caption)
                                    }
                                    
                                    HStack {
                                        Text("🏆")
                                        Text("Points: Level \(pointsManager.currentLevel) validated")
                                            .font(.subheadline)
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(ThemeColors.successGreen)
                                            .font(.caption)
                                    }
                                }
                                
                                HStack {
                                    Text("Last validation: App launch")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Button("Run Check") {
                                        runManualDataValidation()
                                    }
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.primaryBlue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(ThemeColors.primaryBlue, lineWidth: 1)
                                    )
                                }
                            }
                            .dashboardCard()
                            
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
                    isLevelUp: pointsManager.isLevelUp
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

//#Preview {
//    DashboardView()
//        .environmentObject(PointsManager())
//}
            
            
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
