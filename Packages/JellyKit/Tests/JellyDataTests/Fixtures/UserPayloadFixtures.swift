//
//  UserPayloadFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum UserPayloadFixtures {
    static let publicUsers = """
    [
      { "Name": "Alice", "Id": "user-a", "HasPassword": true, "PrimaryImageTag": "tag-a", "ServerId": "s" },
      { "Name": "Bob", "Id": "user-b", "HasPassword": false, "ServerId": "s" }
    ]
    """

    static let authenticationResult = """
    {
      "User": { "Name": "Alice", "Id": "user-a", "HasPassword": true, "PrimaryImageTag": "tag-a" },
      "AccessToken": "token-123",
      "ServerId": "s"
    }
    """

    static let authenticationResultWithoutToken = """
    {
      "User": { "Name": "Alice", "Id": "user-a" },
      "ServerId": "s"
    }
    """
}
