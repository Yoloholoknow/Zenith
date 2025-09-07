//
//  ButtonStyles.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody (configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ThemeColors.textLight)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background (ThemeColors.primaryBlue)
            .cornerRadius (12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: ThemeColors.primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
        
struct SuccessButtonStyle: ButtonStyle {
    func makeBody (configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ThemeColors.textLight)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(ThemeColors.successGreen)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .shadow(color: ThemeColors.successGreen.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
 
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody (configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundStyle(ThemeColors.secondaryPurple)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(ThemeColors.cardBackground)
            .cornerRadius(8)
            .overlay (
                RoundedRectangle (cornerRadius: 8)
                    .stroke (ThemeColors.secondaryPurple, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
