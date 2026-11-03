//
//  FavoritesScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import SwiftUI

struct FavoritesScreen: View {

    // MARK: - View

    var body: some View {
        ContentUnavailableView(String(localized: "Favorites", bundle: .module), systemImage: "heart")
            .navigationTitle(String(localized: "Favorites", bundle: .module))
            .accessibilityIdentifier(AccessibilityID.Main.favorites)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        FavoritesScreen()
    }
}
#endif
#endif
