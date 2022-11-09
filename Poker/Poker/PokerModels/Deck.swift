//
//  Deck.swift
//  Poker
//
//  Created by Benjamin Lewis on 9/11/2022.
//

import Foundation

struct Deck {
    static let cards: [Card] = {
        var cards: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        return cards
    }()
}
