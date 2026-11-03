//
//  SignInFailure.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum SignInFailure: Equatable, Sendable {
    case wrongCredentials
    case unreachable

    // MARK: - Init

    public init(_ error: SignInError) {
        switch error {
        case .unauthorised:
            self = .wrongCredentials
        case .network,
             .server,
             .decoding,
             .encoding,
             .forbidden,
             .notFound,
             .missingSession:
            self = .unreachable
        }
    }
}
