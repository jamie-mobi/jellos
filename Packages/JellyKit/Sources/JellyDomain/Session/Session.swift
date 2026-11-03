//
//  Session.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct Session: Equatable, Sendable {

    // MARK: - Stored

    public let server: Server
    public let user: User
    public let accessToken: String

    // MARK: - Init

    public init(server: Server, user: User, accessToken: String) {
        self.server = server
        self.user = user
        self.accessToken = accessToken
    }
}
