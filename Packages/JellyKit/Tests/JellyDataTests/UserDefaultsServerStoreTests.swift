//
//  UserDefaultsServerStoreTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("UserDefaultsServerStore", .tags(.data))
struct UserDefaultsServerStoreTests {
    private static let server = Server(
        id: "abc",
        name: "Den",
        version: "10.11.0",
        address: URL(string: "http://den.local:8096")!
    )

    private func makeSUT() -> UserDefaultsServerStore {
        UserDefaultsServerStore(suiteName: "test.\(UUID().uuidString)")
    }

    @Test
    func `an empty store loads no servers`() {
        #expect(makeSUT().load().isEmpty)
    }

    @Test
    func `saved servers load back unchanged`() {
        let sut = makeSUT()

        sut.save([Self.server])

        #expect(sut.load() == [Self.server])
    }

    @Test
    func `a second store on the same defaults sees the saved servers`() {
        let suiteName = "test.\(UUID().uuidString)"
        UserDefaultsServerStore(suiteName: suiteName).save([Self.server])

        #expect(UserDefaultsServerStore(suiteName: suiteName).load() == [Self.server])
    }
}
