//
//  ContentView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct ContentView: View {
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
    }
}

//#Preview {
//    ContentView()
//}
