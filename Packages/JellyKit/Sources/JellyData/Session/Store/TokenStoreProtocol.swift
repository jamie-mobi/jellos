//
//  TokenStoreProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public protocol TokenStoreProtocol: Sendable {
    func token(for account: String) -> String?
    func setToken(_ token: String, for account: String)
    func deleteToken(for account: String)
}
