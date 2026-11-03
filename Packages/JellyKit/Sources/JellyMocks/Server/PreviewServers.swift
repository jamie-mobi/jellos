//
//  PreviewServers.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import JellyDomain

#if DEBUG
public enum PreviewServers {
    public static let livingRoom = Server(
        id: "preview-1",
        name: "Living Room",
        version: "10.11.0",
        address: URL(string: "http://192.168.1.10:8096")!
    )

    public static let longName = Server(
        id: "preview-2",
        name: "A Very Long Server Name That Should Truncate Somewhere Sensible",
        version: "10.11.0",
        address: URL(string: "https://a-very-long-host-name.example.com/jellyfin")!
    )

    public static let fixture = Server(
        id: "fixture-server",
        name: "Fixture Server",
        version: "10.11.0",
        address: URL(string: "http://fixture.local:8096")!
    )
}
#endif
