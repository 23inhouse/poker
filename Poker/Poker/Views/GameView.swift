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

    @State var isBet: Bool = false
    @State var isEven: Bool = .random()

    var dealer: Dealer { Dealer(gameVM: gameVM, isPoopMode: appState.isPoopMode) }
    var player: Player { gameVM.player }
    var computerPlayers: [Player] { gameVM.computerPlayers }

    var spacerPadding: CGFloat { 50 }

    var body: some View {
        VStack(spacing: 10) {
            VStack {
                ForEach(Array(computerPlayers.enumerated()), id: \.offset) { _, player in
                    PlayerView(player: player, winningHands: gameVM.winningHands, isFaceUp: false, isGameOver: gameVM.over)
                }
            }
            Spacer()
            VStack {
                potView
                RiverView(cards: gameVM.river, position: gameVM.riverPosition, winningCards: gameVM.winningCards)
            }
            .containerShape(Rectangle())
            .onTapGesture {
                guard gameVM.over else { return }
                Task.init { await next() }
            }
            Spacer()
            playerBetView
            PlayerView(player: player, winningHands: gameVM.winningHands, isFaceUp: true, isGameOver: gameVM.over, betGesture: betGesture, checkGesture: checkGesture, foldGesture: foldGesture)
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
        Text("Pot: \(gameVM.potIncludingCurrentBettingRound)€")
            .foregroundColor(gameVM.over ? .blue : .primary)
            .font(.largeTitle)
    }

    var playerBetView: some View {
        HStack {
            if gameVM.player.isFolded {
                Text("FOLD")
            } else {
                Text("Bet: \(player.bet)€")
            }
        }
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

                    let dragDelta = gesture.translation.height * -1
                    let potAmount: Int = 40
                    let betStep: Int = Int(Double(dragDelta) / betDragDistance)
                    var newAmountToBet = 0
                    switch betStep {
                    case 0: newAmountToBet = 0
                    case 1: newAmountToBet = potAmount / 2
                    case 2: newAmountToBet = potAmount
                    case 3: newAmountToBet = potAmount * 2
                    case 4: newAmountToBet = potAmount * 3
                    case 5: newAmountToBet = potAmount * 4
                    default: newAmountToBet = dealer.allInAmount
                    }

                    guard player.bet != newAmountToBet else { return }
                    DispatchQueue.main.async {
                        print("GameView.betGesture.Betting:", newAmountToBet)
                        gameVM.player.bet = newAmountToBet
                    }
                }
                .onEnded { gesture in
                    guard dealer.isThePlayersTurn else { return }

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
