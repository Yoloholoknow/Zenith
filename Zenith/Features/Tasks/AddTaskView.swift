//
//  AddTaskView.swift
//  Zenith
//
//  Created by Charles Huang on 9/7/25.
//

import SwiftUI

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

