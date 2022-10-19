//
//  Card.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Card {
    var rank: Rank = .allCases.randomElement() ?? .ace
    var suit: Suit = .allCases.randomElement() ?? .spade
}
extension Card: Hashable {}
