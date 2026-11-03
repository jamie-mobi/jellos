//
//  LibraryPayloadFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum LibraryPayloadFixtures {
    static let userViews = """
    {
      "Items": [
        { "Name": "Movies", "Id": "lib-movies", "CollectionType": "movies", "Type": "CollectionFolder" },
        { "Name": "Shows", "Id": "lib-shows", "CollectionType": "tvshows", "Type": "CollectionFolder" },
        { "Name": "Broken" }
      ],
      "TotalRecordCount": 3
    }
    """
}
