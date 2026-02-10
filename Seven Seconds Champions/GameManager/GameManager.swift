    //
//  GameManager.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

enum ChallengeOutcome {
    case win, loss
}

class GameManager: ObservableObject {
    @Published var hits: Int = 0
    @Published var timeLeft: Double = 7
    @Published var currentScore: Int = 0
    @Published var previousScore: Int = 0
    @Published var isGameRunning: Bool = false
    @Published var isGameOver: Bool = false
    @Published var achievementMessage: String? = nil
    @Published var isNewHighScore: Bool = false
    
    private let userDefaults: UserDefaults
    
    private var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")
    private var timer: Timer?
    private let timerBeep: AVAudioPlayer?
    private let iceCracking: AVAudioPlayer?
    private let explodeBeep: AVAudioPlayer?
    private let buttonBeep: AVAudioPlayer?
    private var sparks = Sparks.shared
    
    @Published var challengeTarget: Int? = nil
    @Published var challengeOutcome: ChallengeOutcome? = nil

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.highScore = userDefaults.integer(forKey: "highScore")
        self.timerBeep = AudioPlayerFactory.createAudioPlayer(fileName: "timer", fileType: "wav")
        self.iceCracking = AudioPlayerFactory.createAudioPlayer(fileName: "ice-cracking", fileType: "mp3")
        self.explodeBeep = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
        self.buttonBeep = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        if let player = timerBeep, player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
    }

    func startGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect, challengeTarget: Int? = nil) {
        stopTimer()
        
        isNewHighScore = false
        isGameRunning = true
        currentScore = 0
        timeLeft = 7
        
        self.challengeTarget = challengeTarget
        self.challengeOutcome = nil
        
        iceCracking?.play()

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeLeft > 0 {
                self.timeLeft = max(0, self.timeLeft - 0.1)
                
                let isFullSecond = abs(self.timeLeft.truncatingRemainder(dividingBy: 1.0)) < 0.05
                
                if isFullSecond && self.timeLeft > 0 {
                    self.timerBeep?.play()
                }
                
                if self.timeLeft <= 0 {
                    self.stopTimer()
                    self.endGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                }
            }
        }
    }

    func endGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect) {
        stopTimer()
        
        isGameRunning = false
    
        explodeBeep?.play()
        
        if let target = self.challengeTarget {
            if currentScore > target {
                self.challengeOutcome = .win
            } else {
                self.challengeOutcome = .loss
            }
        } else {
            self.challengeOutcome = nil
        }
        
        if currentScore > highScore {
            highScore = currentScore
            self.userDefaults.set(highScore, forKey: "highScore")
            isNewHighScore = true
        }
        
        isGameOver = true
        
        if currentScore < 145 {
            GameCenterManager.shared.submitScore(with: currentScore)
        }
        
        achievementMessage = AchievementManager.shared.handleAchievements(for: currentScore)
    }

    func buttonPressed() {
        
    }

    func resetGame(emitterLayer: CAEmitterLayer?, buttonFrame: CGRect) {
        stopTimer()
        
        isGameRunning = false
        isGameOver = false
        timeLeft = 7
        currentScore = 0
        
        self.challengeTarget = nil
        self.challengeOutcome = nil
    }
}
