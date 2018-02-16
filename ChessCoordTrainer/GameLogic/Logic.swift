//
//  Logic.swift
//  ChessCoordTrainer
//
//  Created by Iman Zarrabian on 16/02/2018.
//  Copyright © 2018 One More Thing Studio. All rights reserved.
//

import Foundation

final class Logic {

    var gameIsStarted = false

    private let fileNames = ["a","b","c","d","e","f","g","h"]
    private var tempoTimer: Timer?
    private var sessionTimer: Timer?
    private var isWhitePerspective = true
    private var nbOfTickInGameSession = 0

    var passiveTickhandler: ((Int) -> ())?
    var activeTickHandler: ((Square) -> ())?
    var gameOverHandler: (() -> ())?

    enum GameError: Error {
        case thisIsNotGo
    }

    func squareFromItem(itemNumber: Int, whitePerspective: Bool) throws -> Square {
        guard itemNumber >= 0 && itemNumber <= 63 else {
            throw GameError.thisIsNotGo
        }

        let row = itemNumber / 8
        let column = itemNumber % 8

        var rank: Rank!
        var file: File!

        if whitePerspective {
            rank = 8 - row
            file = fileNames[column]
        } else {
            rank = row + 1
            file = fileNames[7 - column]
        }
        return Square(rank: rank, file: file, flatRank: itemNumber)
    }

    func indexPathForItem(itemNumber: Int) throws -> IndexPath {
        guard itemNumber >= 0 && itemNumber <= 63 else {
            throw GameError.thisIsNotGo
        }

        return IndexPath(item: itemNumber, section: 0)
    }

    func startGame(cpm: Int, isWhitePerspective: Bool) {
        gameIsStarted = true
        nbOfTickInGameSession = 0
        self.isWhitePerspective = isWhitePerspective
        sessionTimer = Timer.scheduledTimer(timeInterval: TimeInterval(60),
                                          target: self,
                                          selector: #selector(gameOver),
                                          userInfo: nil,
                                          repeats: false)

        tempoTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Int(60 / cpm)),
                                     target: self,
                                     selector: #selector(tick),
                                     userInfo: nil,
                                     repeats: true)
        computeRandomItemNumber()
    }

    @objc private func gameOver() {
        gameIsStarted = false
        sessionTimer?.invalidate()
        sessionTimer = nil
        stopTimer()
    }

    private func stopTimer() {
        tempoTimer?.invalidate()
        tempoTimer = nil

        if let handler = gameOverHandler {
            handler()
        }
    }

    @objc private func tick() {
        computeRandomItemNumber()
    }

    private func computeRandomItemNumber() {
        if nbOfTickInGameSession % 2 == 1 && nbOfTickInGameSession > 1 {
            let randomItemNumber = Int(arc4random() % 64)
            let square = try! squareFromItem(itemNumber: randomItemNumber, whitePerspective: isWhitePerspective)

            if let handler = activeTickHandler {
                handler(square)
            }
        } else {
            if let handler = passiveTickhandler {
                handler(nbOfTickInGameSession)
            }
        }
        nbOfTickInGameSession = nbOfTickInGameSession + 1
    }
}
