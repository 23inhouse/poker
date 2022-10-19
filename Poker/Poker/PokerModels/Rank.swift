//
//  Rank.swift
//  Poker
//
//  Created by Benjamin Lewis on 19/10/2022.
//

import Foundation

enum Rank: String {
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "10"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    case ace = "A"
}
extension Rank: CaseIterable {}
