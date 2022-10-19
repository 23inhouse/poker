//
//  Suit.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

enum Suit: String {
    case clubs = "♧"
    case diamonds = "♢"
    case hearts = "♡"
    case spades = "♤"
}

extension Suit: CaseIterable {}

extension Suit: Comparable {
    static let order: [Suit] = [clubs, diamonds, hearts, spades]

    static func == (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    static func < (lhs: Suit, rhs: Suit) -> Bool {
        return lhs.index() < rhs.index()
    }

    func index() -> Int {
        return Suit.order.firstIndex(of: self) ?? -1
    }
}

extension Suit: CustomStringConvertible {
    var description: String {
        let mapping: [Suit: String] = [
            .clubs: "club",
            .diamonds: "diamond",
            .hearts: "heart",
            .spades: "spade"
        ]
        return mapping[self]!
    }
}
