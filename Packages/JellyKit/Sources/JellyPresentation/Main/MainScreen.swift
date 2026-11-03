//
//  MainScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import JellyAccessibility
import JellyDomain
import SwiftUI

struct MainScreen: View {

    // MARK: - Input

    let session: Session

    // MARK: - View

    var body: some View {
        NavigationStack {
            Text(session.user.name)
                .font(.title)
                .navigationTitle(String(localized: "Home", bundle: .module))
                .accessibilityIdentifier(AccessibilityID.Main.home)
        }
    }
}
#endif
