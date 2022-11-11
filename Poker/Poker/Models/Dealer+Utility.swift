//
//  Dealer+Utility.swift
//  Poker
//
//  Created by Benjamin Lewis on 14/11/2022.
//

import Foundation

extension Dealer {
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let interval = DispatchTime.now().string(format: "[%07.3f]")
        let items = [interval] + items
        Swift.print(items, separator: separator, terminator: terminator)
    }

    func sleep(_ seconds: Double) async {
        let seconds = gameVM.player.isFolded ? Dealer.playerIsFoldedSleepDelay : seconds
        print("Sleep [", seconds, "]")
        try? await Task.sleep(nanoseconds: UInt64(seconds * Double(NSEC_PER_SEC)))
    }
}
