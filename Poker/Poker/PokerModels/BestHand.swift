//
//  BestHand.swift
//  Poker
//
//  Created by Benjamin Lewis on 26/10/2022.
//

import Foundation

struct BestHand {
    typealias HandLogic = ([Card]) -> (hand: Hand, label: String)?

    var hand: Hand?
    var cards: [Card] = []
    var score: Int = 0
    var label: String = ""
    var tieBreakingKickerCard: Card?

    init(cards: [Card]) {
        self.cards = cards.sorted().reversed()

        guard !cards.isEmpty else { return }

        for (index, logic) in BestHand.logics.enumerated() {
            guard let bestLogic = logic(cards) else { continue }
            guard bestLogic.hand.isEmpty else {
                let score = BestHand.logics.count - index

                self.hand = bestLogic.hand
                self.label = bestLogic.label
                self.score = score
//                print("BestHand.init:", "cards:", cards, "hand:", bestLogic.hand, "score:", score, "highCard:", highCard(), "secondHighCard:", secondHighCard() ?? .two, "label:", label)
                return
            }
        }
    }

    init(hand: Hand) {
        self.init(cards: hand.cards)
    }

    var handWithKicker: [Card] {
        guard let hand = hand else { return [] }
        guard let tieBreakingKickerCard = tieBreakingKickerCard else { return hand.cards }

        return hand.cards + [tieBreakingKickerCard]
    }

    static func from(_ description: String) -> BestHand? {
        guard let hand = Hand.from(description) else { return nil }
        return BestHand(hand: hand)
    }

    static func check(_ hands: [Hand]) -> BestHand? {
        return hands.map({ BestHand(hand: $0) }).sorted().last
    }

    static let logics: [HandLogic] = [royalFlush, straightFlush, fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, pair, highCard]

    static let royalFlush: HandLogic = { cards in
        guard let straightFlush = straightFlush(cards) else { return nil }

        let hand = straightFlush.hand
        guard hand.count == 5 else { return nil }
        guard hand[0].rank == .ace else { return nil }
        guard hand[4].rank == .ten else { return nil }
        return (hand, "Royal Flush")
    }

    static let straightFlush: HandLogic = { cards in
        guard let straight = straight(cards) else { return nil }
        let straightCards = straight.hand.cards
        guard straightCards.count == 5 else { return nil }
        guard let flushCards = flush(straightCards) else { return nil }
        guard flushCards.hand.cards.count == 5 else { return nil }
        return (Hand(cards: straightCards), "Straight Flush \(highCard(flushCards.hand.cards)!.label)")
    }

    static let fourOfAKind: HandLogic = { cards in
        let hand = Hand(cards: cards)
        var rankedCards = hand.groupedByRank()
        guard rankedCards.count == 4 && rankedCards.first!.rank == rankedCards.last!.rank else { return nil }
        return (Hand(cards: rankedCards), "Four of a kind \(rankedCards[0].rank)s")
    }

    static let fullHouse: HandLogic = { cards in
        let hand = Hand(cards: cards)
        var rankedCards = Array(hand.groupedByRank().prefix(5))
        guard rankedCards.count == 5 else { return nil }
        if rankedCards[0].rank != rankedCards[2].rank {
            rankedCards.reverse()
        }
        return (Hand(cards: rankedCards), "Full house")
    }

    static let flush: HandLogic = { cards in
        let hand = Hand(cards: cards)
        let suitedCards = hand.groupedBySuit()
        guard suitedCards.count == 5 else { return nil }
        return (Hand(cards: suitedCards), "Flush \(highCard([suitedCards[0]])!.label)")
    }

    static let straight: HandLogic = { cards in
        let hand = Hand(cards: cards)
        let straightCards = hand.groupedByStraights()
        guard straightCards.count == 5 else { return nil }
        return (Hand(cards: straightCards), "Straight \(highCard([straightCards[0]])!.label)")
    }

    static let threeOfAKind: HandLogic = { cards in
        let hand = Hand(cards: cards)
        var rankedCards = Array(hand.groupedByRank())
        guard rankedCards.count == 3 else { return nil }
        return (Hand(cards: rankedCards), "Three of a kind \(rankedCards[0].rank)s")
    }

    static let twoPair: HandLogic = { cards in
        let hand = Hand(cards: cards)
        var rankedCards = Array(hand.groupedByRank().prefix(4))
        guard rankedCards.count == 4 else { return nil }
        return (Hand(cards: rankedCards), "Two pair \(rankedCards[0].rank)s & \(rankedCards[3].rank)s")
    }

    static let pair: HandLogic = { cards in
        let hand = Hand(cards: cards)
        var rankedCards = hand.groupedByRank()
        guard rankedCards.count == 2 else { return nil }
        return (Hand(cards: rankedCards), "Pair of \(rankedCards[0].rank)s")
    }

    static let highCard: HandLogic = { cards in
        let cards = Array(cards.sorted().reversed())
        guard let firstCard = cards.first else { return (Hand(), "No hand") }
        let hand = Hand(cards: [firstCard])
        return (hand, "\(firstCard.rank) high")
    }
}

extension BestHand: Hashable {}

extension BestHand: Comparable {
    static func == (lhs: BestHand, rhs: BestHand) -> Bool {
        guard lhs.score == rhs.score else { return false }

        return !(lhs < rhs || lhs > rhs)
    }

    static func < (lhs: BestHand, rhs: BestHand) -> Bool {
        guard lhs.score == rhs.score else { return lhs.score < rhs.score }

        guard let lhsHand = lhs.hand, let rhsHand = rhs.hand else { return false }
        let numberOfCards = [lhsHand.count, rhsHand.count].min() ?? 0
        guard numberOfCards > 0 else { return false }

        for index in 0..<numberOfCards {
            if lhsHand[index].rank < rhsHand[index].rank {
                return true
            }
        }

        let lhsKickers = lhs.kickerCards()
        let rhsKickers = rhs.kickerCards()

        let numberOfKickers = [lhsKickers.count, rhsKickers.count].min() ?? 0
        guard numberOfKickers > 0 else { return false }

        for index in 0..<numberOfKickers {
            if lhsKickers[index].rank < rhsKickers[index].rank {
                return true
            }
        }

        return false
    }

    func kickerCards() -> [Card] {
        guard let hand = hand else { return cards }
        let kickerCards = cards.filter { card in !hand.contains(card) }
        return Array(kickerCards.prefix(Hand.maxNumberOfCards - hand.count))
    }
}

extension BestHand: CustomStringConvertible {
    var description: String {
        guard let tieBreakingKickerCard = tieBreakingKickerCard else { return label }
        return "\(label) [\(tieBreakingKickerCard.rank) kicker]"
    }
}
