//
//  XCUIApplication+Fixture.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import XCTest

extension XCUIApplication {
    static func launched(fixture: String, reset: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-test-fixture", fixture] + (reset ? ["-ui-test-reset"] : [])
        app.launch()
        return app
    }
}
