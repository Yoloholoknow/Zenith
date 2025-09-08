//
//  TasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct TasksView: View {
    @State private var showingTaskDetail = false
    @State private var selectedTask: Task?
    @State private var showingAIGeneration = false
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(dataManager.tasks.filter { !$0.isCompleted }) { task in
                    HStack(spacing: 12) {
                        // Completion button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                toggleTaskCompletion(task)
                            }
                        }) {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                                .font(.title2)
                                .overlay(
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(ThemeColors.successGreen)
                                        .font(.title2)
                                        .scaleEffect(task.isCompleted ? 1.0 : 0.0)
                                        .opacity(task.isCompleted ? 1.0 : 0.0)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: task.isCompleted)
                                )
                        }
                        
                        // Task details card
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(task.title)
                                    .font(.headline)
                                    .strikethrough(task.isCompleted)
                                    .foregroundColor(task.isCompleted ? ThemeColors.textSecondary : ThemeColors.textPrimary)
                                
                                Spacer()
                                
                                Text(task.priority.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(priorityColor(for: task.priority))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            if !task.description.isEmpty {
                                Text(task.description)
                                    .font(.subheadline)
                                    .foregroundColor(ThemeColors.textSecondary)
                                    .lineLimit(2)
                            }
                            
                            HStack {
                                Text(task.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.secondaryPurple)
                                
                                Spacer()
                                
                                if task.isCompleted {
                                    Text("+\(task.pointsEarned) points")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.successGreen)
                                        .fontWeight(.medium)
                                } else {
                                    Text("\(task.potentialPoints) points")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .onTapGesture {
                            selectedTask = task
                            showingTaskDetail = true
                        }
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                }
                .onDelete(perform: deleteTask)
            }
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingAIGeneration = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "brain")
                            Text("AI")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.secondaryPurple)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedTask = nil
                        showingTaskDetail = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingTaskDetail) {
                TaskDetailView(isPresented: $showingTaskDetail, tasks: $dataManager.tasks, task: selectedTask)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingAIGeneration) {
                AITaskGenerationView(tasks: $dataManager.tasks)
                    .preferredColorScheme(.dark)
            }
        }
    }
    
    private func saveTasksData() {
        dataManager.saveTasks(dataManager.tasks) // UPDATED: Save the published property
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        if let index = dataManager.tasks.firstIndex(where: { $0.id == task.id }) {
            // First, update the local task to show it's completed for the animation
            var completedTask = dataManager.tasks.remove(at: index)
            completedTask.isCompleted.toggle()
            
            // Perform haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Remove from the current view after a small delay to allow the animation to show
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Archive the task
                dataManager.archiveTask(completedTask)
                
                // Award points
                pointsManager.awardPointsForTask(completedTask)
                
                // Save the modified tasks list (without the completed task)
                saveTasksData()
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        dataManager.tasks.remove(atOffsets: offsets) // UPDATED: Modify the published property
        saveTasksData()
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
