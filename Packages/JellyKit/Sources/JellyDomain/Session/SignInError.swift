//
//  SignInError.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum SignInError: Error, Equatable, Sendable {
    case network
    case server
    case decoding
    case encoding
    case unauthorised
    case forbidden
    case notFound
    case missingSession
}
