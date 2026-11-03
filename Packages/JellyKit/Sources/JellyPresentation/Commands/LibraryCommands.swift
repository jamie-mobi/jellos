//
//  LibraryCommands.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import SwiftUI

public struct LibraryCommands: Commands {

    // MARK: - Constants

    private enum Constants {
        static let shortcutDigits: [Character] = ["2", "3", "4", "5", "6", "7", "8", "9"]
    }

    // MARK: - Focused values

    @FocusedValue(\.sidebarShortcut)
    private var shortcut

    // MARK: - Init

    public init() {}

    // MARK: - Commands

    public var body: some Commands {
        CommandGroup(before: .sidebar) {
            Button(String(localized: "Home", bundle: .module)) {
                shortcut?.select(1)
            }
            .keyboardShortcut("1", modifiers: .command)
            .disabled(shortcut == nil)

            ForEach(Array(libraryShortcuts.enumerated()), id: \.offset) { index, name in
                Button(name) {
                    shortcut?.select(index + 2)
                }
                .keyboardShortcut(KeyEquivalent(Constants.shortcutDigits[index]), modifiers: .command)
            }

            Divider()
        }
    }

    // MARK: - Helpers

    private var libraryShortcuts: [String] {
        Array((shortcut?.libraryNames ?? []).prefix(Constants.shortcutDigits.count))
    }
}
#endif
