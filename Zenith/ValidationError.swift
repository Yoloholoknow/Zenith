//
//  ValidationError.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct ValidationAlertView: View {
    let validationResults: ValidationResults
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: validationResults.hasIssues ? "wrench.and.screwdriver" : "checkmark.shield")
                            .font(.system(size: 50))
                            .foregroundColor(validationResults.hasIssues ? ThemeColors.warningOrange : ThemeColors.successGreen)
                        
                        Text(validationResults.hasIssues ? "Data Issues Corrected" : "Data Health Check Complete")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(validationResults.hasIssues ? "We found and automatically fixed some data issues to keep your progress safe." : "All your data looks great! No issues found.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    
                    if validationResults.hasIssues {
                        // Issues Found Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Issues Found & Fixed")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            if validationResults.taskIssues > 0 {
                                HStack {
                                    Image(systemName: "list.bullet")
                                        .foregroundColor(ThemeColors.primaryBlue)
                                    VStack(alignment: .leading) {
                                        Text("Tasks")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Fixed \(validationResults.taskIssues) task data issues")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("✓")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.successGreen)
                                }
                            }
                            
                            if validationResults.streakIssues > 0 {
                                HStack {
                                    Image(systemName: "flame")
                                        .foregroundColor(ThemeColors.warningOrange)
                                    VStack(alignment: .leading) {
                                        Text("Streak")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Corrected streak calculation errors")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("✓")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.successGreen)
                                }
                            }
                            
                            if validationResults.pointIssues > 0 {
                                HStack {
                                    Image(systemName: "star")
                                        .foregroundColor(ThemeColors.streakGold)
                                    VStack(alignment: .leading) {
                                        Text("Points")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Fixed level and point calculation issues")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("✓")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(ThemeColors.successGreen)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGroupedBackground))
                        .cornerRadius(12)
                    }
                    
                    // Protection Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Data is Protected")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "shield.checkered")
                                    .foregroundColor(ThemeColors.successGreen)
                                Text("Automatic validation on every app launch")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(ThemeColors.primaryBlue)
                                Text("Smart data repair for common issues")
                                    .font(.subheadline)
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "externaldrive")
                                    .foregroundColor(ThemeColors.secondaryPurple)
                                Text("Automatic backup creation and restore")
                                    .font(.subheadline)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGroupedBackground))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Data Validation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct ValidationResults {
    let taskIssues: Int
    let streakIssues: Int
    let pointIssues: Int
    
    var hasIssues: Bool {
        taskIssues > 0 || streakIssues > 0 || pointIssues > 0
    }
    
    var totalIssues: Int {
        taskIssues + streakIssues + pointIssues
    }
}
