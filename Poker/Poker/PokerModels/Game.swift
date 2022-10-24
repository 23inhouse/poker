//
//  Game.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

class Game: ObservableObject {
    static var deck: [Card] = {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        return deck
    }()

    var deck: [Card] = Game.deck

    @Published var player: Player = Player()
    @Published var players: [Player] = [Player(), Player(), Player(), Player()]
    @Published var river: [Card] = []
    @Published var bestHand: BestHand?
    @Published var riverPosition: RiverPosition = .preflop

    var over: Bool { riverPosition == .over }
    var isFolded: Bool { player.isFolded }

    func start() {
        print("Came.start")
        deal()
    }

    func new() {
        self.bestHand = nil
        self.river = []

        self.player.cards = []
        self.player.isFolded = false
        self.player.bestHand = nil

        for i in 0..<players.count {
            self.players[i].cards = []
            self.players[i].isFolded = false
            self.players[i].bestHand = nil
        }

        self.riverPosition = .preflop
    }

    func deal() {
        print("deal")
        shuffle()
        self.players = dealPlayers()
        self.player = dealPlayer()
        self.river = []
        self.riverPosition = .preflop
    }

    func next() {
        print("game.next")
        let cardTurnDelay: Double = 0.125
        guard !isFolded else {
            print("isFolded")
            riverPosition = .over
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.calcBestHand()
            }
            player.isFolded = false
            return
        }

        switch riverPosition {
        case .preflop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .flop
            }
        case .flop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .turn
            }
        case .turn:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .river
                self.calcBestHand()
            }
        case .river:
            riverPosition = .over
        case .over:
            print("over")
            new()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.deal()
//                isFolded = false
//                isChecked = false
//                isBet = false
            }
        }
    }

    func shuffle() {
        deck = Game.deck.shuffled().shuffled().shuffled()
    }

    func dealCard() -> Card {
        _ = self.deck.popLast()
        return self.deck.popLast() ?? Card(rank: .ace, suit: .spades)
    }

    func dealPlayer() -> Player {
        return Player(cards: [dealCard(), dealCard()])
    }

    func dealPlayers() -> [Player] {
        return [
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()])
        ]
    }

    func dealRiver() {
        if riverPosition == .preflop {
            river = [dealCard(), dealCard(), dealCard()]
        } else if [.flop, .turn].contains(riverPosition) {
            river.append(dealCard())
        }
    }

    func calcBestHand() {
        print("Game.calcBestHand")
        let players: [Player] = players + [player]

        let hands: [Hand] = players.enumerated().compactMap { index, player in
            let playerBestHand = player.bestHand(from: river)
            if index < self.players.count {
                self.players[index].bestHand = playerBestHand
            } else {
                self.player.bestHand = playerBestHand
            }

            return playerBestHand?.hand
        }

        self.bestHand = BestHand.check(hands)
    }
}
