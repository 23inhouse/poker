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

        @Published var players: [Player] = (0..<GameViewModel.numberOfPlayers).map { _ in Player(isFolded: true) }
        @Published var river: [Card] = []
        @Published var winningHands: [BestHand] = []
        @Published var riverPosition: RiverPosition = .preflop

        var player: Player {
            get { players.last! }
            set(newPlayer) { players[players.count - 1] = newPlayer }
        }

        var computerPlayers: [Player] { Array(players.prefix(GameViewModel.numberOfPlayers - 1)) }

        var over: Bool { riverPosition == .over }
        var isFolded: Bool { player.isFolded }
        var winningCards: [Card] { winningHands.flatMap(\.handWithKicker) }
    }
}
