//
//  Game.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

class Game {
    static var deck: [Card] = {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        return deck
    }()

    static func new() -> Game {
        let game = Game()
        game.deck = Game.deck.shuffled().shuffled().shuffled()
        game.deal()
        return game
    }

    var deck: [Card] = Game.deck

    var player: Player = Player(cards: [])
    var players: [Player] = []
    var river: [Card] = []
    var bestHand: BestHand?

    func deal() {
        self.player = dealPlayer()
        self.players = dealPlayers()
        self.river = dealRiver()
        calcBestHand()
    }

    func dealCard() -> Card {
        _ = self.deck.popLast()
        return self.deck.popLast() ?? Card(rank: .ace, suit: .spades)
    }

    func dealPlayer() -> Player {
        Player(cards: [dealCard(), dealCard()])
    }

    func dealPlayers() -> [Player] {
        [
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()]),
            Player(cards: [dealCard(), dealCard()])
        ]
    }

    func dealRiver() -> [Card] {
//        var cards: [Card] = []
//        for _ in 0..<5 {
//            _ = dealCard()
//            cards.append(dealCard())
//
//        }
//        return cards
        [dealCard(), dealCard(), dealCard(), dealCard(), dealCard()]
    }

    func calcBestHand() {
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

extension Array where Element == Card {
    func riverHands(with cards: [Element]) -> [[Element]] {
        guard count == 5 else {
            assert(false, "Error: There must be 5 cards in the river.")
            return []
        }

        return [
            cards + [self[0], self[1], self[2]],
            cards + [self[0], self[1], self[3]],
            cards + [self[0], self[1], self[4]],

            cards + [self[0], self[2], self[3]],
            cards + [self[0], self[2], self[4]],
            cards + [self[0], self[3], self[4]],

            cards + [self[1], self[2], self[3]],
            cards + [self[1], self[2], self[4]],
            cards + [self[1], self[3], self[4]],

            [cards[0]] + [self[0], self[1], self[2], self[3]],
            [cards[0]] + [self[0], self[1], self[2], self[4]],
            [cards[0]] + [self[0], self[1], self[3], self[4]],
            [cards[0]] + [self[0], self[2], self[3], self[4]],
            [cards[0]] + [self[1], self[2], self[3], self[4]],

            [cards[1]] + [self[0], self[1], self[2], self[3]],
            [cards[1]] + [self[0], self[1], self[2], self[4]],
            [cards[1]] + [self[0], self[1], self[3], self[4]],
            [cards[1]] + [self[0], self[2], self[3], self[4]],
            [cards[1]] + [self[1], self[2], self[3], self[4]],

            self
        ]
    }
}
