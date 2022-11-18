//
//  Dealer+Calculator.swift
//  Poker
//
//  Created by Benjamin Lewis on 14/11/2022.
//

import Foundation

extension Dealer {
    @MainActor
    struct Calculator {
        var gameVM: GameView.GameViewModel

        private var players: [Player] { gameVM.players }
        private var riverPosition: RiverPosition { gameVM.riverPosition }
        private var computerPlayers: [Player] { gameVM.computerPlayers }

        var allInAmount: Int { players.filter(\.isInHand).map(\.chips).min() ?? gameVM.player.chips }
        var startingAmount: Int { startingBet(at: gameVM.currentPlayerIndex) }

        var largestBet: Int { players.filter(\.isInHand).map(\.bet).max() ?? 0 }
        var smallestBet: Int { players.filter(\.isInHand).map(\.bet).min() ?? 0 }
        var minimumBet: Int { computerPlayers.filter(\.isInHand).map(\.bet).max() ?? 0 }

        func startingBet(at index: Int?) -> Int {
            guard let index = index else { return 0 }

            if gameVM.isSmallBlind(at: index) {
                return Dealer.smallBlindBet
            } else if gameVM.isBigBlind(at: index) {
                return Dealer.bigBlindBet
            }

            return 0
        }

        func betAmount(for betStep: Int) -> Int {
            let potAmount: Double = Double([gameVM.pot, Dealer.bigBlindBet * 4].max()!)
            var amountToBet: Double = 0
            switch betStep {
            case 0: amountToBet = Double(startingAmount)
            case 1: amountToBet = potAmount * 0.25
            case 2: amountToBet = potAmount * 0.5
            case 3: amountToBet = potAmount * 0.75
            case 4: amountToBet = potAmount * 1
            case 5: amountToBet = potAmount * 2
            case 6: amountToBet = potAmount * 3
            case 7: amountToBet = potAmount * 4
            case 8: amountToBet = potAmount * 5
            default: amountToBet = Double(gameVM.allInAmount) // NOTE: calculated at the start of each betting round
            }
            guard amountToBet < Double(gameVM.allInAmount) else { return gameVM.allInAmount }
            return Int(amountToBet)
        }
    }
}
