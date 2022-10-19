//
//  Poker.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Poker {
    static func bestHand(_ hands: [String]) -> String {
        let Hands: [Hand] = hands.map { handString in
            guard let hand = Hand(handString) else {
                assert(false, "Error: Invalid hand [\(handString)]")
            }
            return hand
        }
        guard let best = BestHand.check(Hands) else {
            assert(false, "Error: No winner")
        }
        return String(describing: best.hand)
    }
}

struct BestHand {
    typealias HandLogic = (Hand) -> ([Card])

    static let logics: [HandLogic] = [royalFlush, straightFlush, fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, pair, highCard]

    static let royalFlush: HandLogic = { hand in
        let cards = straightFlush(hand)
        guard cards.count == 5 else { return [] }
        guard cards[0].rank == .ace else { return [] }
        return cards
    }

    static let straightFlush: HandLogic = { hand in
        let cards = straight(hand)
        guard cards.count == 5, flush(hand).count == 5 else { return [] }
        return cards
    }

    static let fourOfAKind: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 4 && cards.first!.rank == cards.last!.rank else { return [] }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return cards
    }

    static let fullHouse: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 5 else { return cards }
        if cards[0].rank != cards[2].rank {
            cards.reverse()
        }
        return cards
    }

    static let flush: HandLogic = { hand in
        return hand.sorted().filter { card in card.suit == hand.cards[0].suit }
    }

    static let straight: HandLogic = { hand in
        var cards = [Card]()
        for card in hand.sorted().reversed() {
            if cards.isEmpty || cards.last!.rank.index() == card.rank.index() - 1 {
                cards.append(card)
            }
            if cards.count == 4 && cards.last!.rank == .five && card.rank == .ace {
                cards.insert(card, at: 0)
            }
        }
        return cards
    }

    static let threeOfAKind: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 3 else { return [] }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return cards
    }

    static let twoPair: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 4 && cards.first!.rank != cards.last!.rank else { return [] }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return cards
    }

    static let pair: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 2 else { return [] }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return cards
    }

    static let highCard: HandLogic = { hand in
        return hand.cards.sorted()
    }

    static func check(_ hands: [Hand]) -> BestHand? {
        return hands.map({ BestHand($0) }).sorted().last
    }

    static func grouped(_ hand: Hand) -> [Card] {
        var cards = [Card]()
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

    let hand: Hand
    let cards: [Card]
    let score: Int

    init(_ hand: Hand) {
        var score = 0
        var cards = [Card]()

        for (i, logic) in BestHand.logics.enumerated() {
            cards = logic(hand)
            if cards.count == 5 {
                score = BestHand.logics.count - i
                break
            }
        }

        self.hand = hand
        self.cards = cards
        self.score = score
    }
}

extension BestHand: Comparable {
    static func == (lhs: BestHand, rhs: BestHand) -> Bool {
        return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
    }

    static func < (lhs: BestHand, rhs: BestHand) -> Bool {
        // print("\(lhs.hand) < \(rhs.hand) == \(lhs.score) < \(rhs.score) || \(lhs.highCard()) < \(rhs.highCard()) || \(lhs.secondHighCard(rhs)) < \(rhs.secondHighCard(lhs)) || \(lhs.cards.first!.suit.index()) < \(rhs.cards.first!.suit.index())")
        guard lhs.score != rhs.score else {
            guard lhs.highCard() != rhs.highCard() else {
                guard lhs.secondHighCard(rhs) != rhs.secondHighCard(lhs) else {
                    return lhs.cards.first!.suit < rhs.cards.first!.suit
                }
                return lhs.secondHighCard(rhs) < rhs.secondHighCard(lhs)
            }
            return lhs.highCard() < rhs.highCard()
        }
        return lhs.score < rhs.score
    }

    func highCard() -> Rank {
        return cards[0].rank
    }

    func secondHighCard(_ other: BestHand) -> Rank {
        let highCards = hand.filter({ !other.hand.ranks().contains($0.rank) })
        guard let highestCard = highCards.sorted().last else { return .two }
        return highestCard.rank
    }
}
