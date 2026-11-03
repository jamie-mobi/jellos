//
//  ConnectError.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum ConnectError: Error, Equatable, Sendable {
    case invalidAddress
    case network
    case server
    case decoding
    case encoding
    case unauthorised
    case forbidden
    case notFound
    case missingServerInfo
}
