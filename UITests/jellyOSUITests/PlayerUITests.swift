//
//  PlayerUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 04/11/2026.
//

import JellyAccessibility
import XCTest

final class PlayerUITests: XCTestCase {

    // MARK: - Constants

    private enum Constants {
        static let timeout: TimeInterval = 10
        static let absentTimeout: TimeInterval = 2
        static let resumeFixture = "signed-in-resume"
        static let noSavedPositionFixture = "signed-in"
    }

    // MARK: - Lifecycle

    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func test_S012_resumeSheetOffersResumeAndStartOver() {
        let app = XCUIApplication.launched(fixture: Constants.resumeFixture)

        tapPrimaryButton(in: app)

        XCTAssertTrue(element(AccessibilityID.Player.resumeSheet, in: app).waitForExistence(timeout: Constants.timeout))
        XCTAssertTrue(app.buttons[AccessibilityID.Player.resumeButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Player.startOverButton].exists)
        XCTAssertFalse(element(AccessibilityID.Player.view, in: app).exists)
    }

    @MainActor
    func test_S012_resumeOpensThePlayer() {
        let app = XCUIApplication.launched(fixture: Constants.resumeFixture)
        tapPrimaryButton(in: app)
        let resume = app.buttons[AccessibilityID.Player.resumeButton]
        XCTAssertTrue(resume.waitForExistence(timeout: Constants.timeout))

        resume.tap()

        XCTAssertTrue(element(AccessibilityID.Player.view, in: app).waitForExistence(timeout: Constants.timeout))
        XCTAssertFalse(element(AccessibilityID.Player.resumeSheet, in: app).exists)
    }

    @MainActor
    func test_S012_startOverOpensThePlayer() {
        let app = XCUIApplication.launched(fixture: Constants.resumeFixture)
        tapPrimaryButton(in: app)
        let startOver = app.buttons[AccessibilityID.Player.startOverButton]
        XCTAssertTrue(startOver.waitForExistence(timeout: Constants.timeout))

        startOver.tap()

        XCTAssertTrue(element(AccessibilityID.Player.view, in: app).waitForExistence(timeout: Constants.timeout))
        XCTAssertFalse(element(AccessibilityID.Player.resumeSheet, in: app).exists)
    }

    @MainActor
    func test_S012_cancelClosesTheSheetWithoutPlaying() {
        let app = XCUIApplication.launched(fixture: Constants.resumeFixture)
        tapPrimaryButton(in: app)
        let cancel = app.buttons[AccessibilityID.Player.cancelButton]
        XCTAssertTrue(cancel.waitForExistence(timeout: Constants.timeout))

        cancel.tap()

        XCTAssertTrue(app.buttons[AccessibilityID.Home.heroPrimaryButton].waitForExistence(timeout: Constants.timeout))
        XCTAssertFalse(element(AccessibilityID.Player.view, in: app).exists)
    }

    @MainActor
    func test_S012_noSavedPositionPlaysWithoutTheSheet() {
        let app = XCUIApplication.launched(fixture: Constants.noSavedPositionFixture)

        tapPrimaryButton(in: app)

        XCTAssertTrue(element(AccessibilityID.Player.view, in: app).waitForExistence(timeout: Constants.timeout))
        XCTAssertFalse(element(AccessibilityID.Player.resumeSheet, in: app).exists)
    }

    // MARK: - Helpers

    @MainActor
    private func tapPrimaryButton(in app: XCUIApplication) {
        let primary = app.buttons[AccessibilityID.Home.heroPrimaryButton]
        XCTAssertTrue(primary.waitForExistence(timeout: Constants.timeout))
        primary.tap()
    }

    @MainActor
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }
}
