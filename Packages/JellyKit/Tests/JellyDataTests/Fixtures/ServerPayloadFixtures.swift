//
//  ServerPayloadFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum ServerPayloadFixtures {
    static let publicSystemInfo = """
    {
      "LocalAddress": "http://192.168.1.10:8096",
      "ServerName": "Living Room",
      "Version": "10.11.0",
      "ProductName": "Jellyfin Server",
      "Id": "f1a2b3c4d5",
      "StartupWizardCompleted": true
    }
    """

    static let publicSystemInfoWithoutName = """
    {
      "Version": "10.11.0",
      "Id": "f1a2b3c4d5"
    }
    """
}
