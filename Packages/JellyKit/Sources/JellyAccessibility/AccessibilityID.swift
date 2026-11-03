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

    // MARK: - tvOS root

    public enum TVRoot {
        public static let title = "tvRoot.title"
    }
}
