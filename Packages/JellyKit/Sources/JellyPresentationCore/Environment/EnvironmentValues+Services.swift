//
//  EnvironmentValues+Services.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyComposition
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
}
