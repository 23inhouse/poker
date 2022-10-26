//
//  HandTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 26/10/2022.
//

import XCTest
@testable import Poker

final class HandTests: XCTestCase {
    func testEquality() throws {
        let hand1 = Hand.from("3♡ 10♢ 7♧ 8♤ A♢")
        let hand2 = Hand.from("3♡ 10♢ 7♧ 8♤ A♢")

        XCTAssertEqual(hand1, hand2)
    }

    func testDescription() throws {
        let hand = Hand(cards: [Card(rank: .ace, suit: .spades), Card(rank: .ten, suit: .hearts)])

        XCTAssertEqual(hand.description, "A♤ 10♡")
    }

    func testFromInitializer() throws {
        let hand1 = Hand.from("A♤ 10♡")!
        let hand2 = Hand.from("")!
        let hand3 = Hand.from("A♤ 10 ♡")

        XCTAssertEqual(hand1.description, "A♤ 10♡")
        XCTAssertEqual(hand2.description, "")
        XCTAssertNil(hand3)
    }

    func testGroupByRank() throws {
        let hand = Hand.from("4♢ J♧ 4♤ J♤ K♤")!
        let expectedHand = Hand.from("J♤ J♧ 4♤ 4♢")!

        XCTAssertEqual(hand.groupedByRank(), expectedHand.cards)
    }

    func testGroupBySuit() throws {
        let hand = Hand.from("6♤ 9♤ 4♤ J♤ K♤")!
        let expectedHand = Hand.from("K♤ J♤ 9♤ 6♤ 4♤")!

        XCTAssertEqual(hand.groupedBySuit(), expectedHand.cards)
    }

    func testGroupBySuitLessThanFiveOfTheSuit() throws {
        let hand = Hand.from("4♢ J♡ 4♤ J♤ K♤")!

        XCTAssertEqual(hand.groupedBySuit(), [])
    }

    func testGroupByStraights() throws {
        let hand = Hand.from("2♤ 3♡ 4♡ 5♤ 6♤")!
        let expectedHand = Hand.from("6♤ 5♤ 4♡ 3♡ 2♤")!

        XCTAssertEqual(hand.groupedByStraights(), expectedHand.cards)
    }

    func testGroupByStraightsWithAce() throws {
        let hand = Hand.from("A♡ 2♡ 3♤ 4♤ 5♤")!
        let expectedHand = Hand.from("5♤ 4♤ 3♤ 2♡ A♡")!

        XCTAssertEqual(hand.groupedByStraights(), expectedHand.cards)
    }

    func testGroupByStraightsLessThanFiveInTheStraight() throws {
        let hand = Hand.from("2♢ 3♡ 2♡ 4♤ 5♤ K♤")!

        XCTAssertEqual(hand.groupedBySuit(), [])
    }
}
