//
//  Seven_Seconds_ChampionsUITests.swift
//  Seven Seconds ChampionsUITests
//
//  Created by Ovidiu Muntean on 08.01.2025.
//

import XCTest

final class Seven_Seconds_ChampionsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
    }

    @MainActor
    func test_FullGameLoop_And_Retry() throws {
        let totalRounds = 3
        
        for round in 1...totalRounds {
            print("\n🏁 === RUNDA \(round) din \(totalRounds) === 🏁\n")
            
            let app = XCUIApplication()
            app.launchArguments = ["--uitesting"]
            app.launch()
            
            addUIInterruptionMonitor(withDescription: "Game Center Login") { (alert) -> Bool in
                let button = alert.buttons["Cancel"]
                if button.exists {
                    button.tap()
                    return true
                }
                return false
            }
            
            app.tap()
            
            let reactorButton = app.descendants(matching: .any)["ArcButton"].firstMatch
            let scoreLabel = app.descendants(matching: .any)["ScoreLabel"].firstMatch
            
            XCTAssertTrue(reactorButton.waitForExistence(timeout: 5), "Runda \(round): ArcButton există la start")
            
            let randomTaps = Int.random(in: 10...30)
            print("🔥 Runda \(round): Se execută \(randomTaps) tap-uri.")
            
            for _ in 1...randomTaps {
                reactorButton.tap()
            }
            
            if scoreLabel.exists {
                XCTAssertNotEqual(scoreLabel.label, "0", "Scorul trebuie să fi crescut!")
            }
            
            print("⏳ Runda \(round): Așteptăm timer-ul...")
            let retryButton = app.buttons["RetryButton"]
            let gameEnded = retryButton.waitForExistence(timeout: 12)
            XCTAssertTrue(gameEnded, "Runda \(round): Jocul s-a terminat")
                        
            retryButton.tap()
            
            XCTAssertFalse(retryButton.exists, "Runda \(round): Butonul Retry trebuie să dispară după apăsare")
            XCTAssertTrue(reactorButton.exists, "Runda \(round): ArcButton trebuie să fie din nou pe ecran")
            
            print("✅ RUNDA \(round) COMPLETĂ! Trecem la următoarea...\n")
            
            let timerLabel = app.staticTexts["TimerLabel"]
            if timerLabel.exists {
                XCTAssertTrue(timerLabel.label.contains("7") || timerLabel.label.contains("SECONDS"))
            }
        }
    }
}
