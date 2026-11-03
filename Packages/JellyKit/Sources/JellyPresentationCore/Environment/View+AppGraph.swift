//
//  View+AppGraph.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyComposition
import SwiftUI

public extension View {
    func appGraph(_ graph: AppGraph) -> some View {
        environment(\.connectService, graph.connectService)
            .environment(\.serverListService, graph.serverListService)
            .environment(\.sessionService, graph.sessionService)
            .environment(\.userPickerService, graph.userPickerService)
            .environment(\.signInService, graph.signInService)
    }
}
