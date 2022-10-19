//
//  Suit.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

enum Suit: String {
    case heart = "heart"
    case diamond = "diamond"
    case club = "club"
    case spade = "spade"
}
extension Suit: CaseIterable {}
