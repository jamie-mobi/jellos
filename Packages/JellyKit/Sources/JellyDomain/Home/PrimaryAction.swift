//
//  PrimaryAction.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum PrimaryAction: Equatable, Sendable {
    case play
    case resume
    case playEpisode(season: Int, episode: Int)
}
