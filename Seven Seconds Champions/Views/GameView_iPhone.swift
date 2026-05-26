//
//  GameView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: MAIN VIEW
struct GameView_iPhone: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var gameManager = GameManager()
    
    @State private var isButtonDeployed = false
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    @State private var buttonFrame: CGRect = .zero {
        didSet {
            
        }
    }
    
    @State private var floatingPoints: [FloatingPoint] = []
    @State private var screenShakeOffset: CGFloat = 0.0
    @GestureState private var isPressed: Bool = false
    
    @State private var showLeaderboard = false
    @State private var isAnimationActive: Bool = false
    
    let impactGen = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    NormalBackground()
                        .ignoresSafeArea()
                    
                    ParticleView(isActive: $areParticlesActive)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 5) {
                            if let target = appState.challengeScoreToBeat {
                                Text("TARGET: \(target)")
                                    .font(.system(size: 42, weight: .black, design: .rounded))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .orange, radius: 4)
                            }
                            
                            Group {
                                if gameManager.isGameRunning {
                                    Text(String(format: "%.1f s", Double(gameManager.timeLeft)))
                                        .accessibilityIdentifier("TimerLabel")
                                } else {
                                    Text(String(format: "%.0f SECONDS", Double(gameManager.timeLeft)))
                                }
                            }
                            .font(.system(size: 28, weight: .black, design: .rounded)) // Mai mare, e titlul acum
                            .foregroundColor(gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .white)
                            .shadow(color: gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .neonCyan, radius: 10)
                        }
                        .padding(.top, 20)
                        
                        Spacer().frame(height: 30)
                        
                        ZStack {
                            RadialTimerView(timeLeft: gameManager.timeLeft)
                            
                            VStack(spacing: 0) {
                                Text("SCORE")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.neonCyan.opacity(0.8))
                                    .tracking(8)
                                
                                GlitchScoreView(
                                    score: gameManager.currentScore,
                                    isAnimating: gameManager.isGameRunning
                                )
                            }
                            .offset(y: -10)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            ArcButton(
                                isPressed: isPressed,
                                isDeployed: isButtonDeployed
                            )
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .updating($isPressed) { _, pressed, _ in
                                        pressed = true
                                    }
                                    .onEnded { _ in
                                        handleTap()
                                    }
                            )
                            
                            ForEach(floatingPoints) { point in
                                Text("+1")
                                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2)
                                    .scaleEffect(point.scale)
                                    .opacity(point.opacity)
                                    .offset(x: point.x, y: point.y)
                                    .onAppear {
                                        animateFloatingPoint(point)
                                    }
                            }
                        }
                        
                        Spacer()
                        
                        if let target = appState.challengeScoreToBeat {
                            
                        } else {
                            VStack(spacing: 20) {
                                Button {
                                    showLeaderboard = true
                                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                        GameCenterManager.shared.showLeaderboard(from: rootVC)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trophy.fill")
                                            .font(.title2)
                                        Text("RANKS")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.yellow.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 40)
                                .opacity(gameManager.isGameRunning ? 0 : 1)
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }
                .onAppear {
                    GameCenterManager.shared.authenticateLocalPlayer { success, _ in
                        print("GC Auth: \(success)")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        areParticlesActive = true
                    }
                    
                    impactGen.prepare()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isButtonDeployed = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $gameManager.isGameOver) {
                    GameOverView_iPhone(
                        gameManager: gameManager,
                        previousScore: $gameManager.previousScore
                    )
                    .onAppear {
                        isAnimationActive = false
                    }
                    .onDisappear {
                        gameManager.resetGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func handleTap() {
        guard !gameManager.isGameOver else { return }
        
        if !gameManager.isGameRunning {
            gameManager.startGame(
                emitterLayer: emitterLayer,
                buttonFrame: buttonFrame,
                challengeTarget: appState.challengeScoreToBeat
            )
            isAnimationActive = true
            impactGen.impactOccurred()
        } else {
            gameManager.currentScore += 1
            gameManager.buttonPressed()
            
            impactGen.impactOccurred(intensity: 1.0)
            triggerShake()
            spawnFloatingPoint()
        }
    }
        
    private func triggerShake() {
        let intensity: CGFloat = CGFloat.random(in: -8...8)
        
        withAnimation(.spring(response: 0.1, dampingFraction: 0.2, blendDuration: 0)) {
            screenShakeOffset = intensity
        }
    }
    
    private func spawnFloatingPoint() {
        let newPoint = FloatingPoint(
            x: CGFloat.random(in: -30 ... 30),
            y: CGFloat.random(in: -70 ... -50)
        )
        floatingPoints.append(newPoint)
    }
    
    private func animateFloatingPoint(_ point: FloatingPoint) {
        if let index = floatingPoints.firstIndex(where: { $0.id == point.id }) {
            withAnimation(.easeOut(duration: 0.8)) {
                floatingPoints[index].y = -320
                floatingPoints[index].opacity = 0
                floatingPoints[index].scale = 1.5
            }
            
            // Curățenie automată
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let idx = floatingPoints.firstIndex(where: { $0.id == point.id }) {
                    floatingPoints.remove(at: idx)
                }
            }
        }
    }
}

#Preview {
    GameView_iPhone()
        .environmentObject(AppState())
}

