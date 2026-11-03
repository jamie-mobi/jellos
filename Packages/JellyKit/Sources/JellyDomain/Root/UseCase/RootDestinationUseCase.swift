//
//  RootDestinationUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum RootDestinationUseCase {
    public static func destination(hasLoaded: Bool, serverCount: Int) -> RootDestination {
        guard hasLoaded else {
            return .loading
        }

        return serverCount == 0 ? .connect : .servers
    }
}
