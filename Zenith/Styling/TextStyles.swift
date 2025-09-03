//
//  TextStyles.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

extension Text {
    func dashboardTitle() -> some View {
        self
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(ThemeColors.textPrimary)
    }
    
    func cardTitle() -> some View {
        self
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(ThemeColors.textPrimary)
    }
    
    func bodyText() -> some View {
        self
            .font(. body)
            .foregroundStyle(ThemeColors.textSecondary)
    }
    
    func captionText() -> some View {
        self
            .font(.caption)
            .foregroundStyle(ThemeColors.textSecondary)
    }
    
    func achievementText() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(ThemeColors.streakGold)
    }
    
    func streakCounter() -> some View {
        self
            .font(.title)
            .fontWeight(.heavy)
            .foregroundStyle(ThemeColors.streakGold)
    }
    
    func successText() -> some View {
        self
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(ThemeColors.successGreen)
        
    }
}
