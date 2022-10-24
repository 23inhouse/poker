//
//  GameView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var game: Game
    @State var isFaceUp: Bool = false

    @State var isFolded: Bool = false
    @State var isChecked: Bool = false
    @State var isBet: Bool = false

    var player: Player { game.player }
    var players: [Player] { game.players }
    var river: [Card] { game.river }

    var pot: Int { players.map(\.bet).reduce(0, +) + player.bet }

    var body: some View {
        VStack(spacing: 10) {
            VStack {
                ForEach(Array(players.enumerated()), id: \.offset) { _, player in
                    PlayerView(player: player, isFaceUp: isFaceUp)
                }
            }
            Spacer()
            HStack {
                VStack {
                    Text("🌈")
                        .font(.largeTitle)
                        .padding(10)
                        .containerShape(Rectangle())
                        .onTapGesture {
                            play()
                        }
                    Spacer()
                    Text("💩")
                        .padding(10)
                        .containerShape(Rectangle())
                        .font(.largeTitle)
                        .onTapGesture {
                            isFaceUp.toggle()
                        }
                }
                Spacer()
                VStack {
                    Text("Pot: \(pot)€")
                        .onTapGesture {
                            if game.player.cards.isEmpty {
                                game.deal()
                            } else {
                                game.new()
                            }
                        }
                    HStack {
                        if isFolded {
                            Text("FOLD")
                        } else {
                            if isChecked {
                                Text("CHECK")
                            }
                            Text("Bet: \(player.bet)€")
                            if isBet {
                                Text("Raise: \(player.bet)€")
                            }
                        }
                    }
                    .font(.title)
                }
                Spacer()
                VStack {
                    Text("🌈")
                        .font(.largeTitle)
                        .padding(10)
                        .containerShape(Rectangle())
                        .onTapGesture {
                            play()
                        }
                    Spacer()
                    Text("💩")
                        .padding(10)
                        .containerShape(Rectangle())
                        .font(.largeTitle)
                        .onTapGesture {
                            isFaceUp.toggle()
                        }
                }
            }
            .font(.largeTitle)
            .font(.title)
            RiverView()
                .padding(.horizontal)
            PlayerView(player: player, isFaceUp: true)
                .padding(.horizontal, 10)
//                .border(.blue)
            Spacer()
        }
        .onChange(of: game.player.isFolded) { newValue in
            isFolded = newValue
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                game.start()
            }
        }
    }

    func play() {
        print("GameView.play: ", game.riverPosition)
        game.next()
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(Game())
    }
}
