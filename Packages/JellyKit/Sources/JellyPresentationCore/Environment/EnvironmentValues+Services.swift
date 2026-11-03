//
//  EnvironmentValues+Services.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyComposition
import JellyPlayback
import JellyServices
import SwiftUI

private let defaultGraph = MainActor.assumeIsolated {
    AppDependencies.makeGraph()
}

public extension EnvironmentValues {
    @Entry
    var connectService: ConnectService = defaultGraph.connectService
    @Entry
    var serverListService: ServerListService = defaultGraph.serverListService
    @Entry
    var sessionService: SessionService = defaultGraph.sessionService
    @Entry
    var userPickerService: UserPickerService = defaultGraph.userPickerService
    @Entry
    var signInService: SignInService = defaultGraph.signInService
    @Entry
    var sidebarService: SidebarService = defaultGraph.sidebarService
    @Entry
    var playbackService: PlaybackService = defaultGraph.playbackService
}
