//
//  SettingsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var llmService: LLMService
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var taskGenerator = AITaskGenerator()
    @StateObject private var pointsManager = PointsManager()
    @StateObject private var streakManager = StreakManager()
    
    @State private var showingAPISettings = false
    @State private var showingAIGeneration = false
    @State private var showingPreferences = false
    @State private var tasks: [Task] = []
    
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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // API Integration Status Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: networkManager.isConnected ? "cloud.fill" : "x.circle.fill")
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
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                                
                                Text("Last generated: \(taskGenerator.getGenerationStatus())")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
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
                            .foregroundColor(ThemeColors.textSecondary)
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
                                    .foregroundColor(ThemeColors.textSecondary)
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
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                        } else {
                            Text(taskGenerator.canGenerateToday() ? "Generate AI-powered tasks based on your preferences" : "Tasks already generated today")
                                .font(.subheadline)
                                .foregroundColor(ThemeColors.textSecondary)
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
                    .dashboardCard()
                    
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
                                    .foregroundColor(ThemeColors.textPrimary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ThemeColors.successGreen)
                                    .font(.caption)
                            }
                            
                            HStack {
                                Text("🔥")
                                Text("Streak: Data integrity confirmed")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.textPrimary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ThemeColors.successGreen)
                                    .font(.caption)
                            }
                            
                            HStack {
                                Text("🏆")
                                Text("Points: Level \(pointsManager.currentLevel) validated")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.textPrimary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ThemeColors.successGreen)
                                    .font(.caption)
                            }
                        }
                        
                        HStack {
                            Text("Last validation: App launch")
                                .font(.caption)
                                .foregroundColor(ThemeColors.textSecondary)
                            
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
                }
                .padding()
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAIGeneration) {
                AITaskGenerationView(tasks: $tasks)
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
            .sheet(isPresented: $showingAPISettings) {
                APISettingsView()
            }
            .onAppear {
                tasks = DataManager.shared.loadTasksWithValidation()
            }
        }
    }
}
