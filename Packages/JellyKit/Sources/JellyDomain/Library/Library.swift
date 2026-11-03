//
//  Library.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public struct Library: Identifiable, Equatable, Sendable {

    // MARK: - Stored

    public let id: String
    public let name: String
    public let kind: LibraryKind

    // MARK: - Init

    public init(id: String, name: String, kind: LibraryKind) {
        self.id = id
        self.name = name
        self.kind = kind
    }
}
