//
//  Dealer.swift
//  Poker
//
//  Created by Benjamin Lewis on 8/11/2022.
//

import Foundation

// MARK: static
extension Dealer {
    static var smallBlindBet: Int = 5
    static var bigBlindBet: Int = 10
    static var startingChips: Int = 500

    static var startingButtonIndex: Int = 3

    static let cardTurnDelay: Double = 0.125
    static let nextPlayerDelay: Double = 0.15
    static let nextCommunityCardDelay: Double = 0.5
    static let playerIsFoldedSleepDelay: Double = 0.1
}

@MainActor
struct Dealer {
    var gameVM: GameView.GameViewModel
    var isPoopMode: Bool = false

    var isThePlayersTurn: Bool { gameVM.isCurrentPlayer(at: thePlayerIndex) }

    private var calculator: Dealer.Calculator { Calculator(gameVM: gameVM) }

    var allInAmount: Int { calculator.allInAmount }
    var startingAmount: Int { calculator.startingAmount }
    var minimumBet: Int { calculator.minimumBet }
    var isGameOver: Bool { players.filter(\.isCanBet).count < 2 }

    func start() async {
        print("Dealer.start")

        gameVM.buttonIndex = Dealer.startingButtonIndex

        gameVM.players = [
            Player(chips: Dealer.startingChips),
            Player(chips: Dealer.startingChips),
            Player(chips: Dealer.startingChips),
            Player(chips: Dealer.startingChips),
            Player(chips: Dealer.startingChips, isThePlayer: true),
        ]

        await newHand()
    }

    func perform() async {
        print("")
        print("Dealer.perform [", riverPosition, "]")

        guard !(gameVM.isHandFinished || isBettingRoundComplete) else {
            await performRiverPositionAction()
            return
        }

        await bettingRound(new: true)
    }

    func bettingRound(new newRound: Bool = false) async {
        guard let currentPlayerIndex = currentPlayerIndex else {
            print("Dealer.bettingRound BETTING ROUND IS COMPLETE")
            await perform()
            return
        }

        if newRound {
            gameVM.setAllInAmount()
        }

        print("")
        print("Dealer.bettingRound \(newRound ? "STARTED" : "CONTINUED") [", currentPlayerIndex, "]")

        guard !(isThePlayersTurn && !gameVM.player.isFolded) else { return }

        await checkPlayer()

        await bettingRound()
    }

    func nextAvailableIndex(after index: Int, _ condition: KeyPath<Player, Bool>? = nil) -> Int {
        let max = GameView.GameViewModel.numberOfPlayers
        var newIndex = Utility.indexSafeAddition(from: index, max: max, delta: 1)
        guard let condition = condition else { return newIndex }

        while !players[newIndex][keyPath: condition] {
            guard newIndex != index else {
                assertionFailure("Error: Couldn't find available index")
                return -1
            }
            newIndex = Utility.indexSafeAddition(from: newIndex, max: max, delta: 1)
        }

        return newIndex
    }

    func calcBestHands() {
        print("Dealer.calcBestHands")
        let playerBestHands = Poker.calcBestHands(from: players, river: gameVM.river)

        for (index, playerBestHand) in playerBestHands.enumerated() {
//            print("index:", index, "bestHand:", playerBestHand, playerBestHand.hand!, playerBestHand.cards)
            guard players[index].isInHand else { continue }
            gameVM.players[index].bestHand = playerBestHand
        }

        guard riverPosition == .handFinished || isPoopMode else { return }
        print("Dealer.calcBestHands ALL HANDS")

        gameVM.winningHands = Poker.calcWinningHands(from: playerBestHands)
        let bestKickerHands = Poker.calcBestHandWithKicker(from: playerBestHands, winningHands: gameVM.winningHands)
        guard !bestKickerHands.isEmpty else { return }

        for (index, bestHand) in bestKickerHands.enumerated() {
            gameVM.players[index].bestHand = bestHand

            for (index, winningHand) in gameVM.winningHands.enumerated() {
                if winningHand == bestHand {
                    gameVM.winningHands[index].tieBreakingKickerCard = bestHand.tieBreakingKickerCard
                }
            }
        }
    }

    func betPlayer(amount: Int) async {
        guard let index = currentPlayerIndex else { return }
        gameVM.players[index].bet = amount
        print("Dealer player:", index, "bet amount:", amount)

        await moveToNextPlayer()
    }

    func checkPlayer() async {
        guard let index = currentPlayerIndex else { return }
        let largestBet = calculator.largestBet
        gameVM.players[index].bet = largestBet
        print("Dealer player:", index, "checks amount:", largestBet)

        await moveToNextPlayer()
    }

    func foldPlayer() async {
        guard let index = currentPlayerIndex else { return }
        gameVM.players[index].isFolded = true
        print("Dealer player:", index, "folds")

        await moveToNextPlayer()
    }

    func betAmount(for betStep: Int) -> Int {
        calculator.betAmount(for: betStep)
    }
}

// MARK: private

private extension Dealer {
    var players: [Player] { gameVM.players }
    var riverPosition: RiverPosition { gameVM.riverPosition }
    var currentPlayerIndex: Int? { gameVM.currentPlayerIndex }
    var thePlayerIndex: Int { gameVM.players.count - 1 }
    var isBettingRoundComplete: Bool {
        let largestBet = calculator.largestBet
        let smallestBet = calculator.smallestBet
        let allBetSame: Bool = smallestBet == largestBet
        if smallestBet > 0 && allBetSame { return true }

        if let currentPlayerIndex = currentPlayerIndex {
            let buttonIndex = prevAvailableIndex(before: gameVM.buttonIndex + 1, \.isInHand)
            return currentPlayerIndex == buttonIndex && allBetSame
        } else {
            return currentPlayerIndex == nil && allBetSame
        }
    }

    func newHand() async {
        print("Dealer.newHand")
        await dealNewHand()
        await moveCurrentPlayerToSmallBlind()
        await perform()
    }

    func performRiverPositionAction() async {
        print("Dealer.performNextRiverPositionAction [", riverPosition, "]")

        switch riverPosition {
        case .preflop:
            setPosition(.flop)
            await finishRoundAndPerformNext()
        case .flop:
            setPosition(.turn)
            await finishRoundAndPerformNext()
        case .turn:
            setPosition(.river)
            await finishRoundAndPerformNext()
        case .river:
            // NOTE: No delay on the river because there's no card to turn over
            setPosition(.handFinished)
            await collectBetChips()
            gameVM.currentPlayerIndex = nil
            updateCurrentPlayerStatus()
            calcBestHands()
        case .handFinished:
            print("Dealer hand finished")
            payWinners()
            guard !isGameOver else {
                gameVM.isGameOver = true
                return
            }
            collectCards()
            moveButton()
            await newHand()
        }
    }

    func finishRoundAndPerformNext() async {
        await sleep(Dealer.nextPlayerDelay)
        await collectBetChips()
        dealCommunityCards()
        calcBestHands()
        await sleep(Dealer.nextCommunityCardDelay)
        await moveCurrentPlayerToSmallBlind()
        await perform()
    }

    func dealNewHand() async {
        shuffle()
        setPosition(.preflop)
        await dealPlayers()
    }
}

// MARK: Board

private extension Dealer {
    var playersTurn: Bool { !players.filter(\.isInHand).isEmpty }

    func setPosition(_ position: RiverPosition) {
        gameVM.riverPosition = position
    }

    func moveButton() {
        gameVM.buttonIndex = nextAvailableIndex(after: gameVM.buttonIndex, \.isCanBet)
        gameVM.currentPlayerIndex = nil
        forEachPlayer { i in
            gameVM.players[i].isOnTheButton = gameVM.isOnTheButton(at: i)
            gameVM.players[i].isBigBlind = gameVM.isBigBlind(at: i)
            gameVM.players[i].isSmallBlind = gameVM.isSmallBlind(at: i)
            gameVM.players[i].isCurrentPlayer = false
        }
    }

    func moveToNextPlayer() async {
//        print("Dealer.moveToNextPlayer")
        guard let currentPlayerIndex = currentPlayerIndex else {
            assertionFailure("Error: No current player [currentPlayerIndex not set]")
            return
        }

        let newCurrentPlayerIndex: Int?
        if isBettingRoundComplete {
            newCurrentPlayerIndex = nil
        } else {
            newCurrentPlayerIndex = nextAvailableIndex(after: currentPlayerIndex, \.isInHand)
        }

        print("Dealer moving to next player [", newCurrentPlayerIndex ?? "none", "]")
        gameVM.currentPlayerIndex = newCurrentPlayerIndex
        updateCurrentPlayerStatus()
        await sleep(Dealer.nextPlayerDelay)
    }

    func moveCurrentPlayerToSmallBlind() async {
        guard playersTurn else { return }
        print("")
        print("Dealer.moveCurrentPlayerToSmallBlind")
        gameVM.currentPlayerIndex = gameVM.smallBlindIndex
        updateCurrentPlayerStatus()
        await sleep(Dealer.nextPlayerDelay)
    }

    func updateCurrentPlayerStatus() {
//        print("Dealer.updateCurrentPlayerStatus")
        forEachPlayer { i in
            gameVM.players[i].isCurrentPlayer = gameVM.isCurrentPlayer(at: i)
        }
    }
}

// MARK: Cards

private extension Dealer {
    func shuffle() {
        print("Dealer.shuffle")
        gameVM.deck = Deck.cards.shuffled().shuffled().shuffled()
    }

    func dealPlayers(at index: Int? = nil) async {
        guard let index = index else {
            await dealPlayers(at: gameVM.smallBlindIndex)
            return
        }

        let newIndex = nextAvailableIndex(after: index, \.isCanBet)
        DispatchQueue.main.async { dealPlayer(at: index) }
        await sleep(Dealer.cardTurnDelay * 2)
        guard newIndex != gameVM.smallBlindIndex else { return }
        await dealPlayers(at: newIndex)
    }

    func dealPlayer(at index: Int) {
        print("Dealer.dealPlayer [", index, "]")
        let bet = calculator.startingBet(at: index)
        gameVM.players[index].cards = [dealCard(), dealCard()]
        gameVM.players[index].isFolded = false
        gameVM.players[index].isOnTheButton = gameVM.isOnTheButton(at: index)
        gameVM.players[index].isBigBlind = gameVM.isBigBlind(at: index)
        gameVM.players[index].isSmallBlind = gameVM.isSmallBlind(at: index)
        gameVM.players[index].bet = bet
        gameVM.players[index].bestHand = Poker.calcBestHand(for: players[index])
    }

    func dealCommunityCards(all: Bool = false) {
        print("")
        print("Dealer.dealCommunityCards [", riverPosition, "]")
        guard !all else {
            gameVM.river = [dealCard(), dealCard(), dealCard(), dealCard(), dealCard()]
            return
        }
        if riverPosition == .flop {
            gameVM.river = [dealCard(), dealCard(), dealCard()]
        } else if [.turn, .river].contains(riverPosition) {
            gameVM.river.append(dealCard())
        }
    }

    func dealCard() -> Card {
        _ = gameVM.deck.popLast()
        return gameVM.deck.popLast() ?? Card(rank: .ace, suit: .spades)
    }

    func collectCards() {
        gameVM.river = []

        forEachPlayer { i in
            gameVM.players[i].cards = []
            gameVM.players[i].isFolded = false
        }

        setPosition(.preflop)
    }
}

// MARK: Chips

private extension Dealer {
    func collectBetChips() async {
        print("")
        print("Dealer.collectBetChips")

        let betChips = players.map(\.bet).reduce(0, +)

        forEachPlayer { i in
            gameVM.players[i].chips -= players[i].bet
            print("Dealer player [", i, "] contributes:", players[i].bet)
            gameVM.players[i].bet = 0
        }

        if betChips > 0 {
            await sleep(Dealer.nextCommunityCardDelay)
        }

        gameVM.pot += betChips
    }

    func collectFromLosers() {
        print("Dealer.collectFromLosers")

        forEachPlayer { i in
            if let bestHand = players[i].bestHand, !gameVM.winningHands.contains(bestHand) {
                gameVM.players[i].chips -= players[i].bet
                print("Dealer player [", i, "] loses:", players[i].bet)
            }
        }
    }

    func payWinners() {
        print("dealer.payWinners")
        let numberOfWinners = Double(gameVM.winningHands.count)
        let pot = Double(gameVM.pot)
        let payOutAmount = Int(pot / numberOfWinners)

        print("dealer pot:", pot)
        forEachPlayer { i in
            guard let bestHand = gameVM.players[i].bestHand else { return }
            guard gameVM.winningHands.contains(bestHand) else { return }
            gameVM.players[i].chips += payOutAmount - gameVM.players[i].bet
            print("Dealer player [", i, "] wins:", payOutAmount - gameVM.players[i].bet)
        }

        gameVM.pot = 0
        gameVM.winningHands = []
    }

}

// MARK: Utility

private extension Dealer {
    func forEachPlayer(_ condition: KeyPath<Player, Bool>? = nil, perform action: (Int) -> Void) {
        for i in 0..<players.count {
            if let condition = condition {
                let player = players[i]
                guard player[keyPath: condition] else { continue }
            }
            action(i)
        }
    }

    func prevAvailableIndex(before index: Int, _ condition: KeyPath<Player, Bool>? = nil) -> Int {
        let max = GameView.GameViewModel.numberOfPlayers
        var newIndex = Utility.indexSafeAddition(from: index, max: max, delta: -1)
        guard let condition = condition else { return newIndex }

        while !players[newIndex][keyPath: condition] {
            guard newIndex != index else {
                assertionFailure("Error: Couldn't find available index")
                return -1
            }
            newIndex = Utility.indexSafeAddition(from: newIndex, max: max, delta: -1)
        }

        return newIndex
    }
}
