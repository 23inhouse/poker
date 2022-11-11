//
//  CardTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 26/10/2022.
//

import XCTest
@testable import Poker

final class CardTests: XCTestCase {
    func testEquality() throws {
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .ace, suit: .spades)

        XCTAssertEqual(card1, card2)
    }

    func testInequality() throws {
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .ace, suit: .hearts)

        XCTAssertNotEqual(card1, card2)
    }

    func testSorting() throws {
        let cardPairs: [(high: Card, low: Card)] = [
            (Card(rank: .ace), Card(rank: .king)),
            (Card(rank: .ace), Card(rank: .two)),
            (Card(rank: .three), Card(rank: .two)),
            (Card(rank: .jack), Card(rank: .ten)),
            (Card(rank: .ace, suit: .spades), Card(rank: .ace, suit: .hearts))
        ]

        for pair in cardPairs {
            XCTAssertGreaterThan(pair.high, pair.low)
        }
    }

    func testDescription() throws {
        let card1 = Card(rank: .ace, suit: .spades)
        let card2 = Card(rank: .ten, suit: .hearts)

        XCTAssertEqual(card1.description, "A♤")
        XCTAssertEqual(card2.description, "10♡")
    }

    func testFromInitializer() throws {
        let card1 = Card.from("A♤")!
        let card2 = Card.from("10♡")!
        let card3 = Card.from("10 ♡")

        XCTAssertEqual(card1.description, "A♤")
        XCTAssertEqual(card2.description, "10♡")
        XCTAssertNil(card3)
    }
}
