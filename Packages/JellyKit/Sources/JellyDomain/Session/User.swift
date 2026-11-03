//
//  User.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct User: Identifiable, Equatable, Sendable {

    // MARK: - Stored

    public let id: String
    public let name: String
    public let hasPassword: Bool
    public let imageURL: URL?

    // MARK: - Init

    public init(id: String, name: String, hasPassword: Bool, imageURL: URL?) {
        self.id = id
        self.name = name
        self.hasPassword = hasPassword
        self.imageURL = imageURL
    }
}
