//
//  CardView+ViewModel.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import SwiftUI

extension CardView {
    struct CardViewModel {
        let card: Card?
        let isRevealable: Bool
        let isInBestHand: Bool
        let isPoopMode: Bool

        init(card: Card?, isRevealable: Bool, isInBestHand: Bool, isPoopMode: Bool) {
            self.card = card
            self.isRevealable = isRevealable
            self.isInBestHand = isInBestHand
            self.isPoopMode = isPoopMode
        }

        var rankDescription: String { card?.rank.rawValue ?? "" }
        var suitImageSystemName: String { "suit.\(card?.suit.description ?? "").fill"}

        var suit: Suit? { card?.suit }

        var color: Color {
            guard let suit = suit else { return .secondary }
            return [.clubs, .spades].contains(suit) ? .black : .red
        }

        var opacity: CGFloat {
            guard isRevealable || isPoopMode else { return 1 }
            return isInBestHand ? 1 : 0.25
        }

        var offset: CGFloat {
            guard isRevealable || isPoopMode else { return 0 }
            return isInBestHand ? -5 : 5
        }
    }
}
