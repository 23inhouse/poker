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
    let game: Game
    var cards: [Card] { game.river }
    var position: RiverPosition = .preflop

    @Binding var cardWidth: CGFloat

    var body: some View {
        HStack(spacing: 15) {
            ForEach(Array(cards.enumerated()), id: \.offset) { i, card in
                CardView(card: card, faceUp: faceUp(position, index: i))
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    cardWidth = geo.size.width
                                }
                        }
                    }
                    .offset(y: (game.bestHand?.hand.cards ?? []).contains(card) ? -5 : 5)
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
            RiverView(game: Game.new(), position: .preflop, cardWidth: .constant(100))
            RiverView(game: Game.new(), position: .flop, cardWidth: .constant(100))
            RiverView(game: Game.new(), position: .turn, cardWidth: .constant(100))
            RiverView(game: Game.new(), position: .river, cardWidth: .constant(100))
        }
    }
}
