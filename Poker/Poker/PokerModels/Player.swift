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
        let allCards = cards + river
        guard !allCards.isEmpty else { return nil }
        let handFromAllCards = Hand(cards: allCards)
        return BestHand.check([handFromAllCards])
    }

    mutating func fold() {
        isFolded = true
    }
}
extension Player: Hashable {}
