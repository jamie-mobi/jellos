//
//  AuthHTTPTransportProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

protocol AuthHTTPTransportProtocol: Sendable {
    func fetchPublicUsers(server: URL) async throws(SignInError) -> [UserDTO]
    func authenticate(server: URL, userName: String, password: String) async throws(SignInError) -> AuthenticationResultDTO
}
