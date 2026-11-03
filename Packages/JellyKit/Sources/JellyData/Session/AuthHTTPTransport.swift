//
//  AuthHTTPTransport.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

final class AuthHTTPTransport: AuthHTTPTransportProtocol, Sendable {

    // MARK: - Private

    private let urlSession: URLSession
    private let identity: ClientIdentity
    private let extraHeaders: [String: String]

    // MARK: - Init

    init(urlSession: URLSession, identity: ClientIdentity, extraHeaders: [String: String] = [:]) {
        self.urlSession = urlSession
        self.identity = identity
        self.extraHeaders = extraHeaders
    }

    // MARK: - AuthHTTPTransportProtocol

    func fetchPublicUsers(server: URL) async throws(SignInError) -> [UserDTO] {
        let request = AuthRequest.publicUsers(server: server, identity: identity, extraHeaders: extraHeaders)
        return try await HTTPSending.send(request, urlSession: urlSession, errorType: SignInError.self, as: [UserDTO].self)
    }

    func authenticate(server: URL, userName: String, password: String) async throws(SignInError) -> AuthenticationResultDTO {
        let body = try HTTPBody.encode(AuthenticateByNameDTO(username: userName, pw: password), as: SignInError.self)
        let request = AuthRequest.authenticateByName(server: server, body: body, identity: identity, extraHeaders: extraHeaders)
        return try await HTTPSending.send(
            request,
            urlSession: urlSession,
            errorType: SignInError.self,
            as: AuthenticationResultDTO.self
        )
    }
}
