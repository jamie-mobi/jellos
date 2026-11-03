//
//  AppDependenciesTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

@testable import JellyComposition
import Testing

@Suite("AppDependencies", .tags(.composition))
struct AppDependenciesTests {
    @Test
    func `server requests time out after 20 seconds`() {
        #expect(AppDependencies.makeSessionConfiguration().timeoutIntervalForRequest == 20)
    }
}
