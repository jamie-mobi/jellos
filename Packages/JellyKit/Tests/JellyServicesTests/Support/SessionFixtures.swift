//
//  SessionFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

enum SessionFixtures {
    static let server = Server(id: "s", name: "Den", version: "1", address: URL(string: "http://den.local")!)
    static let alice = User(id: "user-a", name: "Alice", hasPassword: true, imageURL: nil)
    static let session = Session(server: server, user: alice, accessToken: "token-123")
}
