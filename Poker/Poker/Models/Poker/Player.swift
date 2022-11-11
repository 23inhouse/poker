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
    var chips: Int = 10
    var bestHand: BestHand?
    var isFolded: Bool = false
    var isOnTheButton: Bool = false
    var isBigBlind: Bool = false
    var isSmallBlind: Bool = false
    var isCurrentPlayer: Bool = false
    var isThePlayer: Bool = false

    var availableChips: Int { chips - bet }

    var isCanBet: Bool { availableChips > 0 }
    var isInHand: Bool { !isFolded && isCanBet }
}
extension Player: Hashable {}
