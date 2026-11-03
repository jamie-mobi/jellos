//
//  AuthRepositoryProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol AuthRepositoryProtocol: Sendable {
    func publicUsers(server: Server) async throws(SignInError) -> [User]
    func signIn(server: Server, userName: String, password: String) async throws(SignInError) -> Session
    func restoreSession() async -> Session?
}
