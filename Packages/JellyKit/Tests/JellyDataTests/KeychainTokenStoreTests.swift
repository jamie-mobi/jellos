//
//  KeychainTokenStoreTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import Testing

@Suite("KeychainTokenStore", .tags(.data))
struct KeychainTokenStoreTests {
    private func makeSUT() -> KeychainTokenStore {
        KeychainTokenStore(service: "mobi.jamie.jellyOS.tests.\(UUID().uuidString)")
    }

    @Test
    func `a saved token reads back, and a deleted one is gone`() {
        let sut = makeSUT()
        defer { sut.deleteToken(for: "user-a") }

        sut.setToken("token-123", for: "user-a")
        #expect(sut.token(for: "user-a") == "token-123")

        sut.deleteToken(for: "user-a")
        #expect(sut.token(for: "user-a") == nil)
    }

    @Test
    func `saving again replaces the token`() {
        let sut = makeSUT()
        defer { sut.deleteToken(for: "user-a") }

        sut.setToken("old", for: "user-a")
        sut.setToken("new", for: "user-a")

        #expect(sut.token(for: "user-a") == "new")
    }
}
