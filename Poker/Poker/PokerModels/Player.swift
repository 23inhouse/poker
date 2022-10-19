//
//  Player.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Player {
    let cards: [Card]
    var bet: Int = 0
    var chips: Int = 500
    var bestHand: BestHand?

    func bestHand(from river: [Card]) -> BestHand? {
        let hands: [Hand] = river.riverHands(with: cards).map { possibleHands in
            return Hand(cards: possibleHands)
        }
        return BestHand.check(hands)
    }
}
extension Player: Hashable {}
