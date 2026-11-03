//
//  SidebarUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyAccessibility
import XCTest

final class SidebarUITests: XCTestCase {

    // MARK: - Constants

    private enum Constants {
        static let timeout: TimeInterval = 10
    }

    // MARK: - Lifecycle

    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func test_S004_sidebarShowsHomeLibrariesAndFavorites() {
        let app = XCUIApplication.launched(fixture: "signed-in")

        XCTAssertTrue(element(AccessibilityID.Sidebar.home, in: app).waitForExistence(timeout: Constants.timeout))
        XCTAssertTrue(element(AccessibilityID.Sidebar.library(0), in: app).exists)
        XCTAssertTrue(element(AccessibilityID.Sidebar.library(1), in: app).exists)
        XCTAssertTrue(element(AccessibilityID.Sidebar.favorites, in: app).exists)
    }

    @MainActor
    func test_S004_commandNumberShowsHomeAndLibraries() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        XCTAssertTrue(element(AccessibilityID.Main.home, in: app).waitForExistence(timeout: Constants.timeout))

        app.typeKey("2", modifierFlags: .command)
        XCTAssertTrue(element(AccessibilityID.Main.library, in: app).waitForExistence(timeout: Constants.timeout))

        app.typeKey("1", modifierFlags: .command)
        XCTAssertTrue(element(AccessibilityID.Main.home, in: app).waitForExistence(timeout: Constants.timeout))
    }

    @MainActor
    func test_S004_selectedRowIsRememberedAcrossRestarts() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        let favorites = element(AccessibilityID.Sidebar.favorites, in: app)
        XCTAssertTrue(favorites.waitForExistence(timeout: Constants.timeout))

        favorites.tap()
        XCTAssertTrue(element(AccessibilityID.Main.favorites, in: app).waitForExistence(timeout: Constants.timeout))

        app.terminate()
        let relaunched = XCUIApplication.launched(fixture: "signed-in", reset: false)

        XCTAssertTrue(element(AccessibilityID.Main.favorites, in: relaunched).waitForExistence(timeout: Constants.timeout))
    }

    // MARK: - Helpers

    @MainActor
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }
}
