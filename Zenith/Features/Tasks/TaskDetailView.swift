//
//  TaskDetailView.swift
//  Zenith
//
//  Created by Charles Huang on 9/7/25.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var isPresented: Bool
    @Binding var tasks: [Task]
    @State private var taskTitle: String
    @State private var taskDescription: String
    @State private var selectedPriority: TaskPriority
    @State private var selectedCategory: TaskCategory
    
    var existingTask: Task?
    
    init(isPresented: Binding<Bool>, tasks: Binding<[Task]>, task: Task? = nil) {
        self._isPresented = isPresented
        self._tasks = tasks
        self.existingTask = task
        
        _taskTitle = State(initialValue: task?.title ?? "")
        _taskDescription = State(initialValue: task?.description ?? "")
        _selectedPriority = State(initialValue: task?.priority ?? .medium)
        _selectedCategory = State(initialValue: task?.category ?? .other)
    }
    
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
            .navigationTitle(existingTask == nil ? "Add New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let existingIndex = tasks.firstIndex(where: { $0.id == existingTask?.id }) {
                            // Edit existing task
                            tasks[existingIndex].title = taskTitle
                            tasks[existingIndex].description = taskDescription
                            tasks[existingIndex].priority = selectedPriority
                            tasks[existingIndex].category = selectedCategory
                        } else {
                            // Add new task
                            let newTask = Task(
                                title: taskTitle,
                                description: taskDescription,
                                priority: selectedPriority,
                                category: selectedCategory
                            )
                            tasks.append(newTask)
                        }
                        
                        DataManager.shared.saveTasks(tasks)
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}
