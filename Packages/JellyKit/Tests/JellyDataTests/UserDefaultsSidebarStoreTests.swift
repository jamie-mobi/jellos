//
//  UserDefaultsSidebarStoreTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("UserDefaultsSidebarStore", .tags(.data))
struct UserDefaultsSidebarStoreTests {
    @Test
    func `a saved selection is read back by a new store on the same suite`() {
        let suiteName = "test.\(UUID().uuidString)"

        UserDefaultsSidebarStore(suiteName: suiteName).save(.library("lib-shows"))

        #expect(UserDefaultsSidebarStore(suiteName: suiteName).load() == .library("lib-shows"))
    }

    @Test
    func `nothing saved reads back as nil`() {
        #expect(UserDefaultsSidebarStore(suiteName: "test.\(UUID().uuidString)").load() == nil)
    }
}
