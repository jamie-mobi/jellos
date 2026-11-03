//
//  MainScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import JellyPresentationCore
import JellyServices
import SwiftUI

struct MainScreen: View {

    // MARK: - Environment

    @Environment(\.sidebarService)
    private var sidebar

    // MARK: - State

    @State
    private var selection: SidebarItem? = .home

    // MARK: - Input

    let session: Session

    // MARK: - View

    var body: some View {
        NavigationSplitView {
            SidebarList(libraries: sidebar.libraries, hasLoaded: sidebar.hasLoaded, selection: $selection)
        } detail: {
            NavigationStack {
                detail
            }
        }
        .task(id: session.user.id) {
            await sidebar.start(session: session)
            selection = sidebar.selection
        }
        .onChange(of: selection) { _, item in
            guard let item else {
                return
            }

            sidebar.select(item)
        }
        .onChange(of: sidebar.selection) { _, item in
            selection = item
        }
        .focusedSceneValue(
            \.sidebarShortcut,
            SidebarShortcutAction(libraryNames: sidebar.libraries.map(\.name)) { number in
                sidebar.selectShortcut(number)
            }
        )
    }

    // MARK: - Detail

    @ViewBuilder
    private var detail: some View {
        switch selection ?? .home {
        case .home:
            HomeScreen(session: session)
        case let .library(id):
            LibraryScreen(name: sidebar.libraries.first { $0.id == id }?.name ?? "")
        case .favorites:
            FavoritesScreen()
        }
    }
}
#endif
