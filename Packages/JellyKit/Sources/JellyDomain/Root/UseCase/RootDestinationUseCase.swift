//
//  RootDestinationUseCase.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum RootDestinationUseCase {
    public static func destination(
        hasLoaded: Bool,
        servers: [Server],
        session: Session?,
        pickedServer: Server?
    ) -> RootDestination {
        guard hasLoaded else {
            return .loading
        }

        switch (session, pickedServer, servers.isEmpty) {
        case let (session?, _, _):
            return .main(session)
        case let (nil, server?, _):
            return .users(server)
        case (nil, nil, true):
            return .connect
        case (nil, nil, false):
            return .servers
        }
    }
}
