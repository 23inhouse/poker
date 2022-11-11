//
//  DispatchTime+String.swift
//  Poker
//
//  Created by Benjamin Lewis on 14/11/2022.
//

import Foundation

extension DispatchTime {
    static var initTimestamp: DispatchTime = .now()

    func string(format: String) -> String {
        let currentTimestamp: DispatchTime = .now()
        let currentNanoseconds = currentTimestamp.uptimeNanoseconds
        let initNanoseconds = DispatchTime.initTimestamp.uptimeNanoseconds
        let nanoTime: UInt64 = currentNanoseconds > initNanoseconds ? currentNanoseconds - initNanoseconds : 0
        let timeInterval = Double(nanoTime) / 1_000_000_000
        return String(format: format, timeInterval)
    }
}
