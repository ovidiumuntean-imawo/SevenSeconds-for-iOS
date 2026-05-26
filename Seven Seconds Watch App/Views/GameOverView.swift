//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView_Watch
struct GameOverView_Watch: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let challengeOutcome = gameManager.challengeOutcome, let target = gameManager.challengeTarget {
                ChallengeResultView_Watch(
                    challengeOutcome: challengeOutcome,
                    yourScore: gameManager.currentScore,
                    targetScore: target
                )
            } else {
                NormalGameOverView_Watch(
                    gameManager: gameManager,
                    previousScore: $previousScore
                )
            }
        }
        .onAppear {
            appState.challengeScoreToBeat = nil
        }
        .onChange(of: appState.newChallengeReceived) { _ in
            print("Provocare nouă primită în timp ce GameOver era deschis. Se închide...")
            dismiss()
        }
    }
}

// MARK: - ECRAN NORMAL GAME OVER WATCH
struct NormalGameOverView_Watch: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var showNewHighScoreAlert = false
    
    @State private var scaleTitle: CGFloat = 0.5
    @State private var opacityTitle: Double = 0
    @State private var scoreScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            RotatingBackground(isAnimating: false)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ParticlesView(particleCount: 30, particleSize: 2)
                    .frame(width: geo.size.width * 2, height: geo.size.height)
            }
            
            VStack(spacing: 8) {
                Text("GAME OVER")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .neonRed, radius: 5)
                    .scaleEffect(scaleTitle)
                    .opacity(opacityTitle)
                    .padding(.top, 10)
                
                VStack(spacing: -5) {
                    Text("YOU SCORED")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.neonCyan.opacity(0.8))
                    
                    Text("\(gameManager.currentScore)")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .neonCyan, radius: 6)
                        .scaleEffect(scoreScale)
                    
                    Text("TAPS")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                Button(action: {
                    restartGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("RETRY")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 16, design: .rounded))
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.neonBlue.opacity(0.8))
                .opacity(buttonOpacity)
                
                Spacer(minLength: 15)
            }
        }
        .onAppear {
            animateEntrance()
            
            if gameManager.isNewHighScore {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showNewHighScoreAlert = true
                }
            }
        }
    }
    
    private func restartGame() {
        previousScore = gameManager.currentScore
        dismiss()
    }
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            scaleTitle = 1.0
            opacityTitle = 1.0
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.2)) {
            scoreScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            buttonOpacity = 1.0
        }
    }
}

// MARK: - CHALLENGE RESULT WATCH (WIN/LOSS)
struct ChallengeResultView_Watch: View {
    @Environment(\.dismiss) private var dismiss
    var challengeOutcome: ChallengeOutcome
    var yourScore: Int
    var targetScore: Int
    
    @State private var scaleEffect: CGFloat = 0.5
    @State private var opacityEffect: Double = 0
    
    var isWin: Bool {
        return challengeOutcome == .win
    }
    
    var body: some View {
        ZStack {
            RotatingBackground(isAnimating: false).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 12) {
                    Image(systemName: isWin ? "trophy.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isWin ? .green : .red)
                        .shadow(color: isWin ? .green : .red, radius: 10)
                        .scaleEffect(scaleEffect)
                        .padding(.top, 10)
                    
                    Text(isWin ? "MISSION\nACCOMPLISHED" : "MISSION\nFAILED")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(isWin ? .green : .red)
                        .shadow(color: isWin ? .green.opacity(0.5) : .red.opacity(0.5), radius: 5)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("TARGET:")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(targetScore)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        HStack {
                            Text("YOU:")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(yourScore)")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundColor(isWin ? .green : .red)
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isWin ? Color.green.opacity(0.5) : Color.red.opacity(0.5), lineWidth: 1)
                    )
                    .opacity(opacityEffect)
                    
                    Button(action: { dismiss() }) {
                        Text("RETURN")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 10)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scaleEffect = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                opacityEffect = 1.0
            }
        }
    }
}

#Preview("Normal - High Score") {
    @Previewable @State var previousScore = 30
    
    let manager = GameManager()
    manager.currentScore = 42
    manager.isNewHighScore = true
    
    return GameOverView_Watch(
        gameManager: manager,
        previousScore: $previousScore
    )
    .environmentObject(AppState())
}
