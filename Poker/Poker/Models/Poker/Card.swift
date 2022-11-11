//
//  Card.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Card {
    var rank: Rank = .random()
    var suit: Suit = .random()

    static func from(_ description: String) -> Card? {
        guard description.count > 1 else { return nil }

        var description = description
        let suitDescription = String(description.removeLast())
        let rankDescription = description

        guard let rank = Rank(rawValue: rankDescription) else { return nil }
        guard let suit = Suit(rawValue: suitDescription) else { return nil }

        return Card(rank: rank, suit: suit)
    }
}

extension Card: Hashable {}

extension Card: Comparable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.rank == rhs.rank && lhs.suit == rhs.suit
    }

    static func < (lhs: Card, rhs: Card) -> Bool {
        guard lhs.rank != rhs.rank else { return lhs.suit < rhs.suit }
        return lhs.rank < rhs.rank
    }
}

extension Card: CustomStringConvertible {
    var description: String {
        return "\(rank.rawValue)\(suit.rawValue)"
    }
}
