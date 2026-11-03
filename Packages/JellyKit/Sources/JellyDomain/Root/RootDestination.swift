//
//  RootDestination.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum RootDestination: Equatable, Sendable {
    case loading
    case connect
    case servers
    case users(Server)
    case main(Session)
}
