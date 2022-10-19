//
//  GameView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct GameView: View {
    let game: Game = Game.new()

    var player: Player { game.player }
    var players: [Player] { game.players }
    var river: [Card] { game.river }

    @State var cardWidth: CGFloat = 50

    var pot: Int { players.map(\.bet).reduce(0, +) + player.bet }

    var body: some View {
        VStack {
            ForEach(Array(players), id: \.self) { player in
                PlayerView(game: game, player: player, faceUp: false, cardWidth: cardWidth)
//                    .opacity([1, 0.15].randomElement() ?? 1)
            }
            Text("Pot: \(pot)€")
                .font(.title)
            RiverView(game: game, position: .flop, cardWidth: $cardWidth)
                .padding(.horizontal)
            HStack {
                Text("💩      ")
                    .opacity(0.25)
                Spacer()
                Text("Bet: \(player.bet)€")
                Spacer()
                Text("🌈")
                    .onTapGesture {
                        game.deal()
                    }
            }
            .font(.title)
            PlayerView(game: game, player: player, faceUp: true, cardWidth: cardWidth)
                .padding(.horizontal, 10)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
