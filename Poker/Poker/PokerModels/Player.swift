//
//  Player.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Player {
    var cards: [Card] = []
    var bet: Int = 0
    var chips: Int = 500
    var bestHand: BestHand?
    var isFolded: Bool = false

    func bestHand(from river: [Card]) -> BestHand? {
        print("Player.bestHand")
        let fullHand = cards + river
        guard !fullHand.isEmpty else { return nil }
        let riveHand = Hand(cards: fullHand)
        guard let bestCards = BestHand.check([riveHand])?.cards else { return nil }
        return BestHand(Hand(cards: Array(bestCards.prefix(5))))
    }

    mutating func fold() {
        isFolded = true
    }
}
extension Player: Hashable {}
