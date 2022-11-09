//
//  RiverView+ViewModel.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import Foundation

extension RiverView {
    struct RiverViewModel {
        let cards: [Card]
        let position: RiverPosition
        let winningCards: [Card]

        init(cards: [Card], position: RiverPosition, winningCards: [Card]) {
            self.cards = cards
            self.position = position
            self.winningCards = winningCards
        }

        func card(at index: Int) -> Card? {
            guard cards.count > index else { return nil }
            return cards[index]
        }

        func isInBestHand(at index: Int) -> Bool {
            guard let card = card(at: index) else { return false }
            return winningCards.contains(card)
        }

        func isFaceUp(at index: Int) -> Bool {
            switch position {
            case .preflop:
                return false
            case .flop:
                return index < 3
            case .turn:
                return index < 4
            case .river:
                return true
            case .over:
                return true
            }
        }

        var isReavelable: Bool { position == .over }
    }
}
