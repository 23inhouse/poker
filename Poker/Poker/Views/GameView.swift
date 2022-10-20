//
//  GameView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct GameView: View {
    var player: Player { game.player }
    var players: [Player] { game.players }
    var river: [Card] { game.river }

    @State var game: Game = Game.new()
    @State var cardWidth: CGFloat = 50
    @State var isFaceUp: Bool = false

    var pot: Int { players.map(\.bet).reduce(0, +) + player.bet }

    var body: some View {
        VStack {
            ForEach(Array(players), id: \.self) { player in
                PlayerView(game: game, player: player, isFaceUp: $isFaceUp, cardWidth: cardWidth)
            }
            HStack {
                Text("💩")
                    .font(.largeTitle)
                    .onTapGesture {
                        isFaceUp.toggle()
                    }
                Spacer()
                Text("Pot: \(pot)€")
                Spacer()
                Text("🌈")
                    .font(.largeTitle)
                    .onTapGesture {
                        game = Game.new()
                    }
            }
            .font(.largeTitle)
            .font(.title)
            RiverView(game: game, position: .river, cardWidth: $cardWidth)
                .padding(.horizontal)
            HStack {
                Text("FOLD")
                Text("CHECK")
                Text("Bet: \(player.bet)€")
            }
            .font(.title)
            PlayerView(game: game, player: player, isFaceUp: .constant(true), cardWidth: cardWidth)
                .padding(.horizontal, 10)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
