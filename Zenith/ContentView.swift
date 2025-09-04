//
//  ContentView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var pointsManager = PointsManager()
    @StateObject private var streakManager = StreakManager()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TasksView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        // These two lines set the background color of the tab bar
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(ThemeColors.cardBackground, for: .tabBar)
        // This line sets the color for the selected icon
        .tint(ThemeColors.secondaryPurple)
        .environmentObject(pointsManager)
        .environmentObject(streakManager)
    }
}

#Preview {
    ContentView()
}
