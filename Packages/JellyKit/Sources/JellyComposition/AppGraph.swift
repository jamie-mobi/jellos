//
//  AppGraph.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyPlayback
import JellyServices

public struct AppGraph: Sendable {

    // MARK: - Services

    public let connectService: ConnectService
    public let serverListService: ServerListService
    public let sessionService: SessionService
    public let userPickerService: UserPickerService
    public let signInService: SignInService
    public let sidebarService: SidebarService
    public let playbackService: PlaybackService
}
