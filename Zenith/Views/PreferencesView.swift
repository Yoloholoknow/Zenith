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
                        Spacer()
                        Stepper("\(preferences.dailyTaskCount)", value: $preferences.dailyTaskCount, in: 1...8)
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                    
                    Picker("Difficulty Level", selection: $preferences.preferredDifficulty) {
                        ForEach(TaskDifficulty.allCases, id: \.self) { difficulty in
                            VStack(alignment: .leading) {
                                Text(difficulty.rawValue)
                                Text(difficulty.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Picker("Time Availability", selection: $preferences.timeAvailability) {
                        ForEach(TimeAvailability.allCases, id: \.self) { time in
                            VStack(alignment: .leading) {
                                Text(time.rawValue)
                                Text(time.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(time)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Category Preferences
                Section("Preferred Categories") {
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        HStack {
                            Text(category.rawValue)
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
                    }
                }
                
                // Focus Areas
                Section("Personal Focus Areas") {
                    ForEach(preferences.focusAreas.indices, id: \.self) { index in
                        HStack {
                            Text(preferences.focusAreas[index])
                            Spacer()
                            Button("Remove") {
                                preferences.focusAreas.remove(at: index)
                            }
                            .foregroundColor(.red)
                            .font(.caption)
                        }
                    }
                    
                    HStack {
                        TextField("Add focus area", text: $newFocusArea)
                        Button("Add") {
                            if !newFocusArea.isEmpty && !preferences.focusAreas.contains(newFocusArea) {
                                preferences.focusAreas.append(newFocusArea)
                                newFocusArea = ""
                            }
                        }
                        .disabled(newFocusArea.isEmpty)
                        .foregroundColor(ThemeColors.primaryBlue)
                    }
                }
                
                // Advanced Settings
                Section("Task Preferences") {
                    Toggle("Include routine tasks", isOn: $preferences.includeRoutineTasks)
                        .tint(ThemeColors.primaryBlue)
                    
                    Toggle("Include challenges", isOn: $preferences.includeChallenges)
                        .tint(ThemeColors.primaryBlue)
                    
                    Toggle("Prefer morning tasks", isOn: $preferences.preferMorningTasks)
                        .tint(ThemeColors.primaryBlue)
                    
                    HStack {
                        Text("Max task duration")
                        Spacer()
                        Text("\(preferences.maxTaskDuration) min")
                            .foregroundColor(.secondary)
                        Stepper("", value: $preferences.maxTaskDuration, in: 15...180, step: 15)
                            .labelsHidden()
                    }
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
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("AI Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
        }
    }
    
    private func savePreferences() {
        taskGenerator.updatePreferences(preferences)
        print("✅ Preferences saved: \(preferences.dailyTaskCount) tasks, \(preferences.preferredDifficulty.rawValue) difficulty")
    }
}
