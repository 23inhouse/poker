//
//  Hand.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Hand {
    static let maxNumberOfCards = 5

    var cards: [Card] = []

    static func from(_ description: String) -> Hand? {
        var cards: [Card] = []
        for cardDescription in description.split(separator: " ") {
            guard let card = Card.from(String(cardDescription)) else { return nil }
            cards.append(card)
        }
        return Hand(cards: cards)
    }

    func groupedByRank() -> [Card] {
        let hand = Array(cards.sorted().reversed())
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
        if Set(cards.map(\.rank)).count > 2 {
            cards = Hand(cards: Array(cards.prefix(Hand.maxNumberOfCards))).groupedByRank()
        }

        return Array(cards)
    }

    func groupedBySuit() -> [Card] {
        let suitedCards: [Suit: [Card]] = Dictionary(grouping: cards.sorted().reversed(), by: \.suit)
        for cardsBySuit in suitedCards {
            if cardsBySuit.value.count >= Hand.maxNumberOfCards {
                return Array(cardsBySuit.value.prefix(Hand.maxNumberOfCards))
            }
        }

        return []
    }

    func groupedByStraights() -> [Card] {
        var sortedCards: [Card] = cards.sorted().reversed()

        if let indexOfAce = sortedCards.firstIndex(where: { card in card.rank == .ace }) {
            sortedCards.append(sortedCards[indexOfAce])
        }

        while sortedCards.count >= Hand.maxNumberOfCards {
            let firstSortedCard = sortedCards.removeFirst()
            var cards: [Card] = [firstSortedCard]

            for card in sortedCards {
                let cardIndex = card.rank.index
                let lastCardIndex = cards.last!.rank.index
                if cardIndex == lastCardIndex - 1 {
                    cards.append(card)
                }
                if cards.count == 4 && cards.first!.rank == .five && sortedCards.last!.rank == .ace {
                    cards.append(sortedCards.last!)
                }
            }

            if cards.count == Hand.maxNumberOfCards {
                return cards
            }
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
        return map(\.description).joined(separator: " ")
    }
}
