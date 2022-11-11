//
//  UtilityTests.swift
//  PokerTests
//
//  Created by Benjamin Lewis on 11/11/2022.
//

import XCTest
@testable import Poker

final class UtilityTests: XCTestCase {
    func testIndexSafeAddition() throws {
        let max = 5
        let expectations: [(from: Int, delta: Int, expectation: Int)] = [
            (4, 1, 0),
            (0, 5, 0),
            (3, 4, 2),
            (3, 5, 3),
            (3, 10, 3),
        ]

        for expectation in expectations {
            let newIndex = Utility.indexSafeAddition(from: expectation.from, max: max, delta: expectation.delta)
            XCTAssertEqual(newIndex, expectation.expectation)
        }
    }
}
