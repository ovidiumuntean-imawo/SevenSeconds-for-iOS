//
//  AppState.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 26/05/2026.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var challengeScoreToBeat: Int? = nil
    @Published var newChallengeReceived: UUID? = nil
}
