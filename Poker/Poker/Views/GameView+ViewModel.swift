//
//  GameView+ViewModel.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import Foundation

extension GameView.GameViewModel {
    static var numberOfPlayers: Int = 5
}

extension GameView {
    @MainActor
    class GameViewModel: ObservableObject {
        var deck: [Card] = Deck.cards

        @Published var players: [Player] = (0..<GameViewModel.numberOfPlayers).map { _ in Player() }
        @Published var river: [Card] = []
        @Published var winningHands: [BestHand] = []
        @Published var riverPosition: RiverPosition = .preflop
        @Published var currentPlayerIndex: Int?
        @Published var buttonIndex: Int = 0
        @Published var pot: Int = 0
        @Published var allInAmount: Int = 0
        @Published var isGameOver: Bool = false

        var player: Player {
            get { players.last! }
            set(newPlayer) { players[players.count - 1] = newPlayer }
        }

        var computerPlayers: [Player] { Array(players.prefix(GameViewModel.numberOfPlayers - 1)) }

        var dealer: Dealer { Dealer(gameVM: self) }

        var smallBlindIndex: Int { dealer.nextAvailableIndex(after: buttonIndex, \.isInHand) }
        var bigBlindIndex: Int { dealer.nextAvailableIndex(after: smallBlindIndex, \.isInHand) }

        var isHandFinished: Bool { riverPosition == .handFinished }
        var isFolded: Bool { player.isFolded }
        var winningCards: [Card] { winningHands.flatMap(\.handWithKicker) }

        var potDescription: String {
            guard !isGameOver else { return player.chips > 0 ? "Winner!" :"Game Over" }

            return "Pot: \(pot)€"
        }

        var playerActionDescription: String {
            if player.isFolded {
                return "FOLDED"
            } else if player.bet == player.chips {
                return "All in"
            } else if player.bet > dealer.minimumBet {
                return "Raise: \(player.bet)€"
            } else if dealer.minimumBet > 0 {
                return "Call: \(dealer.minimumBet)€"
            } else {
                return "Check"
            }
        }

        func isOnTheButton(at index: Int) -> Bool {
            return index == buttonIndex
        }

        func isSmallBlind(at index: Int) -> Bool {
            return index == smallBlindIndex
        }

        func isBigBlind(at index: Int) -> Bool {
            return index == bigBlindIndex
        }

        func isCurrentPlayer(at index: Int) -> Bool {
            return index == currentPlayerIndex
        }

        func setAllInAmount() {
            allInAmount = dealer.allInAmount
        }
    }
}
