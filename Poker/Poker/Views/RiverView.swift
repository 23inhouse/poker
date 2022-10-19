//
//  RiverView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

enum RiverPosition {
    case preflop, flop, turn, river
}

struct RiverView: View {
    let cards: [Card]
    var position: RiverPosition = .preflop

    @Binding var cardWidth: CGFloat

    var body: some View {
        HStack(spacing: 15) {
            ForEach(Array(cards.enumerated()), id: \.element) { i, card in
                CardView(card: card, faceUp: faceUp(position, index: i))
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    cardWidth = geo.size.width
                                }
                        }
                    }
            }
        }
    }

    func faceUp(_ position: RiverPosition, index: Int) -> Bool {
        switch position {
        case .preflop:
            return false
        case .flop:
            return index < 3
        case .turn:
            return index < 4
        case .river:
            return true
        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RiverView(cards: [Card(), Card(), Card(), Card(), Card()], position: .preflop, cardWidth: .constant(100))
            RiverView(cards: [Card(), Card(), Card(), Card(), Card()], position: .flop, cardWidth: .constant(100))
            RiverView(cards: [Card(), Card(), Card(), Card(), Card()], position: .turn, cardWidth: .constant(100))
            RiverView(cards: [Card(), Card(), Card(), Card(), Card()], position: .river, cardWidth: .constant(100))
        }
    }
}
