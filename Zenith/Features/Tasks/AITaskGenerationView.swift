//
//  AITaskGenerationView.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct AITaskGenerationView: View {
    @StateObject private var taskGenerator = AITaskGenerator()
    @State private var showingPreferences = false
    @State private var showingTaskPreview = false
    @State private var selectedTasks: Set<UUID> = []
    @Binding var tasks: [Task]
    // The onTasksAdded closure is no longer needed for saving.
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    VStack(spacing: 12) {
                        Text("🤖")
                            .font(.system(size: 50))
                        
                        Text("AI Task Generator")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Text("Generate personalized daily tasks based on your preferences and completion history")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Text(taskGenerator.getGenerationStatus())
                            .font(.caption)
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                    .padding()
                    .background(ThemeColors.cardBackground)
                    .cornerRadius(16)
                    
                    // Generation Status
                    VStack(spacing: 16) {
                        HStack {
                            Text("Generation Status")
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
                                Text("Generated Today")
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
                                    .scaleEffect(1.5)
                                    .tint(ThemeColors.primaryBlue)
                                
                                Text("AI is generating your personalized tasks...")
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                            .padding(.vertical, 20)
                        } else if !taskGenerator.generatedTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(taskGenerator.generatedTasks.count) tasks generated")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.textPrimary)
                                
                                Text("Review and select tasks to add to your daily list")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                        } else {
                            VStack(spacing: 8) {
                                Text("No tasks generated yet")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.textPrimary)
                                
                                Text("Tap 'Generate Tasks' to create your personalized daily tasks")
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .dashboardCard()
                    
                    // Generated Tasks Preview
                    if !taskGenerator.generatedTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Generated Tasks")
                                    .cardTitle()
                                
                                Spacer()
                                
                                Button(selectedTasks.count == taskGenerator.generatedTasks.count ? "Deselect All" : "Select All") {
                                    if selectedTasks.count == taskGenerator.generatedTasks.count {
                                        selectedTasks.removeAll()
                                    } else {
                                        selectedTasks = Set(taskGenerator.generatedTasks.map { $0.id })
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(ThemeColors.primaryBlue)
                            }
                            
                            ForEach(taskGenerator.generatedTasks) { task in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            if selectedTasks.contains(task.id) {
                                                selectedTasks.remove(task.id)
                                            } else {
                                                selectedTasks.insert(task.id)
                                            }
                                        }) {
                                            Image(systemName: selectedTasks.contains(task.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedTasks.contains(task.id) ? ThemeColors.successGreen : ThemeColors.textSecondary)
                                                .font(.title2)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(task.title)
                                                    .font(.headline)
                                                    .foregroundColor(ThemeColors.textPrimary)
                                                
                                                Spacer()
                                                
                                                Text(task.priority.rawValue)
                                                    .font(.caption)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(priorityColor(for: task.priority))
                                                    .cornerRadius(6)
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(task.description)
                                                .font(.subheadline)
                                                .foregroundColor(ThemeColors.textSecondary)
                                                .lineLimit(2)
                                            
                                            HStack {
                                                Text(task.category.rawValue)
                                                    .font(.caption)
                                                    .foregroundColor(ThemeColors.secondaryPurple)
                                                
                                                Spacer()
                                                
                                                Text("\(task.potentialPoints) points")
                                                    .font(.caption)
                                                    .foregroundColor(ThemeColors.successGreen)
                                                    .fontWeight(.medium)
                                            }
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if selectedTasks.contains(task.id) {
                                            selectedTasks.remove(task.id)
                                        } else {
                                            selectedTasks.insert(task.id)
                                        }
                                    }
                                    
                                    if task.id != taskGenerator.generatedTasks.last?.id {
                                        Divider()
                                            .background(ThemeColors.textSecondary)
                                    }
                                }
                            }
                        }
                        .dashboardCard()
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        if taskGenerator.canGenerateToday() || taskGenerator.generatedTasks.isEmpty {
                            Button(taskGenerator.isGenerating ? "Generating..." : "Generate Daily Tasks") {
                                taskGenerator.generateDailyTasks()
                                selectedTasks.removeAll()
                            }
                            .disabled(taskGenerator.isGenerating)
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        
                        if !taskGenerator.generatedTasks.isEmpty && !selectedTasks.isEmpty {
                            Button("Add \(selectedTasks.count) Selected Tasks") {
                                addSelectedTasks()
                            }
                            .buttonStyle(SuccessButtonStyle())
                        }
                        
                        Button("Customize Preferences") {
                            showingPreferences = true
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        if !taskGenerator.generatedTasks.isEmpty {
                            Button("Clear Generated Tasks") {
                                taskGenerator.generatedTasks.removeAll()
                                selectedTasks.removeAll()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .navigationTitle("AI Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
                    .preferredColorScheme(.dark)
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func addSelectedTasks() {
        let tasksToAdd = taskGenerator.generatedTasks.filter { selectedTasks.contains($0.id) }
        tasks.append(contentsOf: tasksToAdd)
        DataManager.shared.saveTasks(tasks)
        
        print("✅ Added \(tasksToAdd.count) AI-generated tasks to main list and saved data.")
        
        taskGenerator.generatedTasks.removeAll()
        selectedTasks.removeAll()
    }
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .low:
            return ThemeColors.textSecondary
        case .medium:
            return ThemeColors.primaryBlue
        case .high:
            return ThemeColors.warningOrange
        case .critical:
            return Color.red
        }
    }
}
