//
//  HomeUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyAccessibility
import XCTest

final class HomeUITests: XCTestCase {

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
    func test_ATV001_heroShowsTitleMetadataOverviewAndButtons() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        XCTAssertTrue(element(AccessibilityID.Home.hero, in: app).waitForExistence(timeout: Constants.timeout))

        XCTAssertEqual(element(AccessibilityID.Home.heroTitle, in: app).label, "Driftwood Bay")
        XCTAssertEqual(element(AccessibilityID.Home.heroMetadata, in: app).label, "Series · Drama · Thriller")
        XCTAssertEqual(element(AccessibilityID.Home.heroRating, in: app).label, "TV-14")
        XCTAssertTrue(element(AccessibilityID.Home.heroOverview, in: app).exists)
        XCTAssertEqual(app.buttons[AccessibilityID.Home.heroPrimaryButton].label, "Play S2, E3")
        XCTAssertTrue(app.buttons[AccessibilityID.Home.heroFavoriteButton].exists)
    }

    @MainActor
    func test_ATV001_heroFillsAboutSixtyPercentOfTheHeight() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        let hero = element(AccessibilityID.Home.hero, in: app)
        XCTAssertTrue(hero.waitForExistence(timeout: Constants.timeout))

        let ratio = hero.frame.height / app.windows.firstMatch.frame.height

        XCTAssertGreaterThan(ratio, 0.5)
        XCTAssertLessThan(ratio, 0.7)
    }

    @MainActor
    func test_ATV001_favoritesButtonToggles() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        let favorite = app.buttons[AccessibilityID.Home.heroFavoriteButton]
        XCTAssertTrue(favorite.waitForExistence(timeout: Constants.timeout))
        XCTAssertEqual(favorite.label, "Add to Favorites")

        favorite.tap()

        XCTAssertTrue(app.buttons["Remove from Favorites"].waitForExistence(timeout: Constants.timeout))
    }

    @MainActor
    func test_ATV001_primaryButtonStartsPlayback() {
        let app = XCUIApplication.launched(fixture: "signed-in")
        let play = app.buttons[AccessibilityID.Home.heroPrimaryButton]
        XCTAssertTrue(play.waitForExistence(timeout: Constants.timeout))

        play.tap()

        XCTAssertTrue(element(AccessibilityID.Player.view, in: app).waitForExistence(timeout: Constants.timeout))
        app.buttons[AccessibilityID.Player.close].tap()
        XCTAssertTrue(play.waitForExistence(timeout: Constants.timeout))
    }

    @MainActor
    func test_ATV001_noItemWithBackdropMeansNoHero() {
        let app = XCUIApplication.launched(fixture: "signed-in-no-art")
        XCTAssertTrue(element(AccessibilityID.Main.home, in: app).waitForExistence(timeout: Constants.timeout))

        XCTAssertFalse(element(AccessibilityID.Home.hero, in: app).waitForExistence(timeout: 2))
    }

    // MARK: - Helpers

    @MainActor
    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }
}
