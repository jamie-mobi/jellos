//
//  HomeScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import SwiftUI

struct HomeScreen: View {

    // MARK: - Input

    let session: Session

    // MARK: - View

    var body: some View {
        ScrollView {
            Color.clear
                .frame(height: 1)
                .accessibilityIdentifier(AccessibilityID.Main.home)
        }
        .navigationTitle(String(localized: "Home", bundle: .module))
    }
}
#endif
