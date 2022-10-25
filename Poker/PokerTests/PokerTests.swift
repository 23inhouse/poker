//
//  PokerTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import XCTest
@testable import Poker

final class PokerTests: XCTestCase {
    var validTestCases: [(name: String, hands: [String], best: String, description: String)] = []
    var riverTestCases: [(name: String, hands: [String], best: String, description: String)] = []
    var invalidTestCases: [(name: String, hand: String)] = []

    func testInvalidCases() {
        for each in invalidTestCases {
            XCTAssertNil(Hand(each.hand), "\(each.name)")
        }
    }

    func testAllValidCases() {
        for each in validTestCases {
            let bestHand = Poker.bestHand(each.hands)
            XCTAssertEqual(bestHand.cards, each.best, "\(each.name)")
            XCTAssertEqual(bestHand.label, each.description, "\(each.name)")
        }
    }

    func testAllRiverCases() {
        for each in riverTestCases {
            let bestHand = Poker.bestHand(each.hands)
            XCTAssertEqual(bestHand.cards, each.best, "\(each.name)")
            XCTAssertEqual(bestHand.label, each.description, "\(each.name)")
        }
    }

    override func setUp() {
        super.setUp()

        validTestCases = [
            (
                name: "single hand is always best",
                hands: ["3♡ 10♢ 7♧ 8♤ A♢"],
                best: "3♡ 10♢ 7♧ 8♤ A♢",
                description: "A high"
            ),
            (
                name: "highest card",
                hands: ["3♢ 2♢ 5♤ 6♤ 9♡", "3♡ 2♡ 5♧ 6♢ 10♡"],
                best: "3♡ 2♡ 5♧ 6♢ 10♡",
                description: "10 high"
            ),
            (
                name: "One pair",
                hands: ["3♢ 2♢ 5♤ 6♤ 9♡", "3♡ 3♤ 5♧ 6♢ 9♢"],
                best: "3♡ 3♤ 5♧ 6♢ 9♢",
                description: "Pair of 3s"
            ),
            (
                name: "pair beats lower",
                hands: ["4♢ 3♤ 4♤ J♤ K♤", "A♡ K♡ J♢ 10♧ 9♡"],
                best: "4♢ 3♤ 4♤ J♤ K♤",
                description: "Pair of 4s"
            ),
            (
                name: "best pair",
                hands: ["4♡ 2♡ 5♧ 4♢ 10♡", "3♢ 3♡ 5♤ 6♤ 9♡"],
                best: "4♡ 2♡ 5♧ 4♢ 10♡",
                description: "Pair of 4s"
            ),
            (
                name: "best pair with same pair and highest cards",
                hands: ["4♡ 2♡ 5♧ 4♢ 10♡", "4♤ 4♧ 5♡ 10♢ 3♡"],
                best: "4♤ 4♧ 5♡ 10♢ 3♡",
                description: "Pair of 4s"
            ),
            (
                name: "two pair beats lower",
                hands: [
                    "4♢ 3♤ 4♤ J♤ K♤",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "2♢ 8♡ 5♢ 2♡ 8♧",
                description: "Two pair 8s & 2s"
            ),
            (
                name: "best two pair",
                hands: [
                    "4♢ J♧ 4♤ J♤ K♤",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "4♢ J♧ 4♤ J♤ K♤",
                description: "Two pair Js & 4s"
            ),
            (
                name: "best two pair with equal highest pair",
                hands: [
                    "4♢ J♧ 4♤ J♤ K♤",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "3♢ J♡ 5♢ 3♡ J♢"
                ],
                best: "4♢ J♧ 4♤ J♤ K♤",
                description: "Two pair Js & 4s"
            ),
            (
                name: "best two pair with equal pairs",
                hands: [
                    "4♢ J♧ 4♤ J♤ 2♤",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "4♧ J♡ 5♢ 4♡ J♢"
                ],
                best: "4♧ J♡ 5♢ 4♡ J♢",
                description: "Two pair Js & 4s"
            ),
            (
                name: "full house",
                hands: [
                    "4♢ 3♤ 4♤ J♤ K♤",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "3♡ 8♡ 3♢ 3♧ 8♧",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "3♡ 8♡ 3♢ 3♧ 8♧",
                description: "Full house"
            ),
            (
                name: "best three of a kind",
                hands: [
                    "4♢ 3♤ 4♤ J♤ 4♡",
                    "A♡ K♡ J♢ 10♧ 9♡",
                    "3♢ 8♡ 3♡ 3♧ 9♧",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "4♢ 3♤ 4♤ J♤ 4♡",
                description: "Three of a kind 4s"
            ),
            (
                name: "straight beats lower",
                hands: [
                    "4♢ 3♤ 4♤ J♤ K♤",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♡ 8♡ 3♢ 3♧ 9♧",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "Q♡ K♡ J♢ 10♧ 9♡",
                description: "Straight K high"
            ),
            (
                name: "straight includes ace as one",
                hands: [
                    "4♢ 3♤ 4♤ J♤ K♤",
                    "2♤ 3♡ A♤ 5♤ 4♤",
                    "3♢ 8♡ 3♡ 3♧ 9♧",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "2♤ 3♡ A♤ 5♤ 4♤",
                description: "Straight A high"
            ),
            (
                name: "best straight",
                hands: [
                    "4♢ 3♤ 4♤ J♤ K♤",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "A♢ K♧ 10♢ J♢ Q♢",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "A♢ K♧ 10♢ J♢ Q♢",
                description: "Straight A high"
            ),
            (
                name: "flush beats lower",
                hands: [
                    "4♤ 3♤ 8♤ J♤ K♤",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♢ 8♡ 3♢ 3♧ 9♧",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "4♤ 3♤ 8♤ J♤ K♤",
                description: "Flush K high"
            ),
            (
                name: "best flush",
                hands: [
                    "4♤ 3♤ 8♤ J♤ K♤",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♢ 8♢ A♢ 2♢ 7♢",
                    "2♢ 8♡ 5♢ 2♡ 8♧"
                ],
                best: "3♢ 8♢ A♢ 2♢ 7♢",
                description: "Flush A high"
            ),
            (
                name: "full house beats lower",
                hands: [
                    "4♤ 3♤ 8♤ J♤ K♤",
                    "2♢ 8♡ 8♢ 2♡ 8♧",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♡ A♡ 3♢ 3♧ A♧"
                ],
                best: "2♢ 8♡ 8♢ 2♡ 8♧",
                description: "Full house"
            ),
            (
                name: "full house (low card) beats lower",
                hands: [
                    "4♤ 3♤ 8♤ J♤ K♤",
                    "4♢ 8♡ 8♢ 4♡ 4♧",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♡ A♡ 3♢ 3♧ A♧"
                ],
                best: "4♢ 8♡ 8♢ 4♡ 4♧",
                description: "Full house"
            ),
            (
                name: "best full house",
                hands: [
                    "4♤ 3♤ 8♤ J♤ K♤",
                    "2♢ 8♡ 8♢ 2♡ 8♧",
                    "5♡ 5♢ A♤ 5♧ A♢",
                    "3♡ A♡ 3♢ 3♧ A♧"
                ],
                best: "2♢ 8♡ 8♢ 2♡ 8♧",
                description: "Full house"
            ),
            (
                name: "four of a kind beats lower",
                hands: [
                    "4♤ 5♤ 8♤ J♤ K♤",
                    "2♢ 8♡ 8♢ 2♡ 8♧",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♢ 3♡ 3♤ 3♧ A♧"
                ],
                best: "3♢ 3♡ 3♤ 3♧ A♧",
                description: "Four of a kind 3s"
            ),
            (
                name: "best four of a kind",
                hands: [
                    "4♤ 5♤ 8♤ J♤ K♤",
                    "2♢ 2♧ 8♢ 2♡ 2♤",
                    "Q♡ K♡ J♢ 10♧ 9♡",
                    "3♢ 3♡ 3♤ 3♧ A♧"
                ],
                best: "3♢ 3♡ 3♤ 3♧ A♧",
                description: "Four of a kind 3s"
            ),
            (
                name: "straight flush beats lower",
                hands: [
                    "4♤ 4♢ 4♡ 4♧ K♤",
                    "2♢ 8♡ 8♢ 2♡ 8♧",
                    "Q♡ K♡ 8♡ 10♡ 9♡",
                    "2♤ 3♤ A♤ 5♤ 4♤"
                ],
                best: "2♤ 3♤ A♤ 5♤ 4♤",
                description: "Royal Flush"
            ),
            (
                name: "best straight flush is royal flush",
                hands: [
                    "4♤ 5♤ 8♤ J♤ K♤",
                    "2♢ 8♡ 8♢ 2♡ 8♧",
                    "Q♡ K♡ J♡ 10♡ 9♡",
                    "Q♢ K♢ J♢ 10♢ A♢"
                ],
                best: "Q♢ K♢ J♢ 10♢ A♢",
                description: "Straight Flush A high"
            ),
            (
                name: "tie for best pair: brake tide by suit",
                hands: ["4♡ 2♡ 5♧ 4♢ 10♡", "4♧ 10♢ 5♤ 2♤ 4♤"],
                best: "4♧ 10♢ 5♤ 2♤ 4♤",
                description: "Pair of 4s"
            ),
            (
                name: "preflop pocket aces",
                hands: [
                    "A♡ 2♡",
                    "A♤ A♧"
                ],
                best: "A♤ A♧",
                description: "Pair of As"
            ),
            (
                name: "nut flush draw",
                hands: [
                    "6♤ A♤ K♡ 2♤ 7♡ J♤ 8♤",
                    "9♤ J♧ K♡ 2♤ 7♡ J♤ 8♤"
                ],
                best: "6♤ A♤ K♡ 2♤ 7♡ J♤ 8♤",
                description: "Flush A high"
            )
        ]

        riverTestCases = [
            (
                name: "straight on the river beats lower",
                hands: [
                    "4♤ J♤ Q♡ K♡ J♢ 10♧ 9♡",
                    "4♧ 3♤ A♢ K♧ 10♢ J♢ Q♢",
                ],
                best: "4♧ 3♤ A♢ K♧ 10♢ J♢ Q♢",
                description: "Straight A high"
            ),
            (
                name: "straight on the river beats pair of kings",
                hands: [
                    "K♧ 4♤ 6♧ J♧ 7♤ 8♢ K♡",
                    "10♡ 9♡ 6♧ J♧ 7♤ 8♢ K♡",
                ],
                best: "10♡ 9♡ 6♧ J♧ 7♤ 8♢ K♡",
                description: "Straight K high"
            ),
            (
                name: "two pair on the river beats lower",
                hands: [
                    "K♧ 9♢ 10♤ 9♡ A♤ A♡ K♢",
                    "3♡ 3♢ 10♤ 9♡ A♤ A♡ K♢",
                    "10♢ 2♢ 10♤ 9♡ A♤ A♡ K♢",
                ],
                best: "K♧ 9♢ 10♤ 9♡ A♤ A♡ K♢",
                description: "Two pair As & Ks"
            ),
            (
                name: "two pair on the river",
                hands: [
                    "K♧ 9♢ 10♤ 9♡ A♤ A♡ K♢",
                ],
                best: "K♧ 9♢ 10♤ 9♡ A♤ A♡ K♢",
                description: "Two pair As & Ks"
            ),
            (
                name: "straight on the river beats three of a kind",
                hands: [
                    "3♡ K♡ 9♤ 10♤ Q♤ J♡ 10♢",
                    "10♧ 3♢ 9♤ 10♤ Q♤ J♡ 10♢",
                ],
                best: "3♡ K♡ 9♤ 10♤ Q♤ J♡ 10♢",
                description: "Straight K high"
            )
        ]

        invalidTestCases = [
            (
                name: "1 is an invalid card rank",
                hand: "1♢ 2♡ 3♡ 4♡ 5♡"
            ),
            (
                name: "15 is an invalid card rank",
                hand: "15♢ 2♡ 3♡ 4♡ 5♡"
            ),
            (
                name: "lack of rank",
                hand: "11♢ 2♡ ♡ 4♡ 5♡"
            ),
            (
                name: "lack of suit",
                hand: "2♡ 3♡ 4 5♡ 7♡"
            ),
            (
                name: "H is an invalid suit",
                hand: "2♡ 3♡ 4H 5♡ 7♡"
            ),
            (
                name: "♥ is an invalid suit",
                hand: "2♡ 3♡ 4♥ 5♡ 7♡"
            ),
            (
                name: "lack of spacing",
                hand: "2♡ 3♡ 5♡7♡ 8♡"
            ),
            (
                name: "double suits after rank",
                hand: "2♡ 3♡ 5♡♡ 8♡ 9♡"
            )
        ]
    }
}
