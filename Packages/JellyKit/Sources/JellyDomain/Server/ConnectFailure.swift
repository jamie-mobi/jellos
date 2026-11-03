//
//  ConnectFailure.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ConnectFailure: Equatable, Sendable {
    case invalidAddress
    case unreachable

    // MARK: - Init

    public init(_ error: ConnectError) {
        switch error {
        case .invalidAddress:
            self = .invalidAddress
        case .network,
             .server,
             .decoding,
             .encoding,
             .unauthorised,
             .forbidden,
             .notFound,
             .missingServerInfo:
            self = .unreachable
        }
    }
}
