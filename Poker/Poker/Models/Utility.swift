//
//  Utility.swift
//  Poker
//
//  Created by Benjamin Lewis on 11/11/2022.
//

import Foundation

struct Utility {
    static func indexSafeAddition(from index: Int, max: Int, delta: Int = 1) -> Int {
        var nextIndex = index + delta
        while nextIndex >= max { nextIndex -= max }
        while nextIndex < 0 { nextIndex += max }
        return nextIndex
    }
}
