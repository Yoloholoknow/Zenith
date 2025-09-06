//
//  CategoryContextMenu.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct CategoryContextMenu: View {
    let category: RadarDataPoint
    
    var body: some View {
        VStack {
            // View detailed stats
            Button(action: {
                // This would trigger the detailed popup
                print("View details for \(category.label)")
            }) {
                Label("View Details", systemImage: "chart.bar.doc.horizontal")
            }
            
            // View related tasks
            Button(action: {
                print("View \(category.label) tasks")
                // This would filter tasks by category
            }) {
                Label("View Tasks", systemImage: "list.bullet")
            }
            
            Divider()
            
            // Set as focus area
            Button(action: {
                print("識 Setting \(category.label) as focus area")
                setAsFocusArea()
            }) {
                Label("Set as Focus Area", systemImage: "target")
            }
            
            // Get AI suggestions
            Button(action: {
                print("､Getting AI suggestions for \(category.label)")
                getAISuggestions()
            }) {
                Label("Get Suggestions", systemImage: "lightbulb")
            }
            
            Divider()
            
            // Quick goal setting
            Menu("Set Goal") {
                Button("Daily Goal") {
                    setDailyGoal()
                }
                Button("Weekly Goal") {
                    setWeeklyGoal()
                }
                Button("Monthly Goal") {
                    setMonthlyGoal()
                }
            } primaryAction: {
                Image(systemName: "flag")
            }
            
            // Share progress
            Button(action: {
                shareProgress()
            }) {
                Label("Share Progress", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    private func setAsFocusArea() {
        // Add to user preferences as a focus area
        print("識 Setting \(category.label) as focus area")
        
        // Haptic feedback for action completion
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func getAISuggestions() {
        // Trigger AI suggestion generation for this category
        print("､Getting AI suggestions for \(category.label)")
        
        // In a real implementation, this would:
        // 1. Analyze current performance
        // 2. Generate personalized suggestions
        // 3. Present them in a popup or notification
    }
    
    private func setDailyGoal() {
        print("套 Setting daily goal for \(category.label)")
        // This would open a goal-setting interface
    }
    
    private func setWeeklyGoal() {
        print("投 Setting weekly goal for \(category.label)")
        // This would open a goal-setting interface
    }
    
    private func setMonthlyGoal() {
        print("嶋 Setting monthly goal for \(category.label)")
        // This would open a goal-setting interface
    }
    
    private func shareProgress() {
        print("豆 Sharing progress for \(category.label)")
        // This would create a shareable progress report
        
        let progressText = "I'm at \(Int(category.value * 100))% completion in \(category.label) this week! 潮 #PersonalGrowth #GrowthDash"
        
        // In a real implementation, this would use UIActivityViewController
        // to share via Messages, Mail, Social Media, etc.
    }
}

#Preview {
    VStack {
        Text("Long press simulation")
            .contextMenu {
                CategoryContextMenu(
                    category: RadarDataPoint(
                        label: "Health",
                        value: 0.75,
                        color: ThemeColors.successGreen
                    )
                )
            }
    }
    .padding()
}
