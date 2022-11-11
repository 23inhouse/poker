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

        var allInAmount: Int { players.map(\.availableChips).min() ?? gameVM.player.availableChips }

        var largestBet: Int { players.filter(\.isInHand).map(\.bet).max() ?? 0 }
        var smallestBet: Int { players.filter(\.isInHand).map(\.bet).min() ?? .max }

        func startingBet(at index: Int) -> Int {
            if gameVM.isSmallBlind(at: index) {
                return Dealer.smallBlindBet
            } else if gameVM.isBigBlind(at: index) {
                return Dealer.bigBlindBet
            }

            return 0
        }
    }
}
