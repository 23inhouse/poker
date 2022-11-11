//
//  RiverView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

extension RiverView {
    static let numberOfCards: Int = 5
}

struct RiverView: View {
    @EnvironmentObject var appState: AppState

    let cards: [Card]
    let position: RiverPosition
    var winningCards: [Card] = []

    var riverVM: RiverViewModel {
        RiverViewModel(cards: cards, position: position, winningCards: winningCards)
    }

    var body: some View {
        HStack(spacing: 15) {
            ForEach(Array(0..<RiverView.numberOfCards), id: \.self) { index in
                RiverCardView(riverVM: riverVM, index: index)
            }
        }
    }
}

extension RiverView {
    struct RiverCardView: View {
        @EnvironmentObject var appState: AppState

        let riverVM: RiverViewModel
        let index: Int

        var body: some View {
            CardView(card: riverVM.card(at: index), isFaceUp: riverVM.isFaceUp(at: index), isReavelable: riverVM.isReavelable, isInBestHand: riverVM.isInBestHand(at: index))
        }
    }
}

struct RiverView_Previews: PreviewProvider {
    static let appState = AppState()
    static let cards: [Card] = [Card(), Card(), Card(), Card(), Card()]

    static var previews: some View {
        VStack {
            VStack {
                Text("No cards")
                RiverView(cards: [], position: .preflop)
            }
            Divider()
            VStack {
                Text("River cards")
                RiverView(cards: cards, position: .preflop)
                Divider()
                RiverView(cards: cards, position: .flop)
                Divider()
                RiverView(cards: cards, position: .turn)
            }
            Divider()
            RiverView(cards: cards, position: .river)
            Divider()
            VStack {
                Text("Gave over reveal")
                RiverView(cards: cards, position: .over, winningCards: Array(cards.shuffled().prefix(3)))
            }
            Divider()
        }
        .environmentObject(appState)
        .previewDevice(PreviewDevice.init(rawValue: "iPhone SE (3rd generation)"))
    }
}
