//
//  MediaKind.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum MediaKind: Equatable, Sendable {
    case movie
    case series
    case episode
    case other

    // MARK: - Init

    public init(type: String?) {
        switch type {
        case "Movie":
            self = .movie
        case "Series":
            self = .series
        case "Episode":
            self = .episode
        default:
            self = .other
        }
    }
}
