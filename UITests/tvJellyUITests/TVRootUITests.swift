//
//  TVRootUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyAccessibility
import XCTest

final class TVRootUITests: XCTestCase {

    // MARK: - Lifecycle

    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func test_launchShowsTheRootScreen() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts[AccessibilityID.TVRoot.title].waitForExistence(timeout: 10))
    }
}
