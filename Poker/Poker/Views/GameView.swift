//
//  GameView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct GameView: View {
    let player: Player = Player(cards: [Card(), Card()], bet: Int.random(in: 0..<500))

    let players: [Player] = [
        Player(cards: [Card(), Card()], bet: Int.random(in: 0..<500)),
        Player(cards: [Card(), Card()], bet: Int.random(in: 0..<500)),
        Player(cards: [Card(), Card()], bet: Int.random(in: 0..<500)),
        Player(cards: [Card(), Card()], bet: Int.random(in: 0..<500))
    ]

    let cards: [Card] = [Card(), Card(), Card(), Card(), Card()]

    @State var cardWidth: CGFloat = 50

    var pot: Int { players.map(\.bet).reduce(0, +) + player.bet }

    var body: some View {
        VStack {
            ForEach(Array(players), id: \.self) { player in
                PlayerView(player: player, faceUp: false, cardWidth: cardWidth)
                    .opacity([1, 0.15].randomElement() ?? 1)
            }
            Text("Pot: \(pot)€")
                .font(.title)
            RiverView(cards: cards, position: .flop, cardWidth: $cardWidth)
                .padding(.horizontal)
            HStack {
                Text("💩")
                    .opacity(0.25)
                Spacer()
                Text("Bet: \(player.bet)€")
                Spacer()
                Text("🌈")
                    .opacity(0.25)
            }
            .font(.title)
            PlayerView(player: player, faceUp: true, cardWidth: cardWidth)
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
