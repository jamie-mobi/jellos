//
//  JellyOSApp.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyComposition
import JellyPresentation
import JellyPresentationCore
import SwiftUI

@main
struct JellyOSApp: App {

    // MARK: - State

    @State
    private var graph = Self.makeGraph()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            RootScreen()
                .appGraph(graph)
        }
        .commands {
            AddServerCommands()
            LibraryCommands()
        }
    }

    // MARK: - Graph

    private static func makeGraph() -> AppGraph {
        #if DEBUG
        AppDependencies.makeGraph(arguments: ProcessInfo.processInfo.arguments)
        #else
        AppDependencies.makeGraph()
        #endif
    }
}
