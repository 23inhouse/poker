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
}
extension Player: Hashable {}
