//
//  Poker.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Poker {
    static func bestHand(_ hands: [String]) -> (cards: String, label: String) {
        let hands: [Hand] = hands.map { handString in
            guard let hand = Hand(handString) else {
                assert(false, "Error: Invalid hand [\(handString)]")
            }
            return hand
        }
        guard let best = BestHand.check(hands) else {
            assert(false, "Error: No winner")
        }
        return (String(describing: best.hand), best.label)
    }
}

struct BestHand {
    typealias HandLogic = (Hand) -> ([Card], String)

    let hand: Hand
    let cards: [Card]
    let score: Int
    let label: String

    init(_ hand: Hand) {
        var score = 0
        var cards: [Card] = []
        var label = "No hand"

        for (index, logic) in BestHand.logics.enumerated() {
            (cards, label) = logic(hand)
            if !cards.isEmpty {
                score = BestHand.logics.count - index
                break
            }
        }

        self.hand = hand
        self.cards = cards
        self.score = score
        self.label = label

//        print("BestHand:", hand, "highCard:", highCard(), "secondHighCard:", secondHighCard(), "kicker:", kicker() ?? .two)
    }

    static func check(_ hands: [Hand]) -> BestHand? {
        return hands.map({ BestHand($0) }).sorted().last
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
        guard cards.count == 5, flush(Hand(cards: cards)).0.count == 5 else { return ([], desc) }
        return (cards, "Straight Flush \(highCard(hand).1)")
    }

    static let fourOfAKind: HandLogic = { hand in
        var cards = hand.groupedByRank()
        guard cards.count == 4 && cards.first!.rank == cards.last!.rank else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Four of a kind \(cards.first!.rank)s")
    }

    static let fullHouse: HandLogic = { hand in
        var cards = hand.groupedByRank()
        guard cards.count == 5 else { return ([], highCard(hand).1) }
        if cards[0].rank != cards[2].rank {
            cards.reverse()
        }
        return (cards, "Full house")
    }

    static let flush: HandLogic = { hand in
        let cards = hand.groupedBySuit()
        guard cards.count == 5 else { return ([], highCard(hand).1) }
        return (cards, "Flush \(highCard(hand).1)")
    }

    static let straight: HandLogic = { hand in
        let cards = hand.groupedByStraights()
        guard cards.count >= 5 else { return ([], highCard(hand).1) }
        return (cards, "Straight \(highCard(hand).1)")
    }

    static let threeOfAKind: HandLogic = { hand in
        var cards = hand.groupedByRank()
        guard cards.count == 3 else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Three of a kind \(cards.first!.rank)s")
    }

    static let twoPair: HandLogic = { hand in
        var cards = hand.groupedByRank()
        guard cards.count >= 4 && cards.first!.rank != cards.last!.rank else { return ([], highCard(hand).1) }
        for card in hand.sorted().filter({ !cards.contains($0) }) {
            cards.append(card)
        }
        return (cards, "Two pair \(cards[0].rank)s & \(cards[3].rank)s")
    }

    static let pair: HandLogic = { hand in
        var cards = hand.groupedByRank()
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
}

extension BestHand: Hashable {}

extension BestHand: Comparable {
    static func == (lhs: BestHand, rhs: BestHand) -> Bool {
        guard lhs.score == rhs.score else { return false }

        // royalFlush, straightFlush, fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, pair, highCard
        if [10].contains(lhs.score) { // royalFlush
            return lhs.score == rhs.score
        } else if [9].contains(lhs.score) { // straightFlush
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
        } else if [8, 4, 2, 1].contains(lhs.score) { // fourOfAKind, threeOfAKind, pair, highCard
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard() && lhs.kicker() == rhs.kicker()
        } else if [7].contains(lhs.score) { // flush
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard() && lhs.secondHighCard() == rhs.secondHighCard()
        } else if [3].contains(lhs.score) { // twoPair
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard() && lhs.secondHighCard() == rhs.secondHighCard() && lhs.kicker() == rhs.kicker()
        } else { // straight
            return lhs.score == rhs.score && lhs.highCard() == rhs.highCard()
        }
    }

    static func < (lhs: BestHand, rhs: BestHand) -> Bool {
        guard lhs.score == rhs.score else {
            return lhs.score < rhs.score
        }

        guard lhs.highCard() == rhs.highCard() else {
            return lhs.highCard() < rhs.highCard()
        }

        guard lhs.secondHighCard() == rhs.secondHighCard() else {
            return lhs.secondHighCard() < rhs.secondHighCard()
        }

        return lhs.kicker() ?? .two < rhs.kicker() ?? .two
    }

    func highCard() -> Rank {
        return cards[0].rank
    }

    func secondHighCard() -> Rank {
        return cards.first { card in card.rank != highCard() }?.rank ?? .two
    }

    func kicker() -> Rank? {
        let hand = hand.groupedByRank()
        return cards.first(where: { card in !hand.contains(card) })?.rank ?? .two
    }

//    func secondHighCard(_ other: BestHand) -> Rank {
//        let highCards = hand.filter({ !other.hand.ranks().contains($0.rank) })
//        guard let highestCard = highCards.sorted().last else { return .two }
//        return highestCard.rank
//    }
}
