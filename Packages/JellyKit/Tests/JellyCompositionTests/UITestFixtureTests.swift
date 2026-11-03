//
//  UITestFixtureTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyMocks
import Testing

@Suite("UITestFixture", .tags(.composition))
struct UITestFixtureTests {
    @Test(

        arguments: [
            (["-ui-test-fixture", "connect-success"], UITestFixture.connectSuccess),
            (["App", "-ui-test-reset", "-ui-test-fixture", "connect-unreachable"], UITestFixture.connectUnreachable)
        ]
    )
    func `reads the fixture named after the launch argument`(arguments: [String], expected: UITestFixture) {
        #expect(UITestFixture(arguments: arguments) == expected)
    }

    @Test(

        arguments: [
            [],
            ["App"],
            ["-ui-test-fixture"],
            ["-ui-test-fixture", "unknown"]
        ]
    )
    func `gives no fixture when the argument is missing, has no value, or names no fixture`(arguments: [String]) {
        #expect(UITestFixture(arguments: arguments) == nil)
    }
}
