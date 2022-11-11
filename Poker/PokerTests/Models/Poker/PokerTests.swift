//
//  PokerTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 18/10/2022.
//

import XCTest
@testable import Poker

final class PokerTests: XCTestCase {
    func testCalcWinningHands() {
        let bestHands: [(h1: BestHand, h2: BestHand, winners: [BestHand], label: String, desc: String)] = [
            (BestHand.from("A♡")!, BestHand.from("K♤")!, [BestHand.from("A♡")!], "A high", "High card beats lower"),
            (BestHand.from("A♡ K♡")!, BestHand.from("A♡ Q♤")!, [BestHand.from("A♡ K♡")!], "A high [K kicker]", "High card with kicker beats lower"),
            (BestHand.from("A♡ K♡ 8♢ 6♢ 4♡")!, BestHand.from("A♡ K♡ 8♢ 6♢ 5♤")!, [BestHand.from("A♡ K♡ 8♢ 6♢ 5♤")!], "A high [5 kicker]", "High card with kicker beats lower"),
            (BestHand.from("9♡ 7♡ J♧ 9♢ 8♢")!, BestHand.from("7♢ 9♧ J♧ 9♢ 8♢")!, [BestHand.from("9♡ 7♡ J♧ 9♢ 8♢")!, BestHand.from("7♢ 9♧ J♧ 9♢ 8♢")!], "Pair of 9s", "Pair with equal kickers"),
        ]

        for hands in bestHands {
            let playerOne = Player(cards: hands.h1.cards)
            let playerTwo = Player(cards: hands.h2.cards)
            let players = [playerOne, playerTwo]
            let bestHands = Poker.calcBestHands(from: players)
            XCTAssertEqual(bestHands, [hands.h1, hands.h2], hands.desc)

            let winningHands = Poker.calcWinningHands(from: [hands.h1, hands.h2])
            XCTAssertEqual(winningHands, hands.winners, hands.desc)

            let kickerHands = Poker.calcBestHandWithKicker(from: [hands.h1, hands.h2], winningHands: hands.winners)
            let kickerHand = kickerHands.first { hand in hand == hands.winners.first }
            XCTAssertEqual(kickerHand!.description, hands.label, hands.desc)
        }
    }

    func testCalcWinningHandsOnRiver() {
        let bestHands: [(h1: BestHand, h2: BestHand, winners: [BestHand], label: String, desc: String)] = [
            (BestHand.from("10♧ 4♡ J♢ J♤ 10♢ 9♧ K♧")!, BestHand.from("K♡ 8♡ J♢ J♤ 10♢ 9♧ K♧")!, [BestHand.from("K♡ 8♡ J♢ J♤ 10♢ 9♧ K♧")!], "Two Pair of Ks & Ks", "Two Pair beats lower"),
        ]

        for hands in bestHands {
            let playerOne = Player(cards: hands.h1.cards)
            let playerTwo = Player(cards: hands.h2.cards)
            let players = [playerOne, playerTwo]
            let bestHands = Poker.calcBestHands(from: players)
            XCTAssertEqual(bestHands, [hands.h1, hands.h2], hands.desc)

            let winningHands = Poker.calcWinningHands(from: [hands.h1, hands.h2])
            XCTAssertEqual(winningHands, hands.winners, hands.desc)
        }
    }
}
