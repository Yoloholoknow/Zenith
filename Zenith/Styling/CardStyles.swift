//
//  CardStyles.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

extension View {
    func dashboardCard() -> some View {
        self
            .padding(16)
            .background(ThemeColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    func primaryCard() -> some View {
        self
            .padding(16)
            .background(ThemeColors.primaryBlue)
            .cornerRadius(12)
            .shadow(color: ThemeColors.primaryBlue.opacity(0.3), radius: 6, x: 0, y: 3)
    }
    
    func achievementCard () -> some View {
        self
            .padding(16)
            .background (
                LinearGradient(
                    colors: [ThemeColors.streakGold.opacity(0.2),
                             ThemeColors.successGreen.opacity (0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius (12)
            .overlay (
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ThemeColors.streakGold.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: ThemeColors.streakGold.opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    func statsCard() -> some View {
        self
            .padding(20)
            .background(ThemeColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        
    }
}
