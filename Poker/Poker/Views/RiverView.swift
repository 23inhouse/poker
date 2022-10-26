//
//  RiverView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

enum RiverPosition {
    case preflop, flop, turn, river, over
}

struct RiverView: View {
    @EnvironmentObject var game: Game

    static let numberOfCards: Int = 5

    var body: some View {
        HStack(spacing: 15) {
            ForEach(Array(0..<RiverView.numberOfCards), id: \.self) { index in
                RiverCardView(index: index)
            }
        }
    }
}

struct RiverCardView: View {
    @EnvironmentObject var game: Game

    let index: Int

    var position: RiverPosition { game.riverPosition }
    var cards: [Card] { game.river }

    var card: Card? {
        guard cards.count > index else { return nil }
        return cards[index]
    }

    var isInBestHand: Bool {
        guard let card = card else { return false }
        return game.winningCards.contains(card)
    }

    var isFaceUp: Bool {
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

    var body: some View {
        CardView(card: card, isFaceUp: isFaceUp, isInBestHand: isInBestHand)
    }
}

struct RiverView_Previews: PreviewProvider {
    static func game(_ position: RiverPosition) -> Game {
        let game = Game()
        game.deal()
        game.river = [game.dealCard(), game.dealCard(), game.dealCard(), game.dealCard(), game.dealCard()]
        game.riverPosition = position
        return game
    }
    static var previews: some View {
        VStack {
            RiverView()
                .environmentObject(game(.preflop))
            RiverView()
                .environmentObject(game(.flop))
            RiverView()
                .environmentObject(game(.turn))
            RiverView()
                .environmentObject(game(.river))
            RiverView()
                .environmentObject(game(.over))
        }
    }
}
