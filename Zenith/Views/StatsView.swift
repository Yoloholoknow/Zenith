//
//  StatsView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct StatsView: View {
    var body: some View {
        VStack {
            Text("Progress Stats")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.1))
                .frame(height: 100)
                .overlay(
                    VStack() {
                        Image(systemName: "flame")
                            .font(.title)
                            .foregroundStyle(.orange)
                        Text("5 Day Streak")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                )
            
            VStack(spacing: 12) {
                Text ("Weekly Progress")
                    .cardTitle()
                
                HStack {
                    VStack {
                        Text("85%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(ThemeColors.successGreen)
                        Text ("Completed" )
                            .captionText()
                    }
                    
                    Spacer ()
                    
                    Button("View Chart") {
                        print("Chart button tapped")
                    }
                    .buttonStyle (SecondaryButtonStyle())
                }
            }
            .statsCard()
            
            Text("Interactive radar chart and progress metrics will appear here")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text("📊 Visualize your personal growth journey")
                .font(.headline)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Growth Areas")
                    .font(.headline)
                
                HStack {
                    Text("Productivity")
                    Spacer()
                    Text("75%")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Health")
                    Spacer()
                    Text("60%")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Learning")
                    Spacer()
                    Text("80%")
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .background(ThemeColors.backgroundDark)
    }
}

//#Preview {
//    StatsView()
//}
