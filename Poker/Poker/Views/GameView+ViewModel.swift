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

        var player: Player {
            get { players.last! }
            set(newPlayer) { players[players.count - 1] = newPlayer }
        }

        var computerPlayers: [Player] { Array(players.prefix(GameViewModel.numberOfPlayers - 1)) }

        var potIncludingCurrentBettingRound: Int { players.map(\.bet).reduce(pot, +) }

        var dealer: Dealer { Dealer(gameVM: self) }

        var smallBlindIndex: Int {
            return dealer.nextAvailableIndex(after: buttonIndex, \.isInHand)
        }

        var bigBlindIndex: Int {
            return dealer.nextAvailableIndex(after: smallBlindIndex, \.isInHand)
        }

        var over: Bool { riverPosition == .over }
        var isFolded: Bool { player.isFolded }
        var winningCards: [Card] { winningHands.flatMap(\.handWithKicker) }

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
    }
}
