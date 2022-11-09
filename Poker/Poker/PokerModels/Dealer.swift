//
//  Dealer.swift
//  Poker
//
//  Created by Benjamin Lewis on 8/11/2022.
//

import Foundation

@MainActor
struct Dealer {
    var gameVM: GameView.GameViewModel

    var players: [Player] { gameVM.players }
    var riverPosition: RiverPosition { gameVM.riverPosition }
    var isPoopMode: Bool = false

    func start() {
        print("Came.start")
        deal()
        calcBestHands()
    }

    func new() {
        gameVM.winningHands = []
        gameVM.river = []

        for i in 0..<players.count {
            gameVM.players[i].cards = []
            gameVM.players[i].isFolded = false
            gameVM.players[i].bestHand = nil
        }

        gameVM.riverPosition = .preflop
    }

    func deal() {
        shuffle()
        dealPlayers()
        gameVM.river = []
        gameVM.riverPosition = .preflop
    }

    func shuffle() {
        gameVM.deck = Deck.cards.shuffled().shuffled().shuffled()
    }

    func dealCard() -> Card {
        _ = gameVM.deck.popLast()
        return gameVM.deck.popLast() ?? Card(rank: .ace, suit: .spades)
    }

    func dealPlayers() {
        for i in 0..<players.count {
            gameVM.players[i].cards = [dealCard(), dealCard()]
            gameVM.players[i].isFolded = false
            gameVM.players[i].bestHand = nil
        }
    }

    func dealRiver() {
        if riverPosition == .preflop {
            gameVM.river = [dealCard(), dealCard(), dealCard()]
        } else if [.flop, .turn].contains(riverPosition) {
            gameVM.river.append(dealCard())
        }
    }

    func next() {
//        print("game.next")
        let cardTurnDelay: Double = 0.125
//        guard !isFolded else {
//            print("isFolded")
//            riverPosition = .over
//            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
//                gameVM.calcBestHand()
//            }
//            player.isFolded = false
//            return
//        }

        switch riverPosition {
        case .preflop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                setPosition(.flop)
                calcBestHands()
            }
        case .flop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                setPosition(.turn)
                calcBestHands()
            }
        case .turn:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                setPosition(.river)
                calcBestHands()
            }
        case .river:
            setPosition(.over)
            calcBestHands()
        case .over:
            print("over")
            new()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                deal()
                calcBestHands()
//                isFolded = false
//                isChecked = false
//                isBet = false
            }
        }
    }

    func setPosition(_ position: RiverPosition) {
        gameVM.riverPosition = position
    }

    func calcBestHands() {
        print("Game.calcBestHand")
        let playerBestHands = Poker.calcBestHands(from: players, river: gameVM.river)

        for (index, playerBestHand) in playerBestHands.enumerated() {
//            print("index:", index, "bestHand:", playerBestHand, playerBestHand.hand!, playerBestHand.cards)
            gameVM.players[index].bestHand = playerBestHand
        }

        guard riverPosition == .over || isPoopMode else { return }

        gameVM.winningHands = Poker.calcWinningHands(from: playerBestHands)
        let bestKickerHands = Poker.calcBestHandWithKicker(from: playerBestHands, winningHands: gameVM.winningHands)
        guard !bestKickerHands.isEmpty else { return }

        for (index, bestHand) in bestKickerHands.enumerated() {
            gameVM.players[index].bestHand = bestHand

            for (index, winningHand) in gameVM.winningHands.enumerated() {
                if winningHand == bestHand {
                    gameVM.winningHands[index].tieBreakingKickerCard = bestHand.tieBreakingKickerCard
                }
            }
        }
    }
}
