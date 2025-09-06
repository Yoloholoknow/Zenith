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

    private func formatLastSaveDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func runManualDataValidation() {
        print("🔍 Running manual data validation...")
        
        let currentTasks = dataManager.loadTasksWithValidation()
        self.tasks = currentTasks
        print("✅ All tasks passed validation")
        
        let validatedStreak = dataManager.loadStreakWithValidation()
        if validatedStreak.currentStreak != streakManager.currentStreakCount ||
           validatedStreak.bestStreak != streakManager.bestStreakCount {
            print("⚠️ Manual validation corrected streak data")
            streakManager.streak = validatedStreak
        } else {
            print("✅ Streak data passed validation")
        }
        
        let validatedPoints = dataManager.loadPointsWithValidation()
        if validatedPoints.totalPoints != pointsManager.totalPoints ||
           validatedPoints.level != pointsManager.currentLevel {
            print("⚠️ Manual validation corrected points data")
            pointsManager.userPoints = validatedPoints
        } else {
            print("✅ Points data passed validation")
        }
        
        let backupSuccess = dataManager.createBackup()
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
                        VStack(spacing: 8) {
                            Text("Welcome Back!")
                                .dashboardTitle()
                            
                            Text("Track your daily progress and build lasting habits")
                                .bodyText()
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                    }
                    
                    // API Integration Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: networkManager.isConnected ? "cloud.fill" : "cloud.slash")
                                .foregroundColor(networkManager.isConnected ? ThemeColors.successGreen : ThemeColors.warningOrange)
                                .font(.title3)
                            
                            Text("AI Task Generation")
                                .cardTitle()
                            
                            Spacer()
                            
                            Text(networkManager.isConnected ? "Connected" : "Setup Required")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(networkManager.isConnected ? ThemeColors.successGreen : ThemeColors.warningOrange)
                                .cornerRadius(4)
                        }
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                if networkManager.hasValidAPIKey() {
                                    if networkManager.isConnected {
                                        Text("✅ Ready to generate personalized tasks")
                                            .font(.subheadline)
                                            .foregroundColor(ThemeColors.successGreen)
                                    } else {
                                        Text("⚠️ API key configured but connection failed")
                                            .font(.subheadline)
                                            .foregroundColor(ThemeColors.warningOrange)
                                    }
                                } else {
                                    Text("🔑 Configure your API key to unlock AI-powered task generation")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Last generated: \(taskGenerator.getGenerationStatus())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            if networkManager.hasValidAPIKey() {
                                Button("Test Connection") {
                                    networkManager.checkConnection()
                                }
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryBlue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(ThemeColors.primaryBlue, lineWidth: 1)
                                )
                                .disabled(networkManager.isLoading)
                                
                                if networkManager.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                }
                            } else {
                                Button("Setup AI Integration") {
                                    showingAPISettings = true
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                            
                            Spacer()
                            
                            Button("Settings") {
                                showingAPISettings = true
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                    }
                    .dashboardCard()
                    
                    // AI Task Generation Card
                    VStack(spacing: 12) {
                        HStack {
                            Text("🤖")
                                .font(.title)
                            
                            Text("AI Task Generator")
                                .cardTitle()
                            
                            Spacer()
                            
                            if taskGenerator.canGenerateToday() {
                                Text("Ready")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.successGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(ThemeColors.successGreen.opacity(0.2))
                                    .cornerRadius(4)
                            } else {
                                Text("Generated")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        
                        if taskGenerator.isGenerating {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(ThemeColors.primaryBlue)
                                
                                Text("AI is creating your personalized tasks...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 8)
                        } else if !taskGenerator.generatedTasks.isEmpty {
                            VStack(spacing: 8) {
                                Text("\(taskGenerator.generatedTasks.count) personalized tasks ready")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.textPrimary)
                                
                                Text("Review and add tasks to your daily list")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text(taskGenerator.canGenerateToday() ? "Generate AI-powered tasks based on your preferences" : "Tasks already generated today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        HStack(spacing: 12) {
                            if taskGenerator.canGenerateToday() && taskGenerator.generatedTasks.isEmpty {
                                Button("Generate Tasks") {
                                    taskGenerator.generateDailyTasks()
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(taskGenerator.isGenerating)
                            }
                            
                            if !taskGenerator.generatedTasks.isEmpty {
                                Button("Review Tasks") {
                                    showingAIGeneration = true
                                }
                                .buttonStyle(SuccessButtonStyle())
                            }
                            
                            Button("Preferences") {
                                showingPreferences = true
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }
                    .primaryCard()
                    
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
                                        .foregroundColor(.secondary)
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
                    .primaryCard()
                    
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
                        
                        // Statistics Grid
                        VStack(spacing: 16) {
                            Text("Streak Statistics")
                                .cardTitle()
                            
                            HStack(spacing: 16) {
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
        .sheet(isPresented: $showingAIGeneration) {
            AITaskGenerationView(tasks: $tasks, onTasksAdded: saveTasksData)
                .environmentObject(llmService)
        }
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
        .sheet(isPresented: $showingAPISettings) {
            APISettingsView()
        }
        .onAppear {
            loadTasksData()
        }
    }
    
    private func loadTasksData() {
        tasks = DataManager.shared.loadTasksWithValidation()
    }
    
    private func saveTasksData() {
        DataManager.shared.saveTasks(tasks)
    }
}
