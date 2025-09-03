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
            Color(ThemeColors.backgroundDark)
            
            VStack(spacing: 20) {
                Text("Zenith")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
    //
    //            Text("Def: the time at which something is most powerful or successful:")
    //                .font(.subheadline)
    //                .foregroundStyle(.secondary)
    //                .multilineTextAlignment(.center)
    //                .padding(.horizontal)
    //
                Spacer()
    //
    //            VStack(spacing: 8) {
    //                Text("🔥 Current Streak")
    //                    .cardTitle ()
    //
    //                Text ("7" )
    //                    .streakCounter ()
    //
    //                Text("Days completed!")
    //                    .achievementText ()
    //            }
    //            .achievementCard()
                
            }
        }
//        .background(ThemeColors.backgroundDark)
    }

}

//#Preview {
//    DashboardView()
//}
