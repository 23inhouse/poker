//
//  GameView.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var gameVM: GameViewModel = GameViewModel()

    var dealer: Dealer { Dealer(gameVM: gameVM, isPoopMode: appState.isPoopMode) }
    var player: Player { gameVM.player }
    var computerPlayers: [Player] { gameVM.computerPlayers }

    var spacerPadding: CGFloat { 50 }

    var body: some View {
        VStack(spacing: 10) {
            VStack {
                ForEach(Array(computerPlayers.enumerated()), id: \.offset) { _, player in
                    PlayerView(player: player, winningHands: gameVM.winningHands, isFaceUp: false, isHandFinished: gameVM.isHandFinished)
                }
            }
            Spacer()
            VStack {
                potView
                RiverView(cards: gameVM.river, position: gameVM.riverPosition, winningCards: gameVM.winningCards)
            }
            .containerShape(Rectangle())
            .onTapGesture {
                guard gameVM.isHandFinished else { return }
                Task.init { await next() }
            }
            playerBetView
            Spacer()
            PlayerView(player: player, winningHands: gameVM.winningHands, isFaceUp: true, isHandFinished: gameVM.isHandFinished, betGesture: betGesture, checkGesture: checkGesture, foldGesture: foldGesture)
        }
        .task {
            await dealer.start()
        }
        .onChange(of: appState.isPoopMode) { newValue in
            dealer.calcBestHands()
        }
    }
}

private extension GameView {
    var potView: some View {
        Text("Pot: \(gameVM.pot)€")
            .foregroundColor(gameVM.isHandFinished ? .blue : .primary)
            .font(.largeTitle)
    }

    var playerBetView: some View {
        Text(gameVM.playerActionDescription)
            .font(.title)
    }

    func next() async {
        print("\nGameView.next current position:", gameVM.riverPosition)
        await dealer.perform()
    }

    var betGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
        let betDragDistance: Double = 30

        return DragGesture(minimumDistance: betDragDistance)
            .onChanged { gesture in
                guard dealer.isThePlayersTurn else { return }
                guard gesture.translation.height < 0 else { return }

                let dragDelta = gesture.translation.height * -1
                let betStep: Int = Int(Double(dragDelta) / betDragDistance)
                let newAmountToBet = dealer.betAmount(for: betStep)

                guard player.bet != newAmountToBet else { return }
                DispatchQueue.main.async {
                    print("GameView.betGesture.Betting:", newAmountToBet)
                    gameVM.player.bet = newAmountToBet
                }
            }
            .onEnded { gesture in
                guard dealer.isThePlayersTurn else { return }
                guard player.bet > dealer.startingAmount else { return }

                DispatchQueue.main.async {
                    print("\nGameView.betGesture.Ended")
                    Task.init {
                        await dealer.betPlayer(amount: gameVM.player.bet)
                        await dealer.perform()
                    }
                }
            }
    }

    var checkGesture: () -> Void {
        return {
            guard dealer.isThePlayersTurn else { return }

            DispatchQueue.main.async {
                print("\nGameView.checkGesture")
                Task.init {
                    await dealer.checkPlayer()
                    await dealer.bettingRound()
                }
            }
        }
    }

    var foldGesture: _EndedGesture<DragGesture> {
        DragGesture(minimumDistance: 100)
            .onEnded { endedGesture in
                DispatchQueue.main.async {
                    guard dealer.isThePlayersTurn else { return }

                    print("\nGameView.foldGesture")
                    if (endedGesture.location.y - endedGesture.startLocation.y) < 0 {
                        Task.init {
                            await dealer.foldPlayer()
                            await dealer.bettingRound()
                        }
                    }
                }
            }
    }
}

struct GameView_Previews: PreviewProvider {
    static let appState = AppState()

    static var previews: some View {
        GameView()
            .environmentObject(appState)
            .previewDevice(PreviewDevice.init(rawValue: "iPhone SE (3rd generation)"))
    }
}
