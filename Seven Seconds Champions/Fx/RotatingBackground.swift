//
//  RotatingBackground.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 14.01.2025.
//

import SwiftUI

struct NormalBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("background_cosmic")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .ignoresSafeArea()
    }
}

struct RotatingBackground: View {
    var isAnimating: Bool
    @State private var moveX: CGFloat = -20
    @State private var moveY: CGFloat = -20

    var body: some View {
        GeometryReader { geometry in
            Image("background_cosmic")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width * 1.1, height: geometry.size.height * 1.1)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(x: moveX, y: moveY)
                .onAppear {
                    if isAnimating {
                        startFloating()
                    }
                }
                .onChange(of: isAnimating) { newValue in
                    if newValue { startFloating() }
                }
        }
        .ignoresSafeArea()
    }

    private func startFloating() {
        withAnimation(
            Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)
        ) {
            moveX = 20
        }
        
        withAnimation(
            Animation.easeInOut(duration: 25).repeatForever(autoreverses: true)
        ) {
            moveY = 20
        }
    }
}
