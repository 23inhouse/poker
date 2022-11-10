//
//  DealerTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 10/11/2022.
//

import XCTest
@testable import Poker

@MainActor
final class DealerTests: XCTestCase {
    func testCalcBestHand() {
        let gameVM = GameView.GameViewModel()
        let dealer = Dealer(gameVM: gameVM, isPoopMode: true)
        dealer.new()

        let bestHands: [(h1: BestHand, h2: BestHand, river: Hand?, winners: [BestHand], kicker: Card?, label: String, desc: String)] = [
            (BestHand.from("A♡")!, BestHand.from("K♤")!, nil, [BestHand.from("A♡")!], nil, "A high", "High card beats lower"),
            (BestHand.from("A♡ K♡")!, BestHand.from("A♡ Q♤")!, nil, [BestHand.from("A♡ K♡")!], Card.from("K♡")!, "A high [K kicker]", "High card with kicker beats lower"),
            (BestHand.from("A♡ 4♡")!, BestHand.from("A♡ 5♤")!, Hand.from("K♡ 8♢ 6♢")!, [BestHand.from("A♡ K♡ 8♢ 6♢ 5♤")!], Card.from("5♤")!, "A high [5 kicker]", "High card with kicker beats lower"),
            (BestHand.from("9♡ 7♡")!, BestHand.from("7♢ 9♧")!, Hand.from("J♧ 9♢ 8♢")!, [BestHand.from("9♡ 7♡ J♧ 9♢ 8♢")!, BestHand.from("7♢ 9♧ J♧ 9♢ 8♢")!], nil, "Pair of 9s", "Pair with equal kickers"),
        ]


        for hands in bestHands {
            let playerOne = Player(cards: hands.h1.cards)
            let playerTwo = Player(cards: hands.h2.cards)

            gameVM.players = [playerOne, playerTwo]
            gameVM.river = hands.river?.cards ?? []

            dealer.calcBestHands()

            XCTAssertEqual(gameVM.winningHands, hands.winners)
            XCTAssertEqual(gameVM.winningHands.first!.tieBreakingKickerCard, hands.kicker)
        }
    }
}
