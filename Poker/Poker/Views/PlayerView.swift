//
//  PlayerView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

extension PlayerView {
    static let numberOfCards: Int = 2
}

struct PlayerView: View {
    @EnvironmentObject var appState: AppState

    let player: Player
    let isFaceUp: Bool
    var winningHands: [BestHand]
    var isGameOver: Bool
    var foldGesture: _EndedGesture<DragGesture> = DragGesture().onEnded({ _ in })
    var betGesture: _ChangedGesture<DragGesture> = DragGesture().onChanged({ _ in })

    var playerVM: PlayerViewModel {
        PlayerViewModel(player: player, isFaceUp: isFaceUp, winningHands: winningHands, isGameOver: isGameOver, isPoopMode: appState.isPoopMode)
    }

    var body: some View {
        HStack {
            ForEach(Array(0..<PlayerView.numberOfCards), id: \.self) { index in
                PlayerCardView(playerVM: playerVM, index: index)
                    .gesture(foldGesture)
            }
            PlayerDetailView(playerVM: playerVM)
                .containerShape(Rectangle())
                .gesture(betGesture)
        }
        .frame(maxWidth: .infinity)
        .frame(height: CardView.width * 1.8)
    }
}

extension PlayerView {
    struct PlayerCardView: View {
        @EnvironmentObject var appState: AppState

        let playerVM: PlayerViewModel
        let index: Int

        var card: Card? { playerVM.card(at: index) }
        var isFaceUp: Bool { playerVM.isShowHand }
        var isReavelable: Bool { playerVM.isRevealable }
        var isInBestHand: Bool { playerVM.isCardInBestHand(at: index) }

        var body: some View {
            CardView(card: card, isFaceUp: isFaceUp, isReavelable: isReavelable, isInBestHand: isInBestHand )
        }
    }

    struct PlayerDetailView: View {
        let playerVM: PlayerViewModel

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        Circle().fill(.secondary)
                            .frame(maxWidth: CardView.width * 0.4)
                    }
                    .frame(maxWidth: 50)
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .trailing) {
                                Text("BET")
                                Text(playerVM.playerBetAmount)
                            }
                            .frame(maxWidth: .infinity)
                            .font(.title3)
                            VStack(alignment: .trailing) {
                                Text("CHIPS")
                                Text(playerVM.playerChipsAmount)
                            }
                            .frame(maxWidth: .infinity)
                            .font(.title3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .font(.body)
                }
                Text("\(playerVM.bestHandDescription)")
                    .opacity(playerVM.isShowDescription ? 1 : 0)
                    .animation(!playerVM.isShowDescription ? .none : .linear(duration: 0.125), value: playerVM.isShowHand)
                Spacer()
            }
            .opacity(playerVM.isInBestHand ? 1 : 0.25)

        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static let appState = AppState()

    static let players: [Player] = [
        Player(cards: [Card(), Card()], isFolded: true),
        Player(cards: [Card(), Card()], isFolded: false)
    ]
    static let winningCards = [Card(), Card()]
    static let winningPlayer = Player(cards: winningCards, bestHand: BestHand(cards: [winningCards.sorted().last!]))
    static let foldedPlayer = Player(cards: winningCards, bestHand: BestHand(cards: []), isFolded: true)
    static let playerVM = PlayerView.PlayerViewModel(player: players.last!, isFaceUp: true, winningHands: [], isGameOver: false, isPoopMode: false)

    static var previews: some View {
        VStack {
            HStack {
                PlayerView.PlayerCardView(playerVM: playerVM, index: 0)
                PlayerView.PlayerCardView(playerVM: playerVM, index: 1)
                PlayerView.PlayerCardView(playerVM: playerVM, index: 2)
            }
            Divider()
            PlayerView(player: players.first!, isFaceUp: false, winningHands: [], isGameOver: false)
            PlayerView(player: players.last!, isFaceUp: true, winningHands: [], isGameOver: false)
            Divider()
            VStack {
                Text("Winning player")
                PlayerView(player: winningPlayer, isFaceUp: true, winningHands: [winningPlayer.bestHand!], isGameOver: true)
            }
            Divider()
            VStack {
                Text("Folded player")
                PlayerView(player: foldedPlayer, isFaceUp: true, winningHands: [winningPlayer.bestHand!], isGameOver: true)
                Divider()
                PlayerView(player: foldedPlayer, isFaceUp: false, winningHands: [winningPlayer.bestHand!], isGameOver: true)
            }
        }
        .environmentObject(appState)
    }
}
