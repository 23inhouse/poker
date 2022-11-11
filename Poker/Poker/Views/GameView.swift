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

//    @State var isFolded: Bool = false
    @State var isChecked: Bool = false
    @State var isBet: Bool = false

    var dealer: Dealer { Dealer(gameVM: gameVM, isPoopMode: appState.isPoopMode) }
    var player: Player { gameVM.player }
    var computerPlayers: [Player] { gameVM.computerPlayers }

    var pot: Int { computerPlayers.map(\.bet).reduce(0, +) + player.bet }

    var body: some View {
        VStack(spacing: 10) {
            VStack {
                ForEach(Array(computerPlayers.enumerated()), id: \.offset) { _, player in
                    PlayerView(player: player, isFaceUp: false, winningHands: gameVM.winningHands, isGameOver: gameVM.over)
                }
            }
            HStack {
                controlsView
                Spacer()
                potView
                Spacer()
                controlsView
            }
            .font(.largeTitle)
            .font(.title)
            RiverView(cards: gameVM.river, position: gameVM.riverPosition, winningCards: gameVM.winningCards)
            ThePlayerView(player: player, gameVM: gameVM)
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dealer.start()
            }
        }
        .onChange(of: appState.isPoopMode) { newValue in
            guard newValue else { return }
            dealer.calcBestHands()
        }
    }

    var potView: some View {
        VStack {
            Text("Pot: \(pot)€")
            HStack {
                if gameVM.player.isFolded {
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
    }

    var controlsView: some View {
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
                    appState.isPoopMode.toggle()
                }
        }
    }

    func play() {
        print("GameView.play: ", gameVM.riverPosition)
        dealer.next()
    }
}

extension GameView {
    struct ThePlayerView: View {
        let player: Player
        let gameVM: GameViewModel

        var body: some View {
            PlayerView(player: player, isFaceUp: true, winningHands: gameVM.winningHands, isGameOver: gameVM.over, foldGesture: foldGesture, betGesture: betGesture)
        }

        var foldGesture: _EndedGesture<DragGesture> {
            DragGesture(minimumDistance: 100)
                .onEnded { endedGesture in
                    DispatchQueue.main.async {
                        guard player == gameVM.player else { return }
                        if (endedGesture.location.y - endedGesture.startLocation.y) < 0 {
                            gameVM.player.fold()
                        }
                    }
                }
        }

        var betGesture: _ChangedGesture<DragGesture> {
            let betDragDistance: Double = 30

            return DragGesture(minimumDistance: betDragDistance)
                .onChanged { gesture in
                    print(gesture.translation.height * -1)
                    let dragDelta = gesture.translation.height * -1
                    let potAmount: Int = 40
                    let betStep: Int = Int(Double(dragDelta) / betDragDistance)
                    var amountToBet = 0
                    switch betStep {
                    case 0: amountToBet = 0
                    case 1: amountToBet = potAmount / 2
                    case 2: amountToBet = potAmount
                    case 3: amountToBet = potAmount * 2
                    case 4: amountToBet = potAmount * 3
                    case 5: amountToBet = potAmount * 4
                    default: amountToBet = 1000
                    }
                    DispatchQueue.main.async {
                        gameVM.player.setAmountToBet(amountToBet)
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
