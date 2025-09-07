//
//  TasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct TasksView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    @State private var showingAIGeneration = false
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    HStack(spacing: 12) {
                        Button(action: {
                            toggleTaskCompletion(task)
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? ThemeColors.successGreen : .gray)
                                .font(.title2)
                        }
                        
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
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
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
                        showingAddTask = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(isPresented: $showingAddTask, tasks: $tasks, onTaskAdded: saveTasksData)
                    .preferredColorScheme(.dark)
            }
            .sheet(isPresented: $showingAIGeneration) {
                // Remove the extra parameter from this line
                AITaskGenerationView(tasks: $tasks)
                    .preferredColorScheme(.dark)
            }
            .onAppear {
                loadTasksData()
            }
        }
    }
    
    private func loadTasksData() {
        tasks = dataManager.loadTasksWithValidation()
    }
    
    private func saveTasksData() {
        dataManager.saveTasks(tasks)
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            
            if tasks[index].isCompleted {
                tasks[index].markAsCompleted()
                pointsManager.awardPointsForTask(tasks[index])
            } else {
                tasks[index].markAsIncomplete()
            }
            
            saveTasksData()
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
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

// Add the missing AddTaskView implementation
struct AddTaskView: View {
    @Binding var isPresented: Bool
    @Binding var tasks: [Task]
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .other
    
    let onTaskAdded: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").foregroundColor(ThemeColors.textSecondary)) {
                    TextField("Task title", text: $taskTitle)
                        .listRowBackground(ThemeColors.cardBackground)
                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                        .listRowBackground(ThemeColors.cardBackground)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                                .foregroundColor(ThemeColors.textPrimary)
                        }
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                                .foregroundColor(ThemeColors.textPrimary)
                        }
                    }
                    .listRowBackground(ThemeColors.cardBackground)
                }
            }
            .preferredColorScheme(.dark)
            .background(ThemeColors.backgroundDark)
            .scrollContentBackground(.hidden)
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTask = Task(
                            title: taskTitle,
                            description: taskDescription,
                            priority: selectedPriority,
                            category: selectedCategory
                        )
                        tasks.append(newTask)
                        onTaskAdded()
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}
