//
//  AppState.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 03.07.2025.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var challengeScoreToBeat: Int? = nil
    @Published var newChallengeReceived: UUID? = nil
}
