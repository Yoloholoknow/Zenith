//
//  ZenithApp.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

@main
struct ZenithApp: App {
    @StateObject private var pointsManager = PointsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pointsManager)
        }
    }
}
