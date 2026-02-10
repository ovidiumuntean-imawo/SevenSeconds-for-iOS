//
//  Sparks.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import UIKit

class Sparks {
    static let shared = Sparks()
    private init() {}
    
    func createSparks(emitterLayer: inout CAEmitterLayer?,
                      emitterCell: CAEmitterCell,
                      buttonFrame: CGRect) {
        guard let image = UIImage(named: "spark.png")?.cgImage else {
            print("Failed to load spark image.")
            return
        }
        
        emitterLayer = CAEmitterLayer()
        emitterLayer?.name = "ButtonEmitter"
        emitterLayer?.emitterShape = .circle
        
        emitterLayer?.emitterPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        emitterLayer?.emitterSize = CGSize(width: 10, height: 10)
        
        emitterCell.contents = image
        emitterCell.name = "cell"
        
        emitterCell.birthRate = 20
        emitterCell.lifetime = 16
        emitterCell.velocity = 22
        
        emitterCell.scale = 0.18
        emitterCell.scaleRange = 0.2
        emitterCell.emissionLongitude = .pi / 2.0
        emitterCell.emissionRange = CGFloat.pi / 4.0
        
        emitterCell.color = UIColor.white.cgColor
        emitterLayer?.emitterCells = [emitterCell]
        
        if let emitterLayer = emitterLayer,
           let window = UIApplication.shared.windows.first {
            window.layer.addSublayer(emitterLayer)
        }
    }
    
    func updateSparks(emitterLayer: CAEmitterLayer?,
                         gameManager: GameManager,
                      buttonFrame: CGRect) {
        guard let emitterLayer = emitterLayer else { return }
        
        emitterLayer.emitterPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        
        if gameManager.isGameRunning {
            let newBirthRate = Float(20 + gameManager.currentScore * 2)
            let newVelocity = CGFloat(40 + gameManager.currentScore * 5)
            
            let randomHue = CGFloat.random(in: 0.0...0.18)
            let newColor = UIColor(hue: randomHue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
            
            emitterLayer.setValue(newBirthRate, forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(newVelocity, forKeyPath: "emitterCells.cell.velocity")
            emitterLayer.setValue(newColor, forKeyPath: "emitterCells.cell.color")
        } else {
            emitterLayer.setValue(20, forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(22, forKeyPath: "emitterCells.cell.velocity")
            emitterLayer.setValue(UIColor.white.cgColor, forKeyPath: "emitterCells.cell.color")
        }
    }
}
