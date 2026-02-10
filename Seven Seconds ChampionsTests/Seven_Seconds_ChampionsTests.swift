//
//  Seven_Seconds_ChampionsTests.swift
//  Seven Seconds ChampionsTests
//
//  Created by Ovidiu Muntean on 08.01.2025.
//

import Testing
import Foundation
@testable import Seven_Seconds_Champions

struct Seven_Seconds_ChampionsTests {
    
    let gameManager: GameManager
    let mockDefaults: UserDefaults
    
    init() async throws {
        let suiteName = "TestSandbox"
        UserDefaults().removePersistentDomain(forName: suiteName)
        
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            throw CheckheadError.defaultsFailed
        }
        self.mockDefaults = defaults
        
        self.gameManager = GameManager(userDefaults: defaults)
    }
    
    @Test("Verifică starea inițială a jocului")
    func checkInitialState() {
        #expect(gameManager.isGameRunning == false)
        #expect(gameManager.timeLeft == 7.0)
        #expect(gameManager.currentScore == 0)
    }
    
    @Test("Verifică salvarea High Score-ului")
    func checkHighScoreSaving() {
        gameManager.currentScore = 100
        
        gameManager.endGame(emitterLayer: nil, buttonFrame: .zero)
        
        #expect(gameManager.isNewHighScore == true)
        #expect(mockDefaults.integer(forKey: "highScore") == 100)
    }
    
    @Test("Verifică logica de Challenge (Win)")
    func checkChallengeWin() {
        gameManager.startGame(emitterLayer: nil, buttonFrame: .zero, challengeTarget: 20)
        
        gameManager.currentScore = 21
        gameManager.endGame(emitterLayer: nil, buttonFrame: .zero)
        
        #expect(gameManager.challengeOutcome == .win)
    }
    
    @Test("Verifică logica de Challenge (Loss)")
    func checkChallengeLoss() {
        gameManager.startGame(emitterLayer: nil, buttonFrame: .zero, challengeTarget: 20)
        
        gameManager.currentScore = 19
        gameManager.endGame(emitterLayer: nil, buttonFrame: .zero)
        
        #expect(gameManager.challengeOutcome == .loss)
    }
}

enum CheckheadError: Error {
    case defaultsFailed
}
