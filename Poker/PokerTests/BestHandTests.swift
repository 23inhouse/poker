//
//  BestHandTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 25/10/2022.
//

import XCTest
@testable import Poker

final class BestHandTests: XCTestCase {
    func testEquality() throws {
        let hand1 = BestHand.from("A♡ K♢")
        let hand2 = BestHand.from("A♧ K♤")

        XCTAssertEqual(hand1, hand2)
    }

    func testEqualityOutOfOrder() throws {
        let hand1 = BestHand.from("A♡ K♢")!
        let hand2 = BestHand.from("K♤ A♧")!

        XCTAssertEqual(hand1, hand2)
    }

    func testInequality() throws {
        let hand1 = BestHand.from("A♡ A♢")
        let hand2 = BestHand.from("2♤ 2♧")

        XCTAssertNotEqual(hand1, hand2)
    }

    func testSorting() throws {
        let bestHands: [(high: BestHand, low: BestHand, desc: String)] = [
            (BestHand.from("A♡")!, BestHand.from("K♤")!, "High card beats lower"),
            (BestHand.from("A♡ K♡")!, BestHand.from("A♡ Q♤")!, "High card with kicker beats lower"),

            (BestHand.from("K♡ K♢")!, BestHand.from("A♧")!, "Pair beats High card"),
            (BestHand.from("A♡ A♢")!, BestHand.from("2♤ 2♧")!, "Pair beats lower"),
            (BestHand.from("A♡ A♢ K♢")!, BestHand.from("A♤ A♧ 2♧")!, "Pair with kicker beats lower"),

            (BestHand.from("2♡ 2♢ 3♤ 3♧")!, BestHand.from("A♡ A♢")!, "Two pair beats High pair"),
            (BestHand.from("A♡ A♢ K♤ K♧")!, BestHand.from("A♡ A♢ Q♤ Q♧")!, "Two pair beats lower"),
            (BestHand.from("A♡ A♢ K♤ K♧ Q♧")!, BestHand.from("A♡ A♢ K♤ K♧ J♧")!, "Two pair with kicker beats lower"),

            (BestHand.from("2♡ 2♢ 2♤")!, BestHand.from("A♡ A♢ K♤ K♧")!, "Three of a kind beats Two pair"),
            (BestHand.from("3♡ 3♢ 3♤")!, BestHand.from("2♡ 2♢ 2♤")!, "Three of a kind beats lower"),
            (BestHand.from("3♡ 3♢ 3♤ A♤")!, BestHand.from("3♡ 3♢ 3♤ K♤")!, "Three of a kind with kicker beats lower"),

            (BestHand.from("2♡ 3♢ 4♤ 5♢ 6♤")!, BestHand.from("A♡ A♢ A♤")!, "Straight beats Three of a kind"),
            (BestHand.from("2♡ 3♢ 4♤ 5♢ 6♤")!, BestHand.from("2♡ 3♢ 4♤ 5♢ A♤")!, "Straight beats lower"),
            (BestHand.from("3♢ 4♤ 5♢ 6♤ 7♡")!, BestHand.from("2♡ 3♢ 4♤ 5♢ 6♤")!, "Straight beats lower"),

            (BestHand.from("2♡ 4♡ 6♡ 7♡ K♡")!, BestHand.from("2♡ 3♢ 4♤ 5♢ 6♤")!, "Flush beats Straight"),
            (BestHand.from("K♡ 2♡ 4♡ 6♡ 7♡")!, BestHand.from("Q♡ 2♡ 4♡ 6♡ 7♡")!, "Flush beats lower"),
            (BestHand.from("K♡ J♡ 8♡ 7♡ 6♡")!, BestHand.from("K♡ 9♡ 8♡ 7♡ 6♡")!, "Flush beats lower"),
            (BestHand.from("K♡ J♡ 8♡ 7♡ 6♡")!, BestHand.from("K♡ J♡ 8♡ 7♡ 5♡")!, "Flush beats lower"),

            (BestHand.from("2♤ 2♧ 2♡ 7♢ 7♡")!, BestHand.from("Q♡ 2♡ 4♡ 6♡ 7♡")!, "Fullhouse beats Flush"),
            (BestHand.from("3♤ 3♧ 3♡ K♢ K♡")!, BestHand.from("2♤ 2♧ 2♡ A♢ A♡")!, "Fullhouse beats lower high card"),
            (BestHand.from("3♤ 3♧ 3♡ A♢ A♡")!, BestHand.from("3♤ 3♧ 3♡ K♢ K♡")!, "Fullhouse beats lower second card"),

            (BestHand.from("2♤ 2♧ 2♡ 2♢")!, BestHand.from("A♤ A♧ A♡ K♢ K♡")!, "Four of a kind beats Fullhouse"),
            (BestHand.from("3♤ 3♧ 3♡ 3♢")!, BestHand.from("2♤ 2♧ 2♡ 2♢")!, "Four of a kind beats lower"),
            (BestHand.from("A♤ A♧ A♡ A♢ K♢")!, BestHand.from("A♤ A♧ A♡ A♢ Q♢")!, "Four of a kind with kicker beats lower"),

            (BestHand.from("2♡ 3♡ 4♡ 5♡ 6♡")!, BestHand.from("A♤ A♧ A♡ A♢ K♢")!, "Straight Flush beats Four of a kind"),
            (BestHand.from("2♡ 3♡ 4♡ 5♡ 6♡")!, BestHand.from("A♡ 2♡ 3♡ 4♡ 5♡")!, "Straight Flush beats lower"),
            (BestHand.from("3♡ 4♡ 5♡ 6♡ 7♡")!, BestHand.from("2♡ 3♡ 4♡ 5♡ 6♡")!, "Straight Flush beats lower"),

            (BestHand.from("A♡ K♡ Q♡ J♡ 10♡")!, BestHand.from("K♤ Q♤ J♤ 10♤ 9♤")!, "Royal Flush beats Straight Flush"),
        ]

        for hands in bestHands {
            XCTAssertGreaterThan(hands.high, hands.low, hands.desc)
            // NOTE: really really make sure
            XCTAssertEqual([hands.low, hands.high].sorted().last!, hands.high, hands.desc)
            XCTAssertEqual([hands.high, hands.low].sorted().last!, hands.high, hands.desc)
        }
    }

    func testSortingOnTheRiver() throws {
        let bestHands: [(high: BestHand, low: BestHand, desc: String)] = [
            (BestHand.from("K♡ K♢ A♧ 7♢ 6♢ 5♢ J♢")!, BestHand.from("A♧ 8♢ A♧ 7♢ 6♢ 5♢ J♢")!, "Straight Flush beats lower"),
            (BestHand.from("K♡ 8♡ J♢ J♤ 10♢ 9♧ K♧")!, BestHand.from("10♧ 4♡ J♢ J♤ 10♢ 9♧ K♧")!, "Two Pair beats lower"),
        ]

        for hands in bestHands {
            XCTAssertGreaterThan(hands.high, hands.low, hands.desc)
            // NOTE: really really make sure
            XCTAssertEqual([hands.low, hands.high].sorted().last!, hands.high, hands.desc)
            XCTAssertEqual([hands.high, hands.low].sorted().last!, hands.high, hands.desc)
        }
    }

    func testDescription() throws {
        let expectations: [(hand: Hand, description: String)] = [
            (Hand.from("A♡ K♢")!, "A high"),
            (Hand.from("2♤ 2♧")!, "Pair of 2s"),
            (Hand.from("2♤ 2♧ A♡ A♢")!, "Two pair As & 2s"),
            (Hand.from("2♤ 2♧ 2♡ A♢")!, "Three of a kind 2s"),
            (Hand.from("A♤ 2♧ 3♡ 4♢ 5♢")!, "Straight 5 high"),
            (Hand.from("6♤ 2♧ 3♡ 4♢ 5♢")!, "Straight 6 high"),
            (Hand.from("7♤ 2♤ 3♤ 4♤ 5♤")!, "Flush 7 high"),
            (Hand.from("2♤ 2♧ 2♡ 7♢ 7♡")!, "Full house"),
            (Hand.from("2♤ 2♧ 2♡ 2♢")!, "Four of a kind 2s"),
            (Hand.from("6♤ 2♤ 3♤ 4♤ 5♤")!, "Straight Flush 6 high"),
            (Hand.from("A♤ 2♤ 3♤ 4♤ 5♤")!, "Straight Flush A high"),
            (Hand.from("A♤ K♤ Q♤ J♤ 10♤")!, "Royal Flush"),
        ]

        for expectation in expectations {
            let bestHand = BestHand(hand: expectation.hand)
            XCTAssertEqual(bestHand.description, expectation.description)
        }
    }

    func testDescriptionFromRiver() throws {
        let expectations: [(hand: Hand, description: String)] = [
            (Hand.from("K♡ K♢ A♧ 7♢ 6♢ 5♢ J♢")!, "Flush K high"),
        ]

        for expectation in expectations {
            let bestHand = BestHand(hand: expectation.hand)
            XCTAssertEqual(bestHand.description, expectation.description)
        }
    }

    func testKickerCards() throws {
        let expectations: [(hand: Hand, best: Hand, kickers: [Rank], description: String)] = [
            (Hand.from("A♡ K♢")!, Hand.from("A♡")!, [.king], "A high"),
            (Hand.from("2♤ 2♧")!, Hand.from("2♤ 2♧")!, [], "Pair of 2s"),
            (Hand.from("2♤ 2♧ A♡ Q♢ 10♤")!, Hand.from("2♤ 2♧")!, [.ace, .queen, .ten], "Pair of 2s with kickers"),
            (Hand.from("2♤ 2♧ A♡ A♢")!, Hand.from("A♡ A♢ 2♤ 2♧")!, [], "Two pair As & 2s"),
            (Hand.from("2♤ 2♧ A♡ A♢ 3♢")!, Hand.from("A♡ A♢ 2♤ 2♧")!, [.three], "Two pair As & 2s with kickers"),
            (Hand.from("2♤ 2♧ 2♡ A♢")!, Hand.from("2♤ 2♡ 2♧")!, [.ace], "Three of a kind 2s"),
            (Hand.from("2♤ 2♧ 2♡ A♢ 3♢")!, Hand.from("2♤ 2♡ 2♧")!, [.ace, .three], "Three of a kind 2s with kickers"),
            (Hand.from("A♤ 2♧ 3♡ 4♢ 5♢")!, Hand.from("5♢ 4♢ 3♡ 2♧ A♤")!, [], "Straight 5 high"),
            (Hand.from("6♤ 2♧ 3♡ 4♢ 5♢")!, Hand.from("6♤ 5♢ 4♢ 3♡ 2♧")!, [], "Straight 6 high"),
            (Hand.from("7♤ 2♤ 3♤ 4♤ 5♤")!, Hand.from("7♤ 5♤ 4♤ 3♤ 2♤")!, [], "Flush 7 high"),
            (Hand.from("2♤ 2♧ 2♡ 7♢ 7♡")!, Hand.from("2♧ 2♡ 2♤ 7♢ 7♡")!, [], "Full house"),
            (Hand.from("2♤ 2♧ 2♡ 2♢")!, Hand.from("2♤ 2♡ 2♧ 2♢")!, [], "Four of a kind 2s"),
            (Hand.from("2♤ 2♧ 2♡ 2♢ A♢")!, Hand.from("2♤ 2♡ 2♧ 2♢")!, [.ace], "Four of a kind 2s with kickers"),
            (Hand.from("6♤ 2♤ 3♤ 4♤ 5♤")!, Hand.from("6♤ 5♤ 4♤ 3♤ 2♤")!, [], "Straight Flush 6 high"),
            (Hand.from("A♤ 2♤ 3♤ 4♤ 5♤")!, Hand.from("5♤ 4♤ 3♤ 2♤ A♤")!, [], "Straight Flush 5 high"),
            (Hand.from("A♤ K♤ Q♤ J♤ 10♤")!, Hand.from("A♤ K♤ Q♤ J♤ 10♤")!, [], "Royal Flush"),
        ]

        for expectation in expectations {
            let bestHand = BestHand(hand: expectation.hand)
            XCTAssertEqual(bestHand.hand!.cards, expectation.best.cards, expectation.description)
            XCTAssertEqual(bestHand.kickerCards().map(\.rank), expectation.kickers, expectation.description)
        }
    }

    func testKickerCardsOnTheRiver() throws {
        let expectations: [(hand: Hand, best: Hand, kickers: [Rank], description: String)] = [
            (Hand.from("A♡ K♢ J♢ 9♤ 7♢ 5♤ 3♢")!, Hand.from("A♡")!, [.king, .jack, .nine, .seven], "A high with kickers"),
            (Hand.from("2♤ 2♧ A♡ Q♢ 10♤ 8♢ 6♤")!, Hand.from("2♤ 2♧")!, [.ace, .queen, .ten], "Pair of 2s with kickers"),
            (Hand.from("2♤ 2♧ A♡ A♢ K♢ J♢ 3♢")!, Hand.from("A♡ A♢ 2♤ 2♧")!, [.king], "Two pair As & 2s with kickers"),
            (Hand.from("2♤ 2♧ 2♡ A♢ K♢ J♢ 3♢")!, Hand.from("2♤ 2♡ 2♧")!, [.ace, .king], "Three of a kind 2s with kickers"),
            (Hand.from("A♤ 2♧ 3♡ 4♢ 5♢ 8♢ 9♢")!, Hand.from("5♢ 4♢ 3♡ 2♧ A♤")!, [], "Straight 5 high"),
            (Hand.from("7♤ 2♤ 3♤ 4♤ 5♤ 9♢ J♢")!, Hand.from("7♤ 5♤ 4♤ 3♤ 2♤")!, [], "Flush 7 high"),
            (Hand.from("2♤ 2♧ 2♡ 7♢ 7♡ 9♢ J♢")!, Hand.from("2♧ 2♡ 2♤ 7♢ 7♡")!, [], "Full house"),
            (Hand.from("2♤ 2♧ 2♡ 2♢ A♢ K♢ J♢")!, Hand.from("2♤ 2♡ 2♧ 2♢")!, [.ace], "Four of a kind 2s with kickers"),
            (Hand.from("6♤ 2♤ 3♤ 4♤ 5♤ 9♢ J♢")!, Hand.from("6♤ 5♤ 4♤ 3♤ 2♤")!, [], "Straight Flush 6 high"),
            (Hand.from("A♤ K♤ Q♤ J♤ 10♤ 6♢ 5♢")!, Hand.from("A♤ K♤ Q♤ J♤ 10♤")!, [], "Royal Flush"),

            (Hand.from("A♢ 3♡ 6♡ A♡ 2♧ 3♧ 2♡")!, Hand.from("A♡ A♢ 3♡ 3♧")!, [.six], "Two pair with high card kicker when hand has 3 pairs (low pair)"),
            (Hand.from("A♢ 6♡ 4♡ A♡ 5♧ 6♧ 5♡")!, Hand.from("A♡ A♢ 6♡ 6♧")!, [.five], "Two pair with high card kicker when hand has 3 pairs (low pair)"),
        ]

        for expectation in expectations {
            let bestHand = BestHand(hand: expectation.hand)
            XCTAssertEqual(bestHand.hand!.cards, expectation.best.cards, expectation.description)
            XCTAssertEqual(bestHand.kickerCards().map(\.rank), expectation.kickers, expectation.description)
        }
    }

    func testFromInitializer() throws {
        let hand1 = BestHand.from("A♤ 10♡")!
        let hand2 = BestHand.from("")!
        let hand3 = BestHand.from("A♤ 10 ♡")

        XCTAssertEqual(hand1.description, "A high")
        XCTAssertEqual(hand2.description, "")
        XCTAssertNil(hand3)
    }
}
