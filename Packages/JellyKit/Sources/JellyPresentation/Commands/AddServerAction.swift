//
//  AddServerAction.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

#if os(iOS) || os(macOS)
import SwiftUI

struct AddServerAction: Equatable {

    // MARK: - Input

    let perform: () -> Void

    // MARK: - Call

    func callAsFunction() {
        perform()
    }

    // MARK: - Equatable

    // Every scene's action does the same thing, so any two are interchangeable.
    static func == (lhs: AddServerAction, rhs: AddServerAction) -> Bool {
        true
    }
}

extension FocusedValues {
    @Entry
    var addServer: AddServerAction?
}
#endif
