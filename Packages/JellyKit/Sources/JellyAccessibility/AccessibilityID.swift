//
//  AccessibilityID.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum AccessibilityID {

    // MARK: - Connect

    public enum Connect {
        public static let title = "connect.title"
        public static let addressField = "connect.addressField"
        public static let connectButton = "connect.connectButton"
        public static let cancelButton = "connect.cancelButton"
        public static let demoButton = "connect.demoButton"
        public static let error = "connect.error"
    }

    // MARK: - Server list

    public enum ServerList {
        public static let list = "serverList.list"
        public static let addButton = "serverList.addButton"

        public static func row(_ index: Int) -> String {
            "serverList.row.\(index)"
        }
    }

    // MARK: - User picker

    public enum UserPicker {
        public static let title = "userPicker.title"
        public static let otherUser = "userPicker.otherUser"
        public static let error = "userPicker.error"

        public static func user(_ index: Int) -> String {
            "userPicker.user.\(index)"
        }
    }

    // MARK: - Sign in

    public enum SignIn {
        public static let title = "signIn.title"
        public static let userNameField = "signIn.userNameField"
        public static let passwordField = "signIn.passwordField"
        public static let signInButton = "signIn.signInButton"
        public static let cancelButton = "signIn.cancelButton"
        public static let error = "signIn.error"
    }

    // MARK: - Main

    public enum Main {
        public static let home = "main.home"
        public static let library = "main.library"
        public static let favorites = "main.favorites"
    }

    // MARK: - Sidebar

    public enum Sidebar {
        public static let home = "sidebar.home"
        public static let favorites = "sidebar.favorites"
        public static let noLibraries = "sidebar.noLibraries"

        public static func library(_ index: Int) -> String {
            "sidebar.library.\(index)"
        }
    }

    // MARK: - Home

    public enum Home {
        public static let hero = "home.hero"
        public static let heroTitle = "home.hero.title"
        public static let heroMetadata = "home.hero.metadata"
        public static let heroRating = "home.hero.rating"
        public static let heroOverview = "home.hero.overview"
        public static let heroPrimaryButton = "home.hero.primaryButton"
        public static let heroFavoriteButton = "home.hero.favoriteButton"
    }

    // MARK: - Player

    public enum Player {
        public static let view = "player.view"
        public static let close = "player.close"
    }

    // MARK: - tvOS root

    public enum TVRoot {
        public static let title = "tvRoot.title"
    }
}
