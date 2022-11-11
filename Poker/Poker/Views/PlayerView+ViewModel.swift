//
//  PlayerView+ViewModel.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import SwiftUI

extension PlayerView {
    struct PlayerViewModel {
        let player: Player
        let isFaceUp: Bool
        let winningHands: [BestHand]
        let isGameOver: Bool
        let isPoopMode: Bool

        init(player: Player, isFaceUp: Bool, winningHands: [BestHand], isGameOver: Bool, isPoopMode: Bool) {
            self.player = player
            self.isFaceUp = isFaceUp
            self.winningHands = winningHands
            self.isGameOver = isGameOver
            self.isPoopMode = isPoopMode
        }

        var cards: [Card] { player.cards }

        var playerBetAmount: String { "\(player.bet)€" }
        var playerChipsAmount: String { "\(player.chips)€" }

        var isFolded: Bool { player.isFolded }

        var isShowHand: Bool {
            if isPoopMode { return true }
            if isFaceUp { return true }

            guard !isFolded else { return false }
            guard isGameOver else { return isFaceUp }

            return isWinningHand
        }

        var isWinningHand: Bool {
            guard let playerBestHand = player.bestHand else { return false }
            return winningHands.contains(playerBestHand)
        }

        var bestHandDescription: String {
            guard let bestHand = player.bestHand else { return PlayerViewModel.noDescription }
            return bestHand.description
        }
        static var noDescription: String = "No cards"

        var isShowDescription: Bool {
            isShowHand && player.bestHand != nil
        }

        var isInBestHand: Bool {
            guard !isFolded else { return false }
            guard isGameOver else { return true }

            return isWinningHand
        }

        var isRevealable: Bool { isPoopMode || isGameOver || isFolded }

        func card(at index: Int) -> Card? {
            guard cards.count > index else { return nil }
            return cards[index]
        }

        func isCardInBestHand(at index: Int) -> Bool {
            guard !isFolded else { return false }
            guard isWinningHand else { return false }
            guard let card = card(at: index) else { return false }
            return winningHands.flatMap(\.handWithKicker).contains(card)
        }
    }
}

struct PlayerViewPlayerViewModel_Previews: PreviewProvider {
    static let appState = AppState()

    static let winningCards = [Card(), Card()]
    static let winningHands = [BestHand(cards: [winningCards.sorted().last!])]
    static let winningPlayer = Player(cards: winningCards, bestHand: winningHands.first!)
    static let foldedPlayer = Player(cards: [Card(), Card()], bestHand: winningHands.first!, isFolded: true)

    static let faceDownPlayerVM = PlayerView.PlayerViewModel(player: winningPlayer, isFaceUp: false, winningHands: winningHands, isGameOver: false, isPoopMode: false)
    static let winningPlayerVM = PlayerView.PlayerViewModel(player: winningPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: false, isPoopMode: false)
    static let foldedPlayerVM = PlayerView.PlayerViewModel(player: foldedPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: false, isPoopMode: false)
    static let winningGameOverPlayerVM = PlayerView.PlayerViewModel(player: winningPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: true, isPoopMode: false)
    static let foldedGameOverPlayerVM = PlayerView.PlayerViewModel(player: foldedPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: true, isPoopMode: false)
    static let winningPoopModePlayerVM = PlayerView.PlayerViewModel(player: winningPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: false, isPoopMode: true)
    static let foldedPoopModePlayerVM = PlayerView.PlayerViewModel(player: foldedPlayer, isFaceUp: true, winningHands: winningHands, isGameOver: false, isPoopMode: true)

    static var previews: some View {
        VStack {
            Text("isFaceUp = false")
                .font(.title2)
            HStack {
                PlayerView.PlayerCardView(playerVM: faceDownPlayerVM, index: 0)
                PlayerView.PlayerCardView(playerVM: faceDownPlayerVM, index: 1)
                PlayerView.PlayerCardView(playerVM: faceDownPlayerVM, index: 2)
            }
            Divider()
            VStack(spacing: 10) {
                Text("isGameOver = false")
                    .font(.title2)
                HStack(spacing: 20) {
                    VStack {
                        Text("winningPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: winningPlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: winningPlayerVM, index: 1)
                        }
                    }
                    VStack {
                        Text("foldedPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: foldedPlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: foldedPlayerVM, index: 1)
                        }
                    }
                }
            }
            Divider()
            VStack(spacing: 10) {
                Text("isGameOver = true")
                    .font(.title2)
                HStack(spacing: 20) {
                    VStack {
                        Text("winningPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: winningGameOverPlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: winningGameOverPlayerVM, index: 1)
                        }
                    }
                    VStack {
                        Text("foldedPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: foldedGameOverPlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: foldedGameOverPlayerVM, index: 1)
                        }
                    }
                }
            }
            Divider()
            VStack(spacing: 10) {
                Text("isPoopMode = true")
                    .font(.title2)
                HStack(spacing: 40) {
                    VStack {
                        Text("winningPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: winningPoopModePlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: winningPoopModePlayerVM, index: 1)
                        }
                    }
                    VStack {
                        Text("foldedPlayer")
                            .font(.headline)
                        HStack {
                            PlayerView.PlayerCardView(playerVM: foldedPoopModePlayerVM, index: 0)
                            PlayerView.PlayerCardView(playerVM: foldedPoopModePlayerVM, index: 1)
                        }
                    }
                }
            }
        }
        .environmentObject(appState)
        .previewLayout(PreviewLayout.sizeThatFits)
    }
}
