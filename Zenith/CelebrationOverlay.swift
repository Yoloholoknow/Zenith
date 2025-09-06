//
//  CelebrationOverlap.swift
//  Zenith
//
//  Created by Charles Huang on 9/4/25.
//

import SwiftUI

struct CelebrationOverlay: View {
    let pointsAwarded: Int
    let isLevelUp: Bool
    @State private var animate = false
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Main celebration content
                VStack(spacing: 16) {
                    if isLevelUp {
                        Text("🎉")
                            .font(.system(size: 80))
                            .scaleEffect(animate ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true), value: animate)
                        
                        Text("LEVEL UP!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.streakGold)
                        
                        Text("+\(pointsAwarded) Points")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(ThemeColors.successGreen)
                    } else {
                        Text("⭐")
                            .font(.system(size: 60))
                            .scaleEffect(animate ? 1.3 : 1.0)
                            .animation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true), value: animate)
                        
                        Text("+\(pointsAwarded)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(ThemeColors.primaryBlue)
                        
                        Text("Points Earned!")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(ThemeColors.textPrimary)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
                .scaleEffect(animate ? 1.0 : 0.5)
                .opacity(animate ? 1.0 : 0.0)
            }
            
            // Animated particles
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            startAnimation()
            createParticles()
        }
    }
    
    private func startAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animate = true
        }
    }
    
    private func createParticles() {
        particles = (0..<20).map { _ in
            Particle(
                position: CGPoint(x: 200, y: 400),
                color: [ThemeColors.primaryBlue, ThemeColors.successGreen, ThemeColors.streakGold, ThemeColors.secondaryPurple].randomElement()!,
                size: Double.random(in: 8...16)
            )
        }
        
        // Animate particles
        for i in 0..<particles.count {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 1.0...2.0)
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = Double.random(in: 50...150)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    particles[i].position = CGPoint(
                        x: 200 + cos(angle) * distance,
                        y: 400 + sin(angle) * distance
                    )
                    particles[i].opacity = 0.0
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: Double
    var opacity: Double = 1.0
}
