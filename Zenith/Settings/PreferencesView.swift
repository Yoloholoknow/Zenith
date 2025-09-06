//
//  PreferencesView.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var taskGenerator = AITaskGenerator()
    @State private var preferences: UserPreferences
    @State private var newFocusArea = ""
    @Environment(\.dismiss) private var dismiss
    
    init() {
        let generator = AITaskGenerator()
        _preferences = State(initialValue: generator.getUserPreferences())
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Task Generation Settings
                Section("Daily Task Generation") {
                    HStack {
                        Text("Number of tasks")
                            .foregroundColor(ThemeColors.textPrimary)
                        Spacer()
                        Stepper("\(preferences.dailyTaskCount)", value: $preferences.dailyTaskCount, in: 1...8)
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                    
                    Picker("Difficulty Level", selection: $preferences.preferredDifficulty) {
                        ForEach(TaskDifficulty.allCases, id: \.self) { difficulty in
                            VStack(alignment: .leading) {
                                Text(difficulty.rawValue)
                                    .foregroundColor(ThemeColors.textPrimary)
                                Text(difficulty.description)
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .listRowBackground(ThemeColors.cardBackground)
                    
                    Picker("Time Availability", selection: $preferences.timeAvailability) {
                        ForEach(TimeAvailability.allCases, id: \.self) { time in
                            VStack(alignment: .leading) {
                                Text(time.rawValue)
                                    .foregroundColor(ThemeColors.textPrimary)
                                Text(time.description)
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .tag(time)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .listRowBackground(ThemeColors.cardBackground)
                }
                
                // Category Preferences
                Section("Preferred Categories") {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        HStack {
                            Text(category.rawValue)
                                .foregroundColor(ThemeColors.textPrimary)
                            Spacer()
                            if preferences.preferredCategories.contains(category) {
                                Button("Remove") {
                                    preferences.preferredCategories.removeAll { $0 == category }
                                }
                                .foregroundColor(.red)
                                .font(.caption)
                            } else if !preferences.avoidCategories.contains(category) {
                                Button("Add") {
                                    preferences.preferredCategories.append(category)
                                }
                                .foregroundColor(ThemeColors.primaryBlue)
                                .font(.caption)
                            }
                            
                            if preferences.avoidCategories.contains(category) {
                                Text("Avoided")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                        .listRowBackground(ThemeColors.cardBackground)
                    }
                }
                
                // Focus Areas
                Section("Personal Focus Areas") {
                    ForEach(preferences.focusAreas.indices, id: \.self) { index in
                        HStack {
                            Text(preferences.focusAreas[index])
                                .foregroundColor(ThemeColors.textPrimary)
                            Spacer()
                            Button("Remove") {
                                preferences.focusAreas.remove(at: index)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                        .listRowBackground(ThemeColors.cardBackground)
                    }
                    
                    HStack {
                        TextField("Add focus area", text: $newFocusArea)
                            .foregroundColor(ThemeColors.textPrimary)
                        Button("Add") {
                            if !newFocusArea.isEmpty && !preferences.focusAreas.contains(newFocusArea) {
                                preferences.focusAreas.append(newFocusArea)
                                newFocusArea = ""
                            }
                        }
                        .disabled(newFocusArea.isEmpty)
                        .foregroundColor(ThemeColors.primaryBlue)
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                }
                
                // Advanced Settings
                Section("Task Preferences") {
                    Toggle("Include routine tasks", isOn: $preferences.includeRoutineTasks)
                        .tint(ThemeColors.primaryBlue)
                        .foregroundColor(ThemeColors.textPrimary)
                        .listRowBackground(ThemeColors.cardBackground)
                    
                    Toggle("Include challenges", isOn: $preferences.includeChallenges)
                        .tint(ThemeColors.primaryBlue)
                        .foregroundColor(ThemeColors.textPrimary)
                        .listRowBackground(ThemeColors.cardBackground)
                    
                    Toggle("Prefer morning tasks", isOn: $preferences.preferMorningTasks)
                        .tint(ThemeColors.primaryBlue)
                        .foregroundColor(ThemeColors.textPrimary)
                        .listRowBackground(ThemeColors.cardBackground)
                    
                    HStack {
                        Text("Max task duration")
                            .foregroundColor(ThemeColors.textPrimary)
                        Spacer()
                        Text("\(preferences.maxTaskDuration) min")
                            .foregroundColor(ThemeColors.textSecondary)
                        Stepper("", value: $preferences.maxTaskDuration, in: 15...180, step: 15)
                            .labelsHidden()
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                }
                
                // Generation History
                if !preferences.generationHistory.isEmpty {
                    Section("Recent Generations") {
                        ForEach(preferences.generationHistory.suffix(3), id: \.self) { prompt in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Generation Prompt")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.primaryBlue)
                                
                                Text(prompt.prefix(100) + (prompt.count > 100 ? "..." : ""))
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .lineLimit(3)
                            }
                            .padding(.vertical, 2)
                            .listRowBackground(ThemeColors.cardBackground)
                        }
                    }
                }
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("AI Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreferences()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryBlue)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func savePreferences() {
        taskGenerator.updatePreferences(preferences)
        print("✅ Preferences saved: \(preferences.dailyTaskCount) tasks, \(preferences.preferredDifficulty.rawValue) difficulty")
    }
}
