//
//  PlayerView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct PlayerView: View {
    let player: Player
    let faceUp: Bool
    let cardWidth: CGFloat

    var body: some View {
        HStack {
            ForEach(Array(player.cards), id: \.self) { card in
                CardView(card: card, faceUp: faceUp)
                    .frame(maxWidth: cardWidth)
            }
            Circle().fill(.secondary)
                .frame(maxWidth: cardWidth * 0.4)
            Spacer()
            VStack {
                Text("B: \(player.bet)€")
                Text("C: \(player.chips)€")
            }
            .font(.title)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PlayerView(player: Player(cards: [Card(), Card()]), faceUp: false, cardWidth: 50)
            PlayerView(player: Player(cards: [Card(), Card()]), faceUp: true, cardWidth: 50)
        }
    }
}
