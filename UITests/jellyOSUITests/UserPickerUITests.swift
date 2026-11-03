//
//  UserPickerUITests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyAccessibility
import XCTest

final class UserPickerUITests: XCTestCase {

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
    func test_S003_pickerShowsUsersAndOtherUser() {
        let app = openUserPicker()

        XCTAssertTrue(app.buttons[AccessibilityID.UserPicker.user(0)].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.UserPicker.user(1)].exists)
        XCTAssertTrue(app.buttons[AccessibilityID.UserPicker.otherUser].exists)
    }

    @MainActor
    func test_S003_passwordSheetShowsFieldAndSignIn() {
        let app = openUserPicker()

        app.buttons[AccessibilityID.UserPicker.user(0)].tap()

        XCTAssertTrue(app.secureTextFields[AccessibilityID.SignIn.passwordField].waitForExistence(timeout: Constants.timeout))
        XCTAssertTrue(app.buttons[AccessibilityID.SignIn.signInButton].exists)
    }

    @MainActor
    func test_S003_wrongPasswordShowsErrorInSheet() {
        let app = openUserPicker()
        app.buttons[AccessibilityID.UserPicker.user(0)].tap()

        enterPassword("wrong", in: app)

        let error = app.staticTexts[AccessibilityID.SignIn.error]
        XCTAssertTrue(error.waitForExistence(timeout: Constants.timeout))
        XCTAssertEqual(error.label, "The user name or password is not right.")
    }

    @MainActor
    func test_S003_signInOpensHomeAndRestartKeepsTheUser() {
        let app = openUserPicker()
        app.buttons[AccessibilityID.UserPicker.user(0)].tap()

        enterPassword("secret", in: app)

        XCTAssertTrue(homeElement(in: app).waitForExistence(timeout: Constants.timeout))

        app.terminate()
        let relaunched = XCUIApplication.launched(fixture: "users", reset: false)

        XCTAssertTrue(homeElement(in: relaunched).waitForExistence(timeout: Constants.timeout))
    }

    // MARK: - Helpers

    @MainActor
    private func openUserPicker() -> XCUIApplication {
        let app = XCUIApplication.launched(fixture: "users")
        let row = app.buttons[AccessibilityID.ServerList.row(0)]
        XCTAssertTrue(row.waitForExistence(timeout: Constants.timeout))
        row.tap()
        XCTAssertTrue(app.buttons[AccessibilityID.UserPicker.user(0)].waitForExistence(timeout: Constants.timeout))
        return app
    }

    @MainActor
    private func enterPassword(_ password: String, in app: XCUIApplication) {
        let field = app.secureTextFields[AccessibilityID.SignIn.passwordField]
        XCTAssertTrue(field.waitForExistence(timeout: Constants.timeout))
        field.tap()
        field.typeText(password)
        app.buttons[AccessibilityID.SignIn.signInButton].tap()
    }

    @MainActor
    private func homeElement(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[AccessibilityID.Main.home]
    }
}
