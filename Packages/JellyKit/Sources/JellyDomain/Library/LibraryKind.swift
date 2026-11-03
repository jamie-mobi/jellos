//
//  LibraryKind.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum LibraryKind: Equatable, Sendable {
    case movies
    case shows
    case music
    case collections
    case other

    // MARK: - Init

    public init(collectionType: String?) {
        switch collectionType {
        case "movies":
            self = .movies
        case "tvshows":
            self = .shows
        case "music":
            self = .music
        case "boxsets":
            self = .collections
        default:
            self = .other
        }
    }
}
