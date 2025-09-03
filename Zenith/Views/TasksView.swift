//
//  TasksView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct TasksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Daily Tasks")
                .cardTitle()
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.horizontal)
            
            Text("Your personalized tasks and rewards will appear here")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
                Text("Today's Tasks")
                    .cardTitle()
                
                Text("Complete 3 daily goals to maintain your streak")
                    .bodyText()
                
                Button("View Tasks") {
                    print("Tasks button tapped")
                }
                .buttonStyle(PrimaryButtonStyle())
            
            Text("🏆 Streak tracking coming soon")
                .font(.headline)
                .foregroundStyle(.orange)
            
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "star.circle")
                        .foregroundStyle(.yellow)
                    Text("Complete morning routine")
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .foregroundStyle(.green)
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "book.circle")
                        .foregroundStyle(.blue)
                    Text("Read for 15 minutes")
                    Spacer()
                    Image(systemName: "circle")
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
//        .dashboardCard()
        .background(ThemeColors.backgroundDark)
    }
}

//#Preview {
//    TasksView()
//}
