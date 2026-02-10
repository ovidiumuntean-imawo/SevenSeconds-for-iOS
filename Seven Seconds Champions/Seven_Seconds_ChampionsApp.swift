//
//  Seven_Seconds_ChampionsApp.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 08.01.2025.
//

import SwiftUI
import SwiftData

@main
struct Seven_Seconds_ChampionsApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    guard url.scheme == "sevenseconds", url.host == "challenge" else { return }
                    
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    if let scoreItem = components?.queryItems?.first(where: { $0.name == "score" }) {
                        if let scoreValue = scoreItem.value, let score = Int(scoreValue) {
                            appState.challengeScoreToBeat = score
                            appState.newChallengeReceived = UUID()
                        }
                    }
                }
        }
    }
}
