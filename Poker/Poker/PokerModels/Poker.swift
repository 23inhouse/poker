//
//  Poker.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

struct Poker {
    static func calcBestHands(from players: [Player], river: [Card] = []) -> [BestHand] {
        let lowestBestHand = BestHand(cards: [Card(rank: .two, suit: .diamonds)])
        return players.map { player in player.bestHand(from: river) ?? lowestBestHand }
    }

    static func calcWinningHands(from bestHands: [BestHand]) -> [BestHand] {
        let sortedBestHands = bestHands.sorted().reversed()
        let bestHand = sortedBestHands.first!
        return sortedBestHands.prefix { hand in hand == bestHand }
    }

    static func calcBestHandWithKicker(from bestHands: [BestHand], winningHands: [BestHand]) -> [BestHand] {
        guard !winningHands.isEmpty else { return bestHands }
        let sortedBestHands = bestHands.sorted().reversed()
        guard let bestHand = sortedBestHands.first else { return bestHands }

        let kickerlessBestHand = BestHand(hand: bestHand.hand!)
        let kickerlessBestHands = sortedBestHands
            .map { BestHand(hand: $0.hand!) }
            .prefix { hand in hand == kickerlessBestHand }

        guard kickerlessBestHands.count != 1 else { return bestHands }

        let kickerCards = bestHand.kickerCards()
        let otherHands = bestHands.filter { hand in !winningHands.contains(hand) }
        let otherKickers = otherHands.flatMap { $0.kickerCards() }
        guard !otherKickers.isEmpty else { return bestHands }

        let firstKickerCard = kickerCards.first { card in !otherKickers.contains(card) }
        guard let firstKickerCard = firstKickerCard else { return bestHands }

        return bestHands.map { bestHand in
            guard winningHands.contains(bestHand) else { return bestHand }

            var bestHand = bestHand
            bestHand.tieBreakingKickerCard = firstKickerCard
            return bestHand
        }
    }
}
