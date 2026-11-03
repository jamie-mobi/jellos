//
//  ItemPayloadFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum ItemPayloadFixtures {
    static let nextUp = """
    {
      "Items": [
        {
          "Name": "The Harbour",
          "Id": "ep-1",
          "Type": "Episode",
          "Overview": "Storm season.",
          "Genres": ["Drama", "Thriller"],
          "OfficialRating": "TV-14",
          "SeriesName": "Driftwood Bay",
          "SeriesId": "series-1",
          "ParentIndexNumber": 2,
          "IndexNumber": 3,
          "UserData": { "PlaybackPositionTicks": 0, "IsFavorite": false, "Played": false },
          "BackdropImageTags": [],
          "ParentBackdropItemId": "series-1",
          "ParentBackdropImageTags": ["bd-1"],
          "ParentLogoItemId": "series-1",
          "ParentLogoImageTag": "logo-1"
        }
      ]
    }
    """

    static let latest = """
    [
      {
        "Name": "Signal Lost",
        "Id": "movie-1",
        "Type": "Movie",
        "Genres": ["Sci-Fi"],
        "UserData": { "PlaybackPositionTicks": 1200, "IsFavorite": true },
        "BackdropImageTags": ["bd-m"],
        "ImageTags": { "Primary": "p-m", "Logo": "logo-m" }
      },
      { "Name": "No Art", "Id": "movie-2", "Type": "Movie" },
      { "Name": "Broken" }
    ]
    """

    static let episodes = """
    { "Items": [ { "Name": "Pilot", "Id": "ep-first", "Type": "Episode" } ] }
    """

    static let userData = """
    { "IsFavorite": true, "PlaybackPositionTicks": 0 }
    """
}
