//
//  Seven_SecondsApp.swift
//  Seven Seconds Watch App
//
//  Created by Ovidiu Muntean on 11.01.2025.
//

import SwiftUI

@main
struct Seven_Seconds_Watch_AppApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
