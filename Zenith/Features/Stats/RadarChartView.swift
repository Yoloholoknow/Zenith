//
//  RadarChartView.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct RadarChartView: View {
    let data: [RadarDataPoint]
    let maxValue: Double
    @Binding var selectedCategory: RadarDataPoint?
    
    @State private var animationProgress: Double = 0
    @State private var previousDataHash: Int = 0
    
    init(
        data: [RadarDataPoint],
        maxValue: Double,
        selectedCategory: Binding<RadarDataPoint?>
    ) {
        self.data = data
        self.maxValue = maxValue
        self._selectedCategory = selectedCategory
    }

    private func showContextMenu(for category: RadarDataPoint, at index: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedCategory = data[index]
        }
        
        print("🔍 Showing context menu for \(category.label)")
    }

    var body: some View {
        GeometryReader { geometry in
            let totalInset: CGFloat = 40
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = (min(geometry.size.width, geometry.size.height) / 2) - totalInset
            
            ZStack {
                if !data.isEmpty {
                    RadarGridView(center: center, radius: radius, sides: data.count, levels: 5)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    
                    RadialLinesView(center: center, radius: radius, sides: data.count)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    
                    RadarDataShape(center: center, radius: radius, data: data, maxValue: maxValue, animationProgress: animationProgress)
                        .fill(LinearGradient(
                            colors: [ThemeColors.primaryBlue.opacity(0.3), ThemeColors.successGreen.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    RadarDataShape(center: center, radius: radius, data: data, maxValue: maxValue, animationProgress: animationProgress)
                        .stroke(ThemeColors.primaryBlue, lineWidth: 2)
                    
                    ForEach(data.indices, id: \.self) { index in
                        let point = dataPoint(for: data[index], at: index, center: center, radius: radius, maxValue: maxValue, animationProgress: animationProgress, totalPoints: data.count)
                        let isSelected = selectedCategory == data[index]
                        
                        Circle()
                            .fill(isSelected ? ThemeColors.streakGold : ThemeColors.primaryBlue)
                            .frame(width: isSelected ? 14 : 10, height: isSelected ? 14 : 10)
                            .position(point)
                            .scaleEffect(isSelected ? 1.3 : 1.0)
                            .shadow(color: isSelected ? ThemeColors.streakGold.opacity(0.5) : Color.clear, radius: isSelected ? 4 : 0)
                            .opacity(animationProgress)
                            .animation(.easeInOut(duration: 0.3), value: isSelected)
                            .animation(.easeInOut(duration: 1.0), value: animationProgress)
                            .onTapGesture {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedCategory = selectedCategory == data[index] ? nil : data[index]
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                impactFeedback.impactOccurred()
                                showContextMenu(for: data[index], at: index)
                            }
                            .contextMenu {
                                CategoryContextMenu(category: data[index])
                            }
                        
                        if isSelected {
                            VStack(spacing: 2) {
                                Text(data[index].label)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                
                                Text(String(format: "%.0f%%", data[index].value * 100))
                                    .font(.caption2)
                                    .foregroundColor(ThemeColors.successGreen)
                            }
                            .padding(6)
                            .background(ThemeColors.cardBackground)
                            .cornerRadius(6)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .position(x: point.x, y: point.y - 35)
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    
                    ForEach(data.indices, id: \.self) { index in
                        let labelPosition = labelPoint(for: index, center: center, radius: radius + (totalInset / 2), totalPoints: data.count)
                        let isSelected = selectedCategory == data[index]
                        
                        Text(data[index].label)
                            .font(.caption)
                            .fontWeight(isSelected ? .bold : .medium)
                            .foregroundColor(isSelected ? ThemeColors.primaryBlue : ThemeColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .frame(width: 60)
                            .position(labelPosition)
                            .opacity(animationProgress)
                            .animation(.easeInOut(duration: 0.2), value: isSelected)
                            .animation(.easeInOut(duration: 1.2), value: animationProgress)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedCategory = selectedCategory == data[index] ? nil : data[index]
                                }
                            }
                    }
                } else {
                    VStack(spacing: 8) {
                        Text("📊")
                            .font(.system(size: 40))
                            .opacity(0.5)
                        
                        Text("No data available")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Complete tasks to see your growth chart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .position(center)
                }
                
                VStack(spacing: 2) {
                    Text("Growth")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeColors.secondaryPurple)
                    
                    if let selectedCategory = selectedCategory, !data.isEmpty {
                        Text(String(format: "%.0f%%", selectedCategory.value * 100))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primaryBlue)
                    } else {
                        Text("Chart")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.secondaryPurple)
                    }
                }
                .position(center)
                .animation(.easeInOut(duration: 0.3), value: selectedCategory)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            startInitialAnimation()
        }
        .onChange(of: data) { newData in
            handleDataChange(newData)
        }
    }
    
    private func startInitialAnimation() {
        withAnimation(.easeInOut(duration: 1.5)) {
            animationProgress = 1.0
        }
        previousDataHash = data.hashValue
    }
    
    private func handleDataChange(_ newData: [RadarDataPoint]) {
        let newHash = newData.hashValue
        if newHash != previousDataHash {
            animationProgress = 0.0
            selectedCategory = nil
            
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
            
            previousDataHash = newHash
            print("📊 Radar chart animating with new data: \(newData.count) categories")
        }
    }
}

// Update helper function to include totalPoints parameter
func dataPoint(for data: RadarDataPoint, at index: Int, center: CGPoint, radius: Double, maxValue: Double, animationProgress: Double, totalPoints: Int) -> CGPoint {
    let angle = (Double(index) * 2 * .pi / Double(totalPoints)) - .pi / 2
    let normalizedValue = min(data.value / maxValue, 1.0)
    let animatedValue = normalizedValue * animationProgress
    let pointRadius = radius * animatedValue
    
    return CGPoint(
        x: center.x + cos(angle) * pointRadius,
        y: center.y + sin(angle) * pointRadius
    )
}
    
// Helper function to calculate label points on the radar chart
func labelPoint(for index: Int, center: CGPoint, radius: Double, totalPoints: Int) -> CGPoint {
    let angle = (Double(index) * 2 * .pi / Double(totalPoints)) - .pi / 2
    return CGPoint(
        x: center.x + cos(angle) * radius,
        y: center.y + sin(angle) * radius
    )
}

struct RadarGridView: Shape {
    let center: CGPoint
    let radius: Double
    let sides: Int
    let levels: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw concentric polygons
        for level in 1...levels {
            let levelRadius = radius * Double(level) / Double(levels)
            let points = polygonPoints(center: center, radius: levelRadius, sides: sides)
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.closeSubpath()
        }
        
        return path
    }
}

struct RadialLinesView: Shape {
    let center: CGPoint
    let radius: Double
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for i in 0..<sides {
            let angle = (Double(i) * 2 * .pi / Double(sides)) - .pi / 2
            let endPoint = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            path.move(to: center)
            path.addLine(to: endPoint)
        }
        
        return path
    }
}

// Helper function to calculate polygon points
func polygonPoints(center: CGPoint, radius: Double, sides: Int) -> [CGPoint] {
    var points: [CGPoint] = []
    
    for i in 0..<sides {
        let angle = (Double(i) * 2 * .pi / Double(sides)) - .pi / 2
        let point = CGPoint(
            x: center.x + cos(angle) * radius,
            y: center.y + sin(angle) * radius
        )
        points.append(point)
    }
    
    return points
}

struct RadarDataPoint: Hashable {
    let label: String
    let value: Double
    let color: Color
    
    init(label: String, value: Double, color: Color = .blue) {
        self.label = label
        self.value = value
        self.color = color
    }
}
    
struct RadarDataShape: Shape {
    let center: CGPoint
    let radius: Double
    let data: [RadarDataPoint]
    let maxValue: Double
    var animationProgress: Double
    
    var animatableData: Double {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        guard !data.isEmpty else { return Path() }
        
        var path = Path()
        let points = dataPoints()
        
        if points.isEmpty { return path }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
    
    private func dataPoints() -> [CGPoint] {
        var points: [CGPoint] = []
        
        for (index, dataPoint) in data.enumerated() {
            let angle = (Double(index) * 2 * .pi / Double(data.count)) - .pi / 2
            let normalizedValue = min(dataPoint.value / maxValue, 1.0)
            let animatedValue = normalizedValue * animationProgress
            let pointRadius = radius * animatedValue
            
            let point = CGPoint(
                x: center.x + cos(angle) * pointRadius,
                y: center.y + sin(angle) * pointRadius
            )
            points.append(point)
        }
        
        return points
    }
}

enum QuickAction {
    case viewDetails
    case viewTasks
    case setFocusArea
    case getSuggestions
    case setDailyGoal
    case setWeeklyGoal
    case setMonthlyGoal
    case shareProgress
    
    var title: String {
        switch self {
        case .viewDetails: return "View Details"
        case .viewTasks: return "View Tasks"
        case .setFocusArea: return "Set as Focus Area"
        case .getSuggestions: return "Get Suggestions"
        case .setDailyGoal: return "Set Daily Goal"
        case .setWeeklyGoal: return "Set Weekly Goal"
        case .setMonthlyGoal: return "Set Monthly Goal"
        case .shareProgress: return "Share Progress"
        }
    }
    
    var icon: String {
        switch self {
        case .viewDetails: return "chart.bar.doc.horizontal"
        case .viewTasks: return "list.bullet"
        case .setFocusArea: return "target"
        case .getSuggestions: return "lightbulb"
        case .setDailyGoal: return "calendar"
        case .setWeeklyGoal: return "calendar.week"
        case .setMonthlyGoal: return "calendar.month"
        case .shareProgress: return "square.and.arrow.up"
        }
    }
}
