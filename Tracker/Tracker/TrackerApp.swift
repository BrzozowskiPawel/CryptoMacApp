//
//  TrackerApp.swift
//  Tracker
//
//  Created by Paweł Brzozowski on 18/09/2022.
//

import SwiftUI

@main
struct TrackerApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
        }
    }
}
