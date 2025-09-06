//
//  ProgressLineChart.swift
//  Zenith
//
//  Created by Charles Huang on 9/6/25.
//

import SwiftUI

struct ProgressLineChart: View {
    let data: [WeeklyProgress]
    let color: Color
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Over Time")
                .font(.headline)
                .fontWeight(.semibold)
            
            if data.isEmpty {
                VStack(spacing: 8) {
                    Text("📈")
                        .font(.title2)
                        .opacity(0.5)
                    
                    Text("Not enough data for trend analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                GeometryReader { geometry in
                    ZStack {
                        // Grid lines
                        Path { path in
                            let stepY = geometry.size.height / 4
                            for i in 0...4 {
                                let y = CGFloat(i) * stepY
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                            }
                        }
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        
                        // Data line
                        Path { path in
                            guard !data.isEmpty else { return }
                            
                            let maxRate = data.map { $0.completionRate }.max() ?? 1.0
                            let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                            
                            for (index, progress) in data.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = geometry.size.height - (CGFloat(progress.completionRate / maxRate) * geometry.size.height * animationProgress)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        
                        // Data points
                        ForEach(data.indices, id: \.self) { index in
                            let maxRate = data.map { $0.completionRate }.max() ?? 1.0
                            let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                            let x = CGFloat(index) * stepX
                            let y = geometry.size.height - (CGFloat(data[index].completionRate / maxRate) * geometry.size.height * animationProgress)
                            
                            Circle()
                                .fill(color)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                                .opacity(animationProgress)
                        }
                        
                        // Y-axis labels
                        VStack {
                            ForEach(0..<5) { i in
                                HStack {
                                    Text("\(Int((1.0 - Double(i) * 0.25) * 100))%")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                
                                if i < 4 { Spacer() }
                            }
                        }
                    }
                }
                .frame(height: 120)
                
                // X-axis labels
                HStack {
                    ForEach(data.indices, id: \.self) { index in
                        if index % max(data.count / 4, 1) == 0 || index == data.count - 1 {
                            VStack(spacing: 2) {
                                Text(formatDate(data[index].weekStart))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

#Preview {
    ProgressLineChart(
        data: [
            WeeklyProgress(weekStart: Date().addingTimeInterval(-6 * 7 * 24 * 60 * 60), totalTasks: 10, completedTasks: 6, completionRate: 0.6),
            WeeklyProgress(weekStart: Date().addingTimeInterval(-5 * 7 * 24 * 60 * 60), totalTasks: 8, completedTasks: 7, completionRate: 0.875),
            WeeklyProgress(weekStart: Date().addingTimeInterval(-4 * 7 * 24 * 60 * 60), totalTasks: 12, completedTasks: 8, completionRate: 0.67),
            WeeklyProgress(weekStart: Date().addingTimeInterval(-3 * 7 * 24 * 60 * 60), totalTasks: 9, completedTasks: 9, completionRate: 1.0),
            WeeklyProgress(weekStart: Date().addingTimeInterval(-2 * 7 * 24 * 60 * 60), totalTasks: 11, completedTasks: 7, completionRate: 0.64),
            WeeklyProgress(weekStart: Date().addingTimeInterval(-1 * 7 * 24 * 60 * 60), totalTasks: 15, completedTasks: 12, completionRate: 0.8)
        ],
        color: ThemeColors.primaryBlue
    )
    .padding()
}

#Preview {
    ProgressLineChart()
}
