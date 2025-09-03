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

//struct ContentView: View {
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Dashboard Header1
//                Text ("Personal Dashboard")
//                    .dashboardTitle()
//                    .padding(.top)
//                
//                // Sample Task Card
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Today's Tasks")
//                        .cardTitle()
//                    
//                    Text("Complete 3 daily goals to maintain your streak")
//                        .bodyText()
//                    
//                    Button("View Tasks") {
//                        print("Tasks button tapped")
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                }
//                .dashboardCard()
//                
//                // Sample Achievement Card
//                VStack(spacing: 8) {
//                    Text("🔥 Current Streak")
//                        .cardTitle ()
//                    
//                    Text ("7" )
//                        .streakCounter ()
//                    
//                    Text("Days completed!")
//                        .achievementText ()
//                }
//                .achievementCard()
//                
//                // Sample Stats Card
//                VStack(spacing: 12) {
//                    Text ("Weekly Progress")
//                        .cardTitle()
//                    
//                    HStack {
//                        VStack {
//                            Text("85%")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundStyle(ThemeColors.successGreen)
//                            Text ("Completed" )
//                                .captionText()
//                        }
//                        
//                        Spacer ()
//                        
//                        Button("View Chart") {
//                            print("Chart button tapped")
//                        }
//                        .buttonStyle (SecondaryButtonStyle())
//                    }
//                }
//                .statsCard()
//                    
//                Spacer (minLength: 20)
//            }
//            .padding(.horizontal, 16)
//        }
//        .background (ThemeColors.backgroundLight)
//    }
//}

//#Preview {
//    ContentView()
//}
