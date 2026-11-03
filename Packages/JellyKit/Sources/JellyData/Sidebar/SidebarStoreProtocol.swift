//
//  SidebarStoreProtocol.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import JellyDomain

public protocol SidebarStoreProtocol: Sendable {
    func load() -> SidebarItem?
    func save(_ item: SidebarItem)
}
