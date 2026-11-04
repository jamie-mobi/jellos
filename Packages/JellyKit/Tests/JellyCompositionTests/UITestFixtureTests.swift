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
            (["App", "-ui-test-reset", "-ui-test-fixture", "connect-unreachable"], UITestFixture.connectUnreachable),
            (["-ui-test-fixture", "signed-in-resume"], UITestFixture.signedInResume)
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

    @Test
    func `only the resume fixture signs in with a saved position on Home`() {
        #expect(UITestFixture.signedInResume.seedsSession)
        #expect(UITestFixture.signedInResume.homeResumeTicks > 0)
        #expect(UITestFixture.signedIn.homeResumeTicks == 0)
        #expect(UITestFixture.signedInNoArt.homeResumeTicks == 0)
    }
}
