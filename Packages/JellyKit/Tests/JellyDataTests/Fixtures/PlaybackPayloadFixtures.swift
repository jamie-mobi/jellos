//
//  PlaybackPayloadFixtures.swift
//  jellyOS
//
//  Created by Jamie Le Souef on 03/11/2026.
//

enum PlaybackPayloadFixtures {
    static let transcode = """
    {
      "MediaSources": [
        {
          "Id": "source-1",
          "Container": "mkv",
          "SupportsDirectPlay": false,
          "SupportsDirectStream": false,
          "TranscodingUrl": "/videos/item-1/master.m3u8?DeviceId=d&MediaSourceId=source-1&VideoCodec=hevc,h264&ApiKey=token-123"
        }
      ],
      "PlaySessionId": "play-1"
    }
    """

    static let directStream = """
    {
      "MediaSources": [
        { "Id": "source-1", "Container": "mp4", "SupportsDirectPlay": true, "SupportsDirectStream": true }
      ],
      "PlaySessionId": "play-2"
    }
    """

    static let refused = """
    { "MediaSources": [], "ErrorCode": "NotAllowed" }
    """

    static let noSources = """
    { "MediaSources": [], "PlaySessionId": "play-3" }
    """
}
