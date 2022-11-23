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
    let winningHands: [BestHand]
    var isFaceUp: Bool = false
    var isHandFinished: Bool = false
    var betGesture: _EndedGesture<_ChangedGesture<DragGesture>> = DragGesture().onChanged({ _ in }).onEnded({ _ in })
    var checkGesture: () -> Void = {}
    var foldGesture: _EndedGesture<DragGesture> = DragGesture().onEnded({ _ in })

    var playerVM: PlayerViewModel {
        PlayerViewModel(player: player, winningHands: winningHands, isFaceUp: isFaceUp, isHandFinished: isHandFinished, isPoopMode: appState.isPoopMode)
    }

    var body: some View {
        HStack {
            ForEach(Array(0..<PlayerView.numberOfCards), id: \.self) { index in
                PlayerCardView(playerVM: playerVM, index: index)
                    .containerShape(Rectangle())
                    .gesture(foldGesture)
            }
            PlayerDetailView(playerVM: playerVM)
                .containerShape(Rectangle())
                .gesture(betGesture)
                .onTapGesture(count: 1, perform: checkGesture)
        }
        .frame(maxWidth: .infinity)
        .frame(height: CardView.width * 1.8)
    }
}

extension PlayerView {
    struct PlayerCardView: View {
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
        @EnvironmentObject var appState: AppState

        let playerVM: PlayerViewModel

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    VStack {
                        if playerVM.isOnTheButton {
                            Text("💩")
                                .frame(width: 44, height: 44)
                                .containerShape(Rectangle())
                                .onTapGesture {
                                    appState.isPoopMode.toggle()
                                }

                        }
                        if playerVM.isBigBlind {
                            Text("BB")
                                .foregroundColor(playerVM.color ?? .secondary)
                        } else if playerVM.isSmallBlind {
                            Text("SB")
                                .foregroundColor(playerVM.color ?? .secondary)
                        }
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
                            .foregroundColor(playerVM.color ?? .primary)
                            VStack(alignment: .trailing) {
                                Text("CHIPS")
                                Text(playerVM.playerChipsAmount)
                            }
                            .frame(maxWidth: .infinity)
                            .font(.title3)
                            .foregroundColor(playerVM.color ?? .primary)
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
            .contentShape(Rectangle())
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static let appState = AppState()

    static let winningCards = [Card(), Card()]
    static let winningBestHand = BestHand(cards: [winningCards.sorted().last!])
    static let losingBestHand = BestHand(cards: [])

    static let isThePlayerOptions: [Bool] = [true, false]
    static let isCurrentPlayerOptions: [Bool] = [true, false]
    static let isFoldedOptions: [Bool] = [false, true]
    static let isGameOverOptions: [Bool] = [true, false]
    static let isFaceUpOptions: [Bool] = [true, false]
    static var previews: some View {
        VStack {
            Text("Game in play").font(.title)
            ForEach(isCurrentPlayerOptions, id: \.self) { isCurrentPlayer in
                Text("isTheCurrentPlayer: \(String(describing: isCurrentPlayer))").font(.headline)
                ForEach(isFaceUpOptions, id: \.self) { isFaceUp in
                    let winningPlayer = Player(cards: winningCards, bestHand: winningBestHand, isFolded: false, isSmallBlind: true, isCurrentPlayer: isCurrentPlayer, isThePlayer: true)
                    PlayerView(player: winningPlayer, winningHands: [winningPlayer.bestHand!], isFaceUp: isFaceUp, isHandFinished: false)
                    Divider()
                }
            }
            ForEach(isFoldedOptions, id: \.self) { isFolded in
                Text("isFolded: \(String(describing: isFolded))").font(.headline)
                ForEach(isFaceUpOptions, id: \.self) { isFaceUp in
                    let winningPlayer = Player(cards: winningCards, bestHand: winningBestHand, isFolded: isFolded, isSmallBlind: true, isCurrentPlayer: false, isThePlayer: true)
                    PlayerView(player: winningPlayer, winningHands: [winningPlayer.bestHand!], isFaceUp: isFaceUp, isHandFinished: false)
                    Divider()

                }
            }
            Text("Game Over").font(.title)
            ForEach(isThePlayerOptions, id: \.self) { isThePlayer in
                Text("isThePlayer: \(String(describing: isThePlayer))").font(.title2)
                VStack {
                    let winningPlayer = Player(cards: winningCards, bestHand: winningBestHand, isFolded: false, isSmallBlind: true, isCurrentPlayer: false, isThePlayer: isThePlayer)
                    let losingPlayer = Player(cards: winningCards, bestHand: losingBestHand, isFolded: false, isSmallBlind: true, isCurrentPlayer: false, isThePlayer: isThePlayer)
                    Text("Winner")
                    PlayerView(player: winningPlayer, winningHands: [winningPlayer.bestHand!], isFaceUp: true, isHandFinished: true)
                    Divider()
                    Text("Loser")
                    PlayerView(player: losingPlayer, winningHands: [winningPlayer.bestHand!], isFaceUp: true, isHandFinished: true)
                    Divider()
                    Text("Face Down")
                    PlayerView(player: losingPlayer, winningHands: [winningPlayer.bestHand!], isFaceUp: false, isHandFinished: true)
                }
                Divider()
            }
        }
        .previewLayout(PreviewLayout.sizeThatFits)
        .previewDevice(PreviewDevice.init(rawValue: "iPhone SE (3rd generation)"))
        .environmentObject(appState)
    }
}

struct PlayerCardView_Previews: PreviewProvider {
    static let appState = AppState()

    static let player: Player = Player(cards: [Card(), Card()], isFolded: false, isOnTheButton: true)
    static let playerVM = PlayerView.PlayerViewModel(player: player, winningHands: [], isFaceUp: true)

    static var previews: some View {
        HStack {
            PlayerView.PlayerCardView(playerVM: playerVM, index: 0)
            PlayerView.PlayerCardView(playerVM: playerVM, index: 1)
            PlayerView.PlayerCardView(playerVM: playerVM, index: 2)
        }
        .environmentObject(appState)
        .previewDevice(PreviewDevice.init(rawValue: "iPhone SE (3rd generation)"))
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
