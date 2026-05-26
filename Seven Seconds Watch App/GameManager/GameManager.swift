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
    @Published var timeLeft: Double = 7.0
    @Published var currentScore: Int = 0
    @Published var previousScore: Int = 0
    @Published var isGameRunning: Bool = false
    @Published var isGameOver: Bool = false
    
    // Stări noi necesare pentru ecranele moderne de pe ceas
    @Published var isNewHighScore: Bool = false
    @Published var challengeTarget: Int? = nil
    @Published var challengeOutcome: ChallengeOutcome? = nil

    private var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")
    private var timer: Timer?
    
    private let timerBeep: AVAudioPlayer?
    private let iceCracking: AVAudioPlayer?
    private let explodeBeep: AVAudioPlayer?
    private let buttonBeep: AVAudioPlayer?

    init() {
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

    func startGame(challengeTarget: Int? = nil) {
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
                    self.endGame()
                }
            }
        }
    }

    func endGame() {
        stopTimer()
        isGameRunning = false
        
        explodeBeep?.play()
        isGameOver = true
    }

    func buttonPressed() {
        buttonBeep?.play()
    }

    func resetGame() {
        stopTimer()
        isGameRunning = false
        isGameOver = false
        timeLeft = 7.0
        currentScore = 0
        
        challengeTarget = nil
        challengeOutcome = nil
    }
}
