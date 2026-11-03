//
//  LibraryScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import SwiftUI

struct LibraryScreen: View {

    // MARK: - Input

    let name: String

    // MARK: - View

    var body: some View {
        ContentUnavailableView(name, systemImage: "film")
            .navigationTitle(name)
            .accessibilityIdentifier(AccessibilityID.Main.library)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LibraryScreen(name: "Movies")
    }
}
#endif
#endif
