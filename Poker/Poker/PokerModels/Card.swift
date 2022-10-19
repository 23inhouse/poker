//
//  Card.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Card {
    var rank: Rank = .allCases.randomElement() ?? .ace
    var suit: Suit = .allCases.randomElement() ?? .spades

    init() {}

    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
    }

    init?(_ from: String) {
        guard from.count > 1 else { return nil }

        let rankRange = 0 ..< Array(from).count - 1
        let rankFrom = Array(from)[rankRange].map({ String($0) }).joined()
        let suitFrom = String(from.last!)

        guard let rank = Rank(rawValue: rankFrom) else { return nil }
        guard let suit = Suit(rawValue: suitFrom) else { return nil }

        self.rank = rank
        self.suit = suit
    }
}

extension Card: Hashable {}

extension Card: Comparable {
    static func == (lhs: Card, rhs: Card) -> Bool {
      return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    static func < (lhs: Card, rhs: Card) -> Bool {
      return lhs.rank > rhs.rank || (lhs.rank == rhs.rank && lhs.suit > rhs.suit)
    }
}
