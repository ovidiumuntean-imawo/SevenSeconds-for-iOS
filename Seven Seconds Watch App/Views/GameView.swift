//
//  GameView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import WatchKit

struct GameView_Watch: View {
    @StateObject private var gameManager = GameManager()
    @GestureState private var isPressed: Bool = false
    
    var body: some View {
        ZStack {
            RotatingBackground(isAnimating: gameManager.isGameRunning).ignoresSafeArea()
            ParticlesView(particleCount: 20, particleSize: 2)
            
            VStack(spacing: 10) {
                Text(String(format: "%.1f s", Double(gameManager.timeLeft)))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .white)
                    .padding(.top, 10)
                
                ZStack {
                    RadialTimerView_Watch(timeLeft: Double(gameManager.timeLeft))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(height: 100)
                    
                    VStack(spacing: -5) {
                        Text("SCORE")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.neonCyan)
                        
                        GlitchScoreView_Watch(
                            score: gameManager.currentScore,
                            isAnimating: gameManager.isGameRunning
                        )
                    }
                    .offset(y: -15)
                }
                .padding(.horizontal, 5)
                
                Spacer().frame(height: 0)
                
                ArcButton_Watch(isPressed: isPressed)
                    .frame(width: 65, height: 65)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isPressed) { _, pressed, _ in pressed = true }
                            .onEnded { _ in handleTap() }
                    )
                    .offset(y: -40)
                
                Spacer()
            }
        }
    }
    
    private func handleTap() {
        guard !gameManager.isGameOver else { return }
        WKInterfaceDevice.current().play(.click)
        
        if !gameManager.isGameRunning {
            gameManager.startGame()
        } else {
            gameManager.currentScore += 1
            gameManager.buttonPressed()
        }
    }
}

#Preview {
    GameView_Watch()
}
