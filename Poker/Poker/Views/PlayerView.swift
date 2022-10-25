//
//  PlayerView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var game: Game
    @State var isFolded: Bool = false

    let player: Player
    let isFaceUp: Bool

    static let cardWidth: CGFloat = UIScreen.main.bounds.size.width * 0.122
    static let numberOfCards: Int = 2

    var cards: [Card] {
        player.cards
    }

    var bestHandDescription: String {
        player.bestHand(from: game.river)?.label ?? "Player's hand"
    }

    var isInBestHand: Bool {
        guard !player.isFolded else { return false }
        guard game.over else { return true }
        return player.bestHand == game.bestHand
    }

    var isShowHand: Bool {
        if isFaceUp { return true }

        guard !isFolded else { return false }
        guard game.over else { return isFaceUp }

        return player.bestHand == game.bestHand
    }

    var body: some View {
        HStack {
            ForEach(Array(0..<PlayerView.numberOfCards), id: \.self) { index in
                let card: Card? = cards.count > index ? cards[index] : nil
                PlayerCardView(player: player, card: card, isFaceUp: isShowHand)
            }
            .gesture(
                DragGesture(minimumDistance: 100)
                     .onEnded { endedGesture in
                         guard player == game.player else { return }
                         if (endedGesture.location.y - endedGesture.startLocation.y) < 0 {
                             game.player.fold()
                             isFolded = true
                         }
                     }
            )
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        Circle().fill(.secondary)
                            .frame(maxWidth: PlayerView.cardWidth * 0.4)
                    }
                    .frame(maxWidth: 50)
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
                    }
                    .frame(maxWidth: .infinity)
                    .font(.body)
                }
                Text("\(bestHandDescription)")
                    .opacity(isShowHand ? 1 : 0)
                    .animation(bestHandDescription == "Player's hand" ? .none : .linear(duration: 0.125), value: isShowHand)
                Spacer()

            }
            .opacity(isInBestHand ? 1 : 0.25)
        }
        .frame(maxWidth: .infinity)
        .frame(height: PlayerView.cardWidth * 1.8)
        .onChange(of: player) { newValue in
            isFolded = false
        }
    }
}

struct PlayerCardView: View {
    @EnvironmentObject var game: Game

    let player: Player
    let card: Card?
    let isFaceUp: Bool

    var isCardInBestHand: Bool {
        guard player.bestHand == game.bestHand else { return false }
        guard let card = card else { return false }
        let cards = player.bestHand(from: game.river)?.cards ?? []
        return cards.contains(card)
    }

    var body: some View {
        CardView(card: card, isFaceUp: isFaceUp, isInBestHand: isCardInBestHand)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static let game = {
        let game = Game()
        game.deal()
        game.riverPosition = .preflop
        return game
    }()
    static let player1 = game.players.first!
    static let player2 = game.players.last!

    static var previews: some View {
        VStack {
            HStack {
                PlayerCardView(player: player1, card: nil, isFaceUp: false)
                PlayerCardView(player: player1, card: Card(), isFaceUp: true)
            }
            Divider()
            PlayerView(player: player1, isFaceUp: false)
            ForEach(game.players, id: \.self) { player in
                PlayerView(player: player, isFaceUp: true)
            }
            PlayerView(player: player2, isFaceUp: false)
        }
        .environmentObject(Game())
    }
}
