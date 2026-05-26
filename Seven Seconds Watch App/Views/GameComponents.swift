//
//  GameComponents.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 26/05/2026.
//

import SwiftUI

// MARK: - Radial Timer Watch
struct RadialTimerView_Watch: View {
    var timeLeft: Double
    var totalTime: Double = 7.0
    
    @State private var gradientRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        let progress = Double(timeLeft) / totalTime
        let width: CGFloat = 110
        let height: CGFloat = 110
        let thickness: CGFloat = 8
        
        ZStack {
            // Fundalul inelului
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(Color.neonOrange.opacity(0.3), style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                .frame(width: width, height: height)
            
            // Inelul activ
            Circle()
                .trim(from: 0.5, to: 0.5 + (0.5 * progress))
                .stroke(
                    AngularGradient(colors: [.neonBlue, .neonCyan, .white, .neonOrange, .neonRed], center: .center, startAngle: .degrees(180), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .frame(width: width, height: height)
                .shadow(color: .neonCyan.opacity(0.5), radius: 5)
            
            // "Scânteia" din capătul inelului
            GeometryReader { geo in
                let radius = width / 2
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                let angleDegrees = 180 + (180 * progress)
                let angleRadians = angleDegrees * .pi / 180
                
                let x = centerX + radius * cos(angleRadians)
                let y = centerY + radius * sin(angleRadians)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .shadow(color: .neonRed, radius: 5)
                    .scaleEffect(pulseScale)
                    .position(x: x, y: y)
                    .opacity(timeLeft == 0 ? 0 : 1)
            }
            .frame(width: width, height: height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
        .animation(.linear(duration: 1.0), value: timeLeft)
    }
}

// MARK: - Glitch Score Watch
struct GlitchScoreView_Watch: View {
    let score: Int
    let isAnimating: Bool
    
    @State private var offsetRed: CGFloat = 0
    @State private var offsetCyan: CGFloat = 0
    @State private var opacityGlitch: Double = 0
    
    @State private var glitchTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Text("\(score)")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .neonCyan.opacity(0.8), radius: 3)

            if isAnimating {
                Text("\(score)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.neonRed)
                    .offset(x: offsetRed)
                    .opacity(opacityGlitch)
                    .blendMode(.screen)
                
                Text("\(score)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.neonCyan)
                    .offset(x: offsetCyan)
                    .opacity(opacityGlitch)
                    .blendMode(.screen)
            }
        }
        .onChange(of: isAnimating) { oldValue, newValue in
            if newValue {
                glitchTask = Task {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 50_000_000)
                        await MainActor.run {
                            if Double.random(in: 0...1) > 0.8 {
                                offsetRed = CGFloat.random(in: -4...4)
                                offsetCyan = CGFloat.random(in: -4...4)
                                opacityGlitch = Double.random(in: 0.5...1.0)
                            } else {
                                offsetRed = 0; offsetCyan = 0; opacityGlitch = 0
                            }
                        }
                    }
                }
            } else {
                glitchTask?.cancel()
                offsetRed = 0; offsetCyan = 0; opacityGlitch = 0
            }
        }
    }
}

struct ArcButton_Watch: View {
    var isPressed: Bool
    
    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var arcJitter: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Baza butonului
            Circle()
                .fill(RadialGradient(colors: [.neonCyan.opacity(0.4), .black], center: .center, startRadius: 2, endRadius: 50))
                .frame(width: 80, height: 80) // Scalat de la 180
            
            // Inelele electrice animate
            Group {
                Circle()
                    .stroke(Color.white.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, dash:[2, 15, 5, 10]))
                    .rotationEffect(.degrees(rotation1))
                
                Circle()
                    .stroke(Color.neonCyan, style: StrokeStyle(lineWidth: 2, dash:[4, 20, 10, 15]))
                    .rotationEffect(.degrees(-rotation2))
            }
            .frame(width: 95, height: 95)
            
            // Iconița Flash
            Image(systemName: "bolt.fill")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
                .shadow(color: .neonCyan, radius: 4)
                .scaleEffect(isPressed ? 0.8 : 1.0)
                .scaleEffect(arcJitter)
        }
        .drawingGroup() // Randare Metal nativă
        .onAppear {
            startElectricAnimations()
        }
    }
    
    private func startElectricAnimations() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) { rotation1 = 360 }
        withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) { rotation2 = 360 }
        withAnimation(.easeInOut(duration: 0.04).repeatForever(autoreverses: true)) { arcJitter = 1.04 }
    }
}

