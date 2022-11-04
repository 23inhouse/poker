//
//  Game.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

class Game: ObservableObject {
    static var deck: [Card] = {
        var deck: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        return deck
    }()

    static var numberOfPlayers: Int = 5

    var deck: [Card] = Game.deck

    @Published var players: [Player] = (0..<Game.numberOfPlayers).map { _ in Player() }
    @Published var river: [Card] = []
    @Published var winningHands: [BestHand] = []
    @Published var riverPosition: RiverPosition = .preflop
    @Published var isPoopMode: Bool = false

    var player: Player {
        get { players.last! }
        set(newPlayer) { players[players.count - 1] = newPlayer }
    }

    var computerPlayers: [Player] { Array(players.prefix(Game.numberOfPlayers - 1)) }

    var over: Bool { riverPosition == .over }
    var isFolded: Bool { player.isFolded }
    var winningCards: [Card] { winningHands.flatMap(\.handWithKicker) }

    func start() {
        print("Came.start")
        deal()
        calcBestHands()
    }

    func new() {
        self.winningHands = []
        self.river = []

        for i in 0..<players.count {
            self.players[i].cards = []
            self.players[i].isFolded = false
            self.players[i].bestHand = nil
        }

        self.riverPosition = .preflop
    }

    func deal(deck: [Card] = []) {
        print("deal")
        if deck.isEmpty {
            shuffle()
        } else {
            self.deck = deck
        }
        self.players = dealPlayers()
        self.river = []
        self.riverPosition = .preflop
    }


    func shuffle() {
        deck = Game.deck.shuffled().shuffled().shuffled()
    }

    func dealCard() -> Card {
        _ = self.deck.popLast()
        return self.deck.popLast() ?? Card(rank: .ace, suit: .spades)
    }

    func dealPlayers() -> [Player] {
        (0..<Game.numberOfPlayers).map { _ in
            Player(cards: [dealCard(), dealCard()])
        }
    }

    func dealRiver() {
        if riverPosition == .preflop {
            river = [dealCard(), dealCard(), dealCard()]
        } else if [.flop, .turn].contains(riverPosition) {
            river.append(dealCard())
        }
    }

    func next() {
//        print("game.next")
        let cardTurnDelay: Double = 0.125
//        guard !isFolded else {
//            print("isFolded")
//            riverPosition = .over
//            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
//                self.calcBestHand()
//            }
//            player.isFolded = false
//            return
//        }

        switch riverPosition {
        case .preflop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .flop
                self.calcBestHands()
            }
        case .flop:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .turn
                self.calcBestHands()
            }
        case .turn:
            dealRiver()
            DispatchQueue.main.asyncAfter(deadline: .now() + cardTurnDelay) {
                self.riverPosition = .river
                self.calcBestHands()
            }
        case .river:
            riverPosition = .over
            calcBestHands()
        case .over:
            print("over")
            new()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.deal()
                self.calcBestHands()
//                isFolded = false
//                isChecked = false
//                isBet = false
            }
        }
    }

    func calcBestHands() {
        print("Game.calcBestHand")
        let playerBestHands = Poker.calcBestHands(from: players, river: river)

        for (index, playerBestHand) in playerBestHands.enumerated() {
//            print("index:", index, "bestHand:", playerBestHand, playerBestHand.hand!, playerBestHand.cards)
            self.players[index].bestHand = playerBestHand
        }

        guard riverPosition == .over || isPoopMode else { return }

        self.winningHands = Poker.calcWinningHands(from: playerBestHands)
        let bestKickerHands = Poker.calcBestHandWithKicker(from: playerBestHands, winningHands: winningHands)
        guard !bestKickerHands.isEmpty else { return }

        for (index, bestHand) in bestKickerHands.enumerated() {
            self.players[index].bestHand = bestHand

            for (index, winningHand) in winningHands.enumerated() {
                if winningHand == bestHand {
                    self.winningHands[index].tieBreakingKickerCard = bestHand.tieBreakingKickerCard
                }
            }
        }
    }
}
