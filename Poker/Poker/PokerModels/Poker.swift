//
//  Poker.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Poker {
    static func bestHand(_ hands: [String]) -> String {
        let hands: [Hand] = hands.map { handString in
            guard let hand = Hand(handString) else {
                assert(false, "Error: Invalid hand [\(handString)]")
            }
            return hand
        }
        guard let best = BestHand.check(hands) else {
            assert(false, "Error: No winner")
        }
        return String(describing: best.hand)
    }
}

struct BestHand {
    typealias HandLogic = (Hand) -> ([Card], String)

    let hand: Hand
    let cards: [Card]
    let score: Int
    let description: String

    init(_ hand: Hand) {
        var score = 0
        var cards = [Card]()
        var desc = "No hand"

        for (i, logic) in BestHand.logics.enumerated() {
            (cards, desc) = logic(hand)
            if cards.count == 5 {
                score = BestHand.logics.count - i
                break
            }
        }

        self.hand = hand
        self.cards = cards
        self.score = score
        self.description = desc
    }

    static let logics: [HandLogic] = [royalFlush, straightFlush, fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, pair, highCard]

    static let royalFlush: HandLogic = { hand in
        let (cards, desc) = straightFlush(hand)
        guard cards.count == 5 else { return ([], desc) }
        guard cards[0].rank == .ace else { return ([], desc) }
        return (cards, "Royal Flush")
    }

    static let straightFlush: HandLogic = { hand in
        let (cards, desc) = straight(hand)
        guard cards.count == 5, flush(hand).0.count == 5 else { return ([], desc) }
        return (cards, "Straight Flush \(highCard(hand).1)")
    }

    static let fourOfAKind: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 4 && cards.first!.rank == cards.last!.rank else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Four of a kind \(cards.first!.rank)s")
    }

    static let fullHouse: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 5 else { return ([], highCard(hand).1) }
        if cards[0].rank != cards[2].rank {
            cards.reverse()
        }
        return (cards, "Full house")
    }

    static let flush: HandLogic = { hand in
        let cards = hand.sorted().filter { card in card.suit == hand.cards[0].suit }
        return (cards, "Flush \(highCard(hand).1)")
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
        return (cards, "Straight \(highCard(hand).1)")
    }

    static let threeOfAKind: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 3 else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Three of a kind \(cards.first!.rank)s")
    }

    static let twoPair: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 4 && cards.first!.rank != cards.last!.rank else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Two pair \(cards[0].rank)s & \(cards[3].rank)s")
    }

    static let pair: HandLogic = { hand in
        var cards = grouped(hand)
        guard cards.count == 2 else { return ([], highCard(hand).1 ) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Pair of \(cards.first!.rank)s")
    }

    static let highCard: HandLogic = { hand in
        let cards = hand.cards.sorted()
        return (cards, "\(cards.first!.rank.rawValue) high")
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
}

extension BestHand: Hashable {}

extension BestHand: Comparable {
    static func == (lhs: BestHand, rhs: BestHand) -> Bool {
        guard lhs.score == rhs.score else { return false }
        if [8, 4, 3, 2, 1].contains(lhs.score) { // fourOfAKind, threeOfAKind, twoPair, pair, highCard
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard() && lhs.kicker() == rhs.kicker()
        } else {
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
        }
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

    func kicker() -> Rank? {
        let hand = BestHand.grouped(hand)
        return cards.first(where: { card in !hand.contains(card) })?.rank
    }

    func secondHighCard(_ other: BestHand) -> Rank {
        let highCards = hand.filter({ !other.hand.ranks().contains($0.rank) })
        guard let highestCard = highCards.sorted().last else { return .two }
        return highestCard.rank
    }
}
