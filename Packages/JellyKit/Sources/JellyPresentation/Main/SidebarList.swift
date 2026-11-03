//
//  SidebarList.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import SwiftUI

struct SidebarList: View {

    // MARK: - Binding

    @Binding
    var selection: SidebarItem?

    // MARK: - Input

    let libraries: [Library]
    let hasLoaded: Bool

    // MARK: - Init

    init(libraries: [Library], hasLoaded: Bool, selection: Binding<SidebarItem?>) {
        self.libraries = libraries
        self.hasLoaded = hasLoaded
        _selection = selection
    }

    // MARK: - View

    var body: some View {
        List(selection: $selection) {
            Label(String(localized: "Home", bundle: .module), systemImage: "house")
                .tag(SidebarItem.home)
                .accessibilityIdentifier(AccessibilityID.Sidebar.home)

            Section(String(localized: "Libraries", bundle: .module)) {
                ForEach(Array(libraries.enumerated()), id: \.element.id) { index, library in
                    Label(library.name, systemImage: icon(for: library.kind))
                        .tag(SidebarItem.library(library.id))
                        .accessibilityIdentifier(AccessibilityID.Sidebar.library(index))
                }

                if hasLoaded, libraries.isEmpty {
                    Text(String(localized: "This server has no libraries.", bundle: .module))
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier(AccessibilityID.Sidebar.noLibraries)
                }
            }

            Label(String(localized: "Favorites", bundle: .module), systemImage: "heart")
                .tag(SidebarItem.favorites)
                .accessibilityIdentifier(AccessibilityID.Sidebar.favorites)
        }
        .navigationTitle(String(localized: "jellyOS", bundle: .module))
    }

    // MARK: - Helpers

    private func icon(for kind: LibraryKind) -> String {
        switch kind {
        case .movies:
            "film"
        case .shows:
            "tv"
        case .music:
            "music.note"
        case .collections:
            "square.stack"
        case .other:
            "folder"
        }
    }
}

#if DEBUG
import JellyMocks

#Preview("Libraries") {
    @Previewable @State
    var selection: SidebarItem? = .home
    NavigationSplitView {
        SidebarList(libraries: MockLibraryRepository.fixtureLibraries, hasLoaded: true, selection: $selection)
    } detail: {
        EmptyView()
    }
}

#Preview("No libraries") {
    @Previewable @State
    var selection: SidebarItem? = .home
    NavigationSplitView {
        SidebarList(libraries: [], hasLoaded: true, selection: $selection)
    } detail: {
        EmptyView()
    }
}
#endif
#endif
