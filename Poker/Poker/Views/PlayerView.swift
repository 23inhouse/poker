//
//  PlayerView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct PlayerView: View {
    let game: Game
    let player: Player
    let faceUp: Bool
    let cardWidth: CGFloat

    var body: some View {
        HStack {
            ForEach(Array(player.cards.enumerated()), id: \.offset) { index, card in
                CardView(card: card, faceUp: faceUp)
                    .frame(maxWidth: cardWidth)
            }
            Circle().fill(.secondary)
                .frame(maxWidth: cardWidth * 0.4)
            if player.bestHand == game.bestHand {
                Circle().fill(.green)
                    .frame(maxWidth: cardWidth * 0.4)
            }
            Spacer()
            VStack {
                Text("B: \(player.bet)€")
                    .font(.title)
                Text("C: \(player.chips)€")
                    .font(.title)
                Text("\(player.bestHand(from: game.river)?.description ?? "")")
            }
//            .font(.title)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static let game = Game.new()
    static let player1 = game.players.first!
    static let player2 = game.players.last!

    static var previews: some View {
        VStack {
            PlayerView(game: game, player: player1, faceUp: false, cardWidth: 50)
            PlayerView(game: game, player: player2, faceUp: true, cardWidth: 50)
        }
    }
}
