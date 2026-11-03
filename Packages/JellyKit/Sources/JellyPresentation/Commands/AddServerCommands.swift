//
//  AddServerCommands.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import SwiftUI

public struct AddServerCommands: Commands {

    // MARK: - Focused values

    @FocusedValue(\.addServer)
    private var addServer

    // MARK: - Init

    public init() {}

    // MARK: - Commands

    public var body: some Commands {
        CommandGroup(after: .newItem) {
            Button(String(localized: "Add Server…", bundle: .module)) {
                addServer?()
            }
            .keyboardShortcut("n", modifiers: [.shift, .command])
            .disabled(addServer == nil)
        }
    }
}
#endif
