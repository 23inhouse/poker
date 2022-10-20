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
    @Binding var isFaceUp: Bool
    let cardWidth: CGFloat

    var isInBestHand: Bool {
        player.bestHand == game.bestHand
    }

    var body: some View {
        HStack {
            ForEach(Array(player.cards.enumerated()), id: \.offset) { index, card in
                CardView(card: card, faceUp: $isFaceUp)
                    .frame(maxWidth: cardWidth)
            }
            VStack {
                Circle().fill(.secondary)
                    .frame(maxWidth: cardWidth * 0.4)
                if isInBestHand {
                    Circle().fill(.green)
                        .frame(maxWidth: cardWidth * 0.4)
                }
            }
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .trailing) {
                        Text("BET")
                        Text("\(player.bet)€")
                    }
                    .frame(maxWidth: .infinity)
                    .font(.title3)
                    VStack(alignment: .trailing) {
                        Text("CHIPS")
                        Text("\(player.chips)€")
                    }
                    .frame(maxWidth: .infinity)
                    .font(.title3)

                }
                Text("\(player.bestHand(from: game.river)?.description ?? "")")
                    .opacity(isInBestHand ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .font(.body)
        }
        .frame(maxWidth: .infinity)
        .opacity(isInBestHand ? 1 : 0.25)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static let game = Game.new()
    static let player1 = game.players.first!
    static let player2 = game.players.last!

    static var previews: some View {
        VStack {
            PlayerView(game: game, player: player1, isFaceUp: .constant(false), cardWidth: 50)
            ForEach(game.players, id: \.self) { player in
                PlayerView(game: game, player: player, isFaceUp: .constant(true), cardWidth: 50)
            }
            PlayerView(game: game, player: player2, isFaceUp: .constant(false), cardWidth: 50)
        }
    }
}
