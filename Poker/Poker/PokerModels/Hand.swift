//
//  Hand.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Hand {
    static let numberOfCards = 5

    var cards: [Card] = []

    init(cards: [Card]) {
        self.cards = cards
    }

    init?(_ hand: String) {
        for card in hand.split(separator: " ") {
            guard let card = Card(String(card)) else { return nil }
            self.cards.append(card)
        }

//        guard validate() else { return nil }
    }

    func ranks() -> [Rank] {
        return cards.map({ $0.rank }).sorted()
    }

    func suits() -> [Suit] {
        return cards.map({ $0.suit }).sorted()
    }

    private func validate() -> Bool {
        guard cards.count <= Hand.numberOfCards else { return false }
        return true
    }

    func groupedByRank() -> [Card] {
        let hand = self.cards.sorted()
        var cards: [Card] = []
        for card in hand {
            for other in hand {
                guard card != other else { continue }
                guard !cards.contains(card) else { continue }

                if card.rank == other.rank {
                    cards.append(card)
                }
            }
        }
        return cards.sorted()
    }

    func groupedBySuit() -> [Card] {
        let suitedCards: [Suit: [Card]] = Dictionary(grouping: self.cards.sorted(), by: \.suit)
        for cardsBySuit in suitedCards {
            if cardsBySuit.value.count == 5 {
                return cardsBySuit.value
            }
        }

        return []
    }

    func groupedByStraights() -> [Card] {
        var sortedCards = self.cards.sorted()

        let indexOfAce = sortedCards.firstIndex(where: { card in card.rank == .ace })

        while sortedCards.count >= Hand.numberOfCards {
            let hand = sortedCards.prefix(Hand.numberOfCards)

            var cards: [Card] = []
            for card in hand.reversed() {
                if cards.isEmpty || cards.last!.rank.index == card.rank.index - 1 {
                    cards.append(card)
                }
                guard let indexOfAce = indexOfAce else { continue }

                if cards.count == 4 && cards.last!.rank == .five {
                    cards.insert(sortedCards[indexOfAce], at: 0)
                }
            }

            if cards.count == Hand.numberOfCards {
                return cards
            }

            sortedCards.removeFirst()
        }

        return []
    }
}
extension Hand: Hashable {}

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
