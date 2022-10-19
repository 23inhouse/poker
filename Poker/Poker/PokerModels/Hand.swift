//
//  Hand.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Hand {
    static let numberOfCards = 5

    var cards = [Card]()

    func ranks() -> [Rank] {
        return cards.map({ $0.rank }).sorted()
    }

    func suits() -> [Suit] {
        return cards.map({ $0.suit }).sorted()
    }

    private func validate() -> Bool {
        guard cards.count == Hand.numberOfCards else { return false }
        return true
    }

    init?(_ hand: String) {
        for card in hand.split(separator: " ") {
            guard let card = Card(String(card)) else { return nil }
            self.cards.append(card)
        }

        guard validate() else { return nil }
    }
}

extension Hand: Collection {
    typealias Index = Array<Card>.Index
    typealias Element = Array<Card>.Element

    var startIndex: Index { return cards.startIndex }
    var endIndex: Index { return cards.endIndex }

    subscript(index: Index) -> Element {
        get { return cards[index] }
    }

    func index(after i: Index) -> Index {
        return cards.index(after: i)
    }
}

extension Hand: CustomStringConvertible {
    var description: String {
        return self.map({ "\($0.rank.rawValue)\($0.suit.rawValue)" }).joined(separator: " ")
    }
}
