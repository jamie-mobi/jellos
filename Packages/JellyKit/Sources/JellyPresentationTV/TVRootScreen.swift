//
//  TVRootScreen.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(tvOS)
import JellyAccessibility
import SwiftUI

public struct TVRootScreen: View {

    // MARK: - Init

    public init() {}

    // MARK: - View

    public var body: some View {
        Text(verbatim: "jellyOS")
            .font(.largeTitle.bold())
            .accessibilityIdentifier(AccessibilityID.TVRoot.title)
    }
}

#if DEBUG
#Preview {
    TVRootScreen()
}
#endif
#endif
