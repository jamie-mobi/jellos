//
//  SidebarShortcutAction.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import SwiftUI

struct SidebarShortcutAction: Equatable {

    // MARK: - Input

    let libraryNames: [String]
    let select: (Int) -> Void

    // MARK: - Equatable

    static func == (lhs: SidebarShortcutAction, rhs: SidebarShortcutAction) -> Bool {
        lhs.libraryNames == rhs.libraryNames
    }
}

extension FocusedValues {
    @Entry
    var sidebarShortcut: SidebarShortcutAction?
}
#endif
