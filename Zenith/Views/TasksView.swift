//
//  TasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct TasksView: View {
    @State private var showingAddTask = false
    @State private var tasks: [Task] = Task.sampleTasks()
    
//    private func toggleTaskCompletion(_ task: Task) {
//        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
//            tasks[index].isCompleted.toggle()
//        }
//    }
    
    private func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].markAsCompleted()
            } else {
                tasks[index].markAsIncomplete()
            }
        }
    }
    
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
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
    
    var body: some View {
        ZStack {
            ThemeColors.backgroundDark.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                NavigationView {
//                    VStack {
//                        Spacer()
//                        Text("No tasks yet")
//                            .foregroundColor(.gray)
//                        Spacer()
//                    }
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
                    .navigationTitle("My Tasks")
                    .overlay(
                        Button(action: {
                            showingAddTask = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        , alignment: .bottomTrailing
                    )
                    .sheet(isPresented: $showingAddTask) {
                        AddTaskView(isPresented: $showingAddTask, tasks: $tasks)
                    }
                }
                
//                Text("Daily Tasks")
//                    .cardTitle()
//                //                .font(.largeTitle)
//                //                .fontWeight(.bold)
//                //                .padding(.horizontal)
//                
//                Text("Your personalized tasks and rewards will appear here")
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                Text("Today's Tasks")
//                    .cardTitle()
//                
//                Text("Complete 3 daily goals to maintain your streak")
//                    .bodyText()
//                
//                Button("View Tasks") {
//                    print("Tasks button tapped")
//                }
//                .buttonStyle(PrimaryButtonStyle())
//                
//                Text("🏆 Streak tracking coming soon")
//                    .font(.headline)
//                    .foregroundStyle(.orange)
//                
//                VStack(spacing: 15) {
//                    HStack {
//                        Image(systemName: "star.circle")
//                            .foregroundStyle(.yellow)
//                        Text("Complete morning routine")
//                        Spacer()
//                        Image(systemName: "checkmark.circle")
//                            .foregroundStyle(.green)
//                    }
//                    .padding(.horizontal)
//                    
//                    HStack {
//                        Image(systemName: "book.circle")
//                            .foregroundStyle(.blue)
//                        Text("Read for 15 minutes")
//                        Spacer()
//                        Image(systemName: "circle")
//                            .foregroundStyle(.gray)
//                    }
//                    .padding(.horizontal)
//                }
//                
                Spacer()
            }
            .dashboardCard()
        }
    }
}

struct AddTaskView: View {
    @State private var taskTitle = ""
    @State private var taskDescription = ""
    @State private var selectedPriority: TaskPriority = .medium
    @Binding var isPresented: Bool
    @Binding var tasks: [Task]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $taskTitle)
                    TextField("Description (optional)", text: $taskDescription, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        Text("Low").tag(TaskPriority.low)
                        Text("Medium").tag(TaskPriority.medium)
                        Text("High").tag(TaskPriority.high)
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
                            priority: selectedPriority
                        )
                        tasks.append(newTask)
                        isPresented = false
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

//#Preview {
//    TasksView()
//}
