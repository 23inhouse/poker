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

    mutating func fold() {
        isFolded = true
    }

    mutating func setAmountToBet(_ amount: Int) {
        bet = amount
    }
}
extension Player: Hashable {}
