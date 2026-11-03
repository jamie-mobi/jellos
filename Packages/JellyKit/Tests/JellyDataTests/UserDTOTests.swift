//
//  UserDTOTests.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import JellyData
import JellyDomain
import Testing

@Suite("UserDTO", .tags(.data))
struct UserDTOTests {
    private static let server = URL(string: "http://demo.local:8096")!

    @Test
    func `toDomain builds the avatar URL from the primary image tag`() throws {
        let users = try APICoding.makeDecoder().decode([UserDTO].self, from: Data(UserPayloadFixtures.publicUsers.utf8))

        let alice = try users[0].toDomain(server: Self.server)

        #expect(alice == User(
            id: "user-a",
            name: "Alice",
            hasPassword: true,
            imageURL: URL(string: "http://demo.local:8096/Users/user-a/Images/Primary?tag=tag-a&maxWidth=240")
        ))
    }

    @Test
    func `a user with no image tag has no avatar URL`() throws {
        let users = try APICoding.makeDecoder().decode([UserDTO].self, from: Data(UserPayloadFixtures.publicUsers.utf8))

        #expect(try users[1].toDomain(server: Self.server).imageURL == nil)
    }

    @Test
    func `a user with no id or name is missing session data`() {
        #expect(throws: SignInError.missingSession) {
            try UserDTO(id: nil, name: "x", hasPassword: nil, primaryImageTag: nil).toDomain(server: Self.server)
        }
    }
}
