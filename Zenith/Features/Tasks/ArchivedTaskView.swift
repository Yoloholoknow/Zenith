//
//  ArchivedTasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/7/25.
//

import SwiftUI

struct ArchivedTasksView: View {
    @State private var searchText: String = ""
    @State private var selectedCategory: TaskCategory? = nil
    @State private var selectedPriority: TaskPriority? = nil
    @State private var showingFilters: Bool = false
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var pointsManager: PointsManager
    @EnvironmentObject var streakManager: StreakManager
    
    var filteredTasks: [Task] {
        var tasksToFilter = dataManager.archivedTasks
        
        // Filter by search text
        if !searchText.isEmpty {
            tasksToFilter = tasksToFilter.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by category
        if let category = selectedCategory {
            tasksToFilter = tasksToFilter.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = selectedPriority {
            tasksToFilter = tasksToFilter.filter { $0.priority == priority }
        }
        
        return tasksToFilter.sorted(by: { $0.completedDate ?? Date.distantPast > $1.completedDate ?? Date.distantPast })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search tasks...", text: $searchText)
                        .padding(8)
                        .background(ThemeColors.cardBackground)
                        .cornerRadius(8)
                        .foregroundColor(ThemeColors.textPrimary)
                        .tint(ThemeColors.textPrimary)
                    
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title2)
                            .foregroundColor(ThemeColors.primaryBlue)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if showingFilters {
                    filterView()
                }
                
                if filteredTasks.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(ThemeColors.textSecondary)
                        Text("No matching tasks found")
                            .font(.headline)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dataManager.archivedTasks.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 50))
                            .foregroundColor(ThemeColors.textSecondary)
                        Text("Your archive is empty")
                            .font(.headline)
                            .foregroundColor(ThemeColors.textSecondary)
                        Text("Completed tasks will appear here.")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                List {
                    ForEach(filteredTasks) { task in
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    unsubmitTask(task)
                                }
                            }) {
                                Image(systemName: "arrow.uturn.left.circle")
                                    .foregroundColor(ThemeColors.warningOrange)
                                    .font(.title2)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(task.title)
                                        .font(.headline)
                                        .strikethrough()
                                        .foregroundColor(ThemeColors.textPrimary)
                                    Spacer()
                                    Text(task.priority.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(priorityColor(for: task.priority))
                                        .cornerRadius(8)
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

                                    Text("Completed: \(task.completedDate?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")")
                                        .font(.caption)
                                        .foregroundColor(ThemeColors.textSecondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(ThemeColors.cardBackground)
                    }
                }
                .background(ThemeColors.backgroundDark.ignoresSafeArea())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.inline)
            .background(ThemeColors.backgroundDark.ignoresSafeArea())
        }
    }
    
    @ViewBuilder
    private func filterView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by:")
                .font(.headline)
                .foregroundColor(ThemeColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Category Filters
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        FilterButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = selectedCategory == category ? nil : category
                            }
                        )
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Priority Filters
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        FilterButton(
                            title: priority.rawValue,
                            isSelected: selectedPriority == priority,
                            action: {
                                selectedPriority = selectedPriority == priority ? nil : priority
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .dashboardCard()
    }

    private func unsubmitTask(_ task: Task) {
        // Remove points and update streak first
        pointsManager.removePointsForTask(task)
        if let completedDate = task.completedDate {
            streakManager.removeCompletion(on: completedDate)
        }
        
        // Remove from archive and add back to main task list
        dataManager.unarchiveTask(task)
        
        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
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

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? ThemeColors.textLight : ThemeColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? ThemeColors.primaryBlue : ThemeColors.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? ThemeColors.primaryBlue : ThemeColors.textSecondary.opacity(0.5), lineWidth: 1)
                )
        }
    }
}
