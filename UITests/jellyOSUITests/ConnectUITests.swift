//
//  ConnectUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyAccessibility
import XCTest

final class ConnectUITests: XCTestCase {

    // MARK: - Constants

    private enum Constants {
        static let appearTimeout: TimeInterval = 10
        static let unreachableTimeout: TimeInterval = 20
    }

    // MARK: - Lifecycle

    override func setUp() {
        continueAfterFailure = false
    }

    // MARK: - Tests

    @MainActor
    func test_S001_connectPageShowsAddressFieldAndButtons() {
        let app = XCUIApplication.launched(fixture: "connect-success")

        XCTAssertTrue(app.staticTexts[AccessibilityID.Connect.title].waitForExistence(timeout: Constants.appearTimeout))
        XCTAssertTrue(app.textFields[AccessibilityID.Connect.addressField].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Connect.connectButton].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.Connect.demoButton].exists)
    }

    @MainActor
    func test_S001_connectIsDisabledWhileAddressIsEmpty() {
        let app = XCUIApplication.launched(fixture: "connect-success")
        let connect = app.buttons[AccessibilityID.Connect.connectButton]
        XCTAssertTrue(connect.waitForExistence(timeout: Constants.appearTimeout))

        XCTAssertFalse(connect.isEnabled)

        typeAddress("demo.local:8096", in: app)

        XCTAssertTrue(connect.isEnabled)
    }

    @MainActor
    func test_S001_addressWithNoHostShowsNotValid() {
        let app = XCUIApplication.launched(fixture: "connect-success")
        XCTAssertTrue(app.textFields[AccessibilityID.Connect.addressField].waitForExistence(timeout: Constants.appearTimeout))

        typeAddress("http://", in: app)
        app.buttons[AccessibilityID.Connect.connectButton].tap()

        let error = app.staticTexts[AccessibilityID.Connect.error]
        XCTAssertTrue(error.waitForExistence(timeout: Constants.appearTimeout))
        XCTAssertEqual(error.label, "That address is not valid.")
    }

    @MainActor
    func test_S001_serverThatDoesNotAnswerShowsInlineError() {
        let app = XCUIApplication.launched(fixture: "connect-unreachable")
        XCTAssertTrue(app.textFields[AccessibilityID.Connect.addressField].waitForExistence(timeout: Constants.appearTimeout))

        typeAddress("demo.local:8096", in: app)
        app.buttons[AccessibilityID.Connect.connectButton].tap()

        let error = app.staticTexts[AccessibilityID.Connect.error]
        XCTAssertTrue(error.waitForExistence(timeout: Constants.unreachableTimeout))
        XCTAssertEqual(error.label, "Unable to connect to this address. Check it and try again.")
    }

    @MainActor
    func test_S001_addedServerIsStillThereAfterRelaunch() {
        let app = XCUIApplication.launched(fixture: "connect-success")
        XCTAssertTrue(app.textFields[AccessibilityID.Connect.addressField].waitForExistence(timeout: Constants.appearTimeout))

        typeAddress("demo.local:8096", in: app)
        app.buttons[AccessibilityID.Connect.connectButton].tap()
        XCTAssertTrue(app.descendants(matching: .any)[AccessibilityID.ServerList.row(0)].waitForExistence(timeout: Constants.appearTimeout))

        app.terminate()
        let relaunched = XCUIApplication.launched(fixture: "connect-success", reset: false)

        XCTAssertTrue(relaunched.descendants(matching: .any)[AccessibilityID.ServerList.row(0)]
            .waitForExistence(timeout: Constants.appearTimeout))
        XCTAssertFalse(relaunched.textFields[AccessibilityID.Connect.addressField].exists)
    }

    // MARK: - Helpers

    @MainActor
    private func typeAddress(_ address: String, in app: XCUIApplication) {
        let field = app.textFields[AccessibilityID.Connect.addressField]
        field.tap()
        field.typeText(address)
    }
}
