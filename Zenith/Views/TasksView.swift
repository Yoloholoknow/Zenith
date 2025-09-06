//
//  TasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

//import SwiftUI
//
//struct TasksView: View {
//    @State private var showingTaskDetail = false
//    @State private var tasks: [Task] = []
//    @State private var taskToEdit: Task? = nil
//    @EnvironmentObject var pointsManager: PointsManager
//    @EnvironmentObject var dataManager: DataManager
//    @StateObject private var showingAPISettings = false
//    @StateObject private var llmService = LLMService.shared
//    @StateObject private var networkManager = NetworkManager.shared
//    
//    private func loadTasksData() {
//        print("📝 ContentView: Loading validated task data")
//        tasks = DataManager.shared.loadTasksWithValidation()
//        print("📝 ContentView: Loaded \(tasks.count) validated tasks")
//    }
//    private func saveTasksData() {
//        DataManager.shared.saveTasks(tasks)
//    }
//    
//    private func toggleTaskCompletion(_ task: Task) {
//        withAnimation(.easeIn(duration: 0.3)) {
//            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//                tasks[index].isCompleted.toggle()
//                if tasks[index].isCompleted {
//                    tasks[index].markAsCompleted()
//                    pointsManager.awardPointsForTask(tasks[index])
//                } else {
//                    tasks[index].markAsIncomplete()
//                }
//                
//                saveTasksData()
//            }
//        }
//    }
//    
//    private func deleteTask(at offsets: IndexSet) {
//        tasks.remove(atOffsets: offsets)
//        saveTasksData()
//    }
//    
//    private func priorityColor(for priority: TaskPriority) -> Color {
//        switch priority {
//        case .low:
//            return .gray
//        case .medium:
//            return ThemeColors.primaryBlue
//        case .high:
//            return ThemeColors.warningOrange
//        case .critical:
//            return Color.red
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            NavigationView {
//                List {
//                    ForEach(tasks.sorted(by: { !$0.isCompleted && $1.isCompleted })) { task in
//                        HStack(spacing: 12) {
//                            Button(action: {
//                                toggleTaskCompletion(task)
//                            }) {
//                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
//                                    .foregroundColor(task.isCompleted ? ThemeColors.successGreen : .gray)
//                                    .font(.title2)
//                            }
//                            
//                            VStack(alignment: .leading, spacing: 6) {
//                                HStack {
//                                    Text(task.title)
//                                        .font(.headline)
//                                        .strikethrough(task.isCompleted)
//                                        .foregroundColor(task.isCompleted ? .gray : ThemeColors.textLight)
//                                    
//                                    Spacer()
//                                    
//                                    Text(task.priority.rawValue)
//                                        .font(.caption)
//                                        .padding(.horizontal, 8)
//                                        .padding(.vertical, 2)
//                                        .background(priorityColor(for: task.priority))
//                                        .cornerRadius(8)
//                                        .foregroundColor(.white)
//                                }
//                                
//                                if !task.description.isEmpty {
//                                    Text(task.description)
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                        .lineLimit(2)
//                                }
//                                
//                                HStack {
//                                    Text(task.category.rawValue)
//                                        .font(.caption)
//                                        .foregroundColor(ThemeColors.secondaryPurple)
//                                    
//                                    Spacer()
//                                    
//                                    if task.isCompleted {
//                                        Text("+\(task.pointsEarned) points")
//                                            .font(.caption)
//                                            .foregroundColor(ThemeColors.successGreen)
//                                            .fontWeight(.medium)
//                                    } else {
//                                        Text("\(task.potentialPoints) points")
//                                            .font(.caption)
//                                            .foregroundColor(.gray)
//                                    }
//                                }
//                            }
//                            .contentShape(Rectangle())
//                            .onTapGesture {
//                                self.taskToEdit = task
//                                self.showingTaskDetail = true
//                            }
//                        }
//                        .padding(.vertical, 4)
//                        .listRowBackground(ThemeColors.cardBackground)
//                    }
//                    .onDelete(perform: deleteTask)
//                }
//                .background(ThemeColors.backgroundDark.ignoresSafeArea())
//                .scrollContentBackground(.hidden)
//                .navigationTitle("My Tasks")
//            }
//            .onAppear {
//                self.loadTasksData()
//            }
//            .background(ThemeColors.backgroundDark.ignoresSafeArea())
//            .overlay(
//                Button(action: {
//                    self.taskToEdit = nil
//                    self.showingTaskDetail = true
//                }) {
//                    Image(systemName: "plus")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 56, height: 56)
//                        .background(Color.blue)
//                        .clipShape(Circle())
//                        .shadow(radius: 4)
//                }
//                .padding()
//                , alignment: .bottomTrailing
//            )
//            .sheet(isPresented: $showingTaskDetail) {
//                TaskDetailView(tasks: $tasks, taskToEdit: $taskToEdit) {
//                    self.saveTasksData()
//                }
//            }
//            
//            // Celebration overlay
//            if pointsManager.showCelebration {
//                CelebrationOverlay(
//                    pointsAwarded: pointsManager.lastAwardedPoints,
//                    isLevelUp: pointsManager.isLevelUp
//                )
//                .transition(.opacity)
//                .zIndex(1)
//            }
//        }
//    }
//}
//
//struct TaskDetailView: View {
//    @Binding var tasks: [Task]
//    @Binding var taskToEdit: Task?
//    
//    @State private var taskTitle: String = ""
//    @State private var taskDescription: String = ""
//    @State private var selectedPriority: TaskPriority = .medium
//    
//    @Environment(\.dismiss) var dismiss
//    
//    let onTaskAdded: () -> Void
//    
//    var isEditing: Bool {
//        return taskToEdit != nil
//    }
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Task Details").foregroundColor(ThemeColors.textLight)) {
//                    TextField("Task title", text: $taskTitle)
//                        .listRowBackground(ThemeColors.cardBackground)
//                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
//                        .lineLimit(3...6)
//                        .listRowBackground(ThemeColors.cardBackground)
//                    
//                    Picker("Priority", selection: $selectedPriority) {
//                        ForEach(TaskPriority.allCases, id: \.self) { priority in
//                            Text(priority.rawValue)
//                                .tag(priority)
//                                .foregroundColor(ThemeColors.textLight)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .listRowBackground(ThemeColors.cardBackground)
//                }
//                .textCase(nil)
//            }
//            .onAppear {
//                if let task = taskToEdit {
//                    taskTitle = task.title
//                    taskDescription = task.description
//                    selectedPriority = task.priority
//                }
//            }
//            .preferredColorScheme(.dark)
//            .background(ThemeColors.backgroundDark)
//            .scrollContentBackground(.hidden)
//            .navigationTitle(isEditing ? "Edit Task" : "Add New Task")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        if isEditing {
//                            if let index = tasks.firstIndex(where: { $0.id == taskToEdit?.id }) {
//                                tasks[index].title = taskTitle
//                                tasks[index].description = taskDescription
//                                tasks[index].priority = selectedPriority
//                            }
//                        } else {
//                            let newTask = Task(
//                                title: taskTitle,
//                                description: taskDescription,
//                                priority: selectedPriority
//                            )
//                            tasks.append(newTask)
//                            onTaskAdded()
//                        }
//                        dismiss()
//                    }
//                    .disabled(taskTitle.isEmpty)
//                }
//            }
//        }
//    }
//}

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
                                    .foregroundColor(task.isCompleted ? .gray : ThemeColors.textPrimary)
                                
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
                                    .foregroundColor(.secondary)
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
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .onDelete(perform: deleteTask)
            }
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
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(isPresented: $showingAddTask, tasks: $tasks, onTaskAdded: saveTasksData)
            }
            .sheet(isPresented: $showingAIGeneration) {
                AITaskGenerationView(tasks: $tasks, onTasksAdded: saveTasksData)
            }
            .onAppear {
                loadTasksData()
            }
        }
    }
    
    private func loadTasksData() {
        tasks = DataManager.shared.loadTasksWithValidation()
    }
    
    private func saveTasksData() {
        DataManager.shared.saveTasks(tasks)
    }
    
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            _ = tasks[index].isCompleted
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
            return .gray
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
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $taskTitle)
                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
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
                        onTaskAdded() // This calls saveTasksData() which posts the notification
                        print("➕ Created new task: \(newTask.title) in \(newTask.category.rawValue) category")
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

private func saveTasksData() {
    DataManager.shared.saveTasks(tasks)
    // Notify stats manager that tasks have been updated
    NotificationCenter.default.post(name: .tasksUpdated, object: nil)
    print("📝 Tasks saved and stats notified")
}

private func toggleTaskCompletion(_ task: Task) {
    if let index = tasks.firstIndex(where: { $0.id == task.id }) {
        let wasCompleted = tasks[index].isCompleted
        
        if wasCompleted {
            tasks[index].markAsIncomplete()
        } else {
            tasks[index].markAsCompleted()
            pointsManager.awardPoints(for: tasks[index])
        }
        
        saveTasksData()
        print("✅ Task '\(task.title)' completion toggled to \(tasks[index].isCompleted)")
    }
}

private func deleteTask(at offsets: IndexSet) {
    let deletedTasks = offsets.map { tasks[$0].title }
    tasks.remove(atOffsets: offsets)
    saveTasksData()
    print("🗑️ Deleted tasks: \(deletedTasks.joined(separator: ", "))")
}
