//
//  DashboardView.swift
//  Zenith
//
//  Created by Charles Huang on 9/2/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            ThemeColors.backgroundDark.ignoresSafeArea()

            VStack(spacing: 10) {
                Text("Zenith")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .foregroundStyle(Color(red: 0.8, green: 0.2, blue: 1.0))
                
                Text("the time at which something is most powerful or successful")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
    
                Spacer()
    
                VStack(spacing: 8) {
                    Text("🔥 Current Streak")
                        .cardTitle ()
    
                    Text ("7" )
                        .streakCounter ()
    
                    Text("Days completed!")
                        .achievementText ()
                }
                .achievementCard()
                Spacer()
                
            }
        }
    }

}

//#Preview {
//    DashboardView()
//}
