# 13 - jellyOS v1 Decisions

> **Jellyfin SDK source.** A citation `jellyfin-sdk-swift@3.3.0:PATH:LINE` points into [jellyfin/jellyfin-sdk-swift](https://github.com/jellyfin/jellyfin-sdk-swift) at tag `3.3.0` (commit `8ce10a167ad0b4145b2bc005acf8bebcfe6ebe46`). Open it as `https://github.com/jellyfin/jellyfin-sdk-swift/blob/8ce10a167ad0b4145b2bc005acf8bebcfe6ebe46/PATH#LLINE`; for a range `A-B`, use `#LA-LB`. There is no local copy of the SDK.

Part of the Swiftfin Jellyfin spec. Index: [00-INDEX.md](00-INDEX.md).

Files 00 to 12 describe what Swiftfin does. This file records what the **jellyOS** client (the new Apple-only client in this repo) does differently or has chosen. These are design decisions, not claims about the Swiftfin code. Where a row describes Swiftfin, it cites the code. Dependency and server facts come from the sources named in each row.

Decisions were made on 2026-11-03.

## 1. Scope

| Decision | Detail |
|---|---|
| Platforms | Apple only (iOS, iPadOS, tvOS). |
| Player | AVPlayer only for v1; no other player engine. Read only the AVPlayer parts of [06-vlc.md](06-vlc.md). |
| Chromecast | Not in v1. |
| Dead code | Ignored. Items marked dead in [12-gaps.md](12-gaps.md) section 3 are not rebuilt. |
| Why AVPlayer | PiP, AirPlay, Siri Remote and Now Playing come built in. The server transcodes what AVPlayer cannot play. |

## 2. Server facts these decisions rely on

| Fact | Source |
|---|---|
| The server is Jellyfin API 12.2.0 (spec file `docs/openapi.json`). | `docs/openapi.json` `info.version` |
| The server host is an Intel N150 with QuickSync. It decodes AV1 in hardware and encodes HEVC (10-bit too). It cannot encode AV1. | Reported by the user, 2026-11-03. |
| "Allow encoding in HEVC format" is on. Active Sessions shows HEVC as the transcode codec. | Reported by the user, 2026-11-03. |
| No Apple TV has AV1 hardware decode. | Apple platform fact, not shown by any file here. |

## 3. Playback decisions

| # | Decision | Swiftfin behaviour it replaces | Cite for the Swiftfin behaviour |
|---|---|---|---|
| 3.1 | Send `TranscodingProfile` with `Protocol=hls`, `Container=mp4` (fMP4 segments) and `VideoCodec = "hevc,h264"`. Do not list AV1 for Apple TV. | Swiftfin's AVPlayer profile has separate H.264, HEVC and AV1 `CodecProfile` entries. | `Shared/Objects/MediaPlayerType/MediaPlayerType+AVPlayer.swift:180-265` |
| 3.2 | Copy Swiftfin's HDR list as it is. It allows `DOVIWithEL`, `HDR10`, `HDR10Plus`, `HLG` and the `DOVIWith*` types when the device supports HEVC, and `DOVI` only when the device decodes Dolby Vision. | The same list. | `Shared/Objects/MediaPlayerType/MediaPlayerType+AVPlayer.swift:267-297` |
| 3.3 | Dolby Vision Profile 7 files (`DOVIWithEL`) play as HDR10. No `dovi_tool` conversion. | The same list lets the server drop the Dolby Vision layer. | `Shared/Objects/MediaPlayerType/MediaPlayerType+AVPlayer.swift:287-292` |
| 3.4 | Require the HEVC codec tag `hvc1` or `dvh1`, and a frame rate of 60 or less. | The same conditions. | `Shared/Objects/MediaPlayerType/MediaPlayerType+AVPlayer.swift:220-234` |
| 3.5 | Subtitles: `Hls` (WebVTT) for text subtitles. `Encode` (burn-in) for PGS and ASS. | Not decided here by Swiftfin; see [08-images-subtitles-audio.md](08-images-subtitles-audio.md). | - |
| 3.6 | Read `PlaybackInfoResponse.ErrorCode`. If it is set, stop and show a clear error. | Swiftfin never reads `ErrorCode`, `SupportsDirectPlay` or `SupportsDirectStream`. Its only branch is whether `TranscodingUrl` is nil. | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:94-132,229-260`; `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:146` |
| 3.7 | Send `StartTimeTicks` in `PlaybackInfo` when you resume. Shift the player time by the start offset. | Swiftfin never sets `StartTimeTicks`. | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:56-76` |

## 4. Auth, session and reporting decisions

| # | Decision | Swiftfin behaviour it replaces | Cite for the Swiftfin behaviour |
|---|---|---|---|
| 4.1 | At sign-out, call `POST /Sessions/Logout`. On any 401, delete the local login and show the login screen. | Sign-out clears local state only. There is no global 401 handler; the HTTP delegate only validates the status. | `Shared/Services/UserSession/UserSessionManager.swift:113-124`; `jellyfin-sdk-swift@3.3.0:Sources/PassthroughAPIClientDelegate.swift:29-37` |
| 4.2 | Send `Stopped` when playback stops and when the app goes to the background. Use a background task so the request can finish. | Swiftfin runs `stop()` on `applicationWillTerminate`, but it only enqueues an async `Task`, so the request may not finish. | `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:52-55`; `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:55-68` |
| 4.3 | No app lock (PIN or Face ID) at launch in v1. | Swiftfin does the same at launch. It checks the access policy only on the deep-link path. | `Shared/Services/UserSession/UserSessionManager.swift:150` |
| 4.4 | Choose default audio and subtitle tracks with Apple `AVMediaSelection` and the device language settings. | Swiftfin uses a third-party accessibility library for this, which this spec does not cover. | `Shared/Objects/MediaPlayerManager/MediaPlaybackPreferences.swift:84-108` |

## 5. Now Playing decisions

| # | Decision | Swiftfin behaviour | Cite for the Swiftfin behaviour |
|---|---|---|---|
| 5.1 | Build the metadata with Swiftfin's rules: for live TV use `CurrentProgram` for the title and `ChannelName` for the artist; for an episode use `SeriesName` with the season and episode label; for audio use the artists, `AlbumArtist` and `Album`. Treat an item as audio when `MediaType` is `Audio`, or when `ChannelType` is `Radio`. All of these fields exist in `BaseItemDto`. | `BaseItemDto.nowPlayableStaticMetadata`. | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:44-78`; field names in `docs/openapi.json` `components.schemas.BaseItemDto` |
| 5.2 | Use `MPNowPlayingSession` with `AVPlayerItem.externalMetadata`. Update the full info only when the item changes. On play, pause, seek or rate change, update only the elapsed time and the rate. Do not update on each time tick. Update remote commands when the queue changes. Set `nowPlayingInfo = nil` when playback stops. | Swiftfin writes `MPNowPlayingInfoCenter` itself, and refreshes on `observedSeconds`. | `Shared/Objects/MediaPlayerManager/NowPlayable/NowPlayableObserver.swift:76,146-168,170-225` |
| 5.3 | Put publishing behind one protocol (for example `NowPlayingPublisher`) so a second engine can be added later. | Swiftfin uses `MediaPlayerMetadataProviding` for the engine part. | `Shared/Objects/MediaPlayerManager/NowPlayable/NowPlayableObserver.swift:223` |

## 6. Networking and platform decisions

| # | Decision | Swiftfin behaviour | Cite for the Swiftfin behaviour |
|---|---|---|---|
| 6.1 | Use the `TranscodingUrl` exactly as the server returns it. Do not append a token. Never write these URLs to logs, because they contain a token. | Swiftfin appends no token to the `TranscodingUrl`. For static streams it adds `ApiKey` with `queryAPIKey: true`. | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:229-237,256,274` |
| 6.2 | Do not add a token to image requests. | Swiftfin adds none. | `Shared/Extensions/Nuke/ImagePipeline.swift:70-77` |
| 6.3 | Info.plist: set `NSAllowsLocalNetworking = true` (plain `http://` works for the local network only) and an `NSLocalNetworkUsageDescription` text for server discovery. | The tvOS plist sets `NSAllowsArbitraryLoads = true`. The iOS plist is not in the checkout. Discovery uses a UDP broadcast to `255.255.255.255:7359`. | `Swiftfin tvOS/Resources/Info.plist:43-47`; `jellyfin-sdk-swift@3.3.0:Sources/ServerDiscovery.swift:41-43` |
| 6.4 | Do not copy these Swiftfin oddities: the `"YYYY"` date format, the season ID sent as the series ID, and the two shapes of the `Authorization` header. | See [12-gaps.md](12-gaps.md) section 5, items 7, 4 and 10. | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:466-473`; `Shared/Objects/Libraries/EpisodeLibrary.swift:35,38-41` |

## 7. Server tests run on 2026-11-03

The user ran these with `curl` against `https://media.jamie.mobi`, with the movie ID `86ce22866b3248aecbfba3562a036d0e`. The agent that wrote this file did not run them, so the results are as the user reported them.

| Test | Result | Meaning |
|---|---|---|
| `GET /Items/{id}/Images/Primary?maxWidth=300` with no token | HTTP 200 | The server sends images with no token (decision 6.2). This answers question 5 in [12-gaps.md](12-gaps.md) for this server. |
| `POST /Items/{id}/PlaybackInfo?userId=...` with the profile in section 8, signed with an **API key** | `ErrorCode` empty. `SupportsDirectPlay` false, `SupportsDirectStream` false, `SupportsTranscoding` true. | The MKV file needs a transcode. |
| The same reply, `TranscodingUrl` | Path `/videos/{id}/master.m3u8`. It contains `ApiKey=`, `SegmentContainer=mp4`, `VideoCodec=hevc,h264`, `hevc-profile=main10`, `TranscodeReasons=ContainerNotSupported,AudioCodecNotSupported`. | The server puts the token in the URL. This answers question 1 in [12-gaps.md](12-gaps.md) for the main playlist. |

**Not tested yet:**

1. A user access token (the test used an API key). The same behaviour is expected, but it is not shown.
2. The subtitle `DeliveryUrl`.
3. Whether the child playlists and segments inside `master.m3u8` also carry the key.

## 8. The test `DeviceProfile`

This is the profile the test sent. It is a test profile, not the v1 profile. The v1 profile starts from decisions 3.1 to 3.5.

```json
{"DeviceProfile":{"MaxStreamingBitrate":120000000,
 "DirectPlayProfiles":[{"Container":"mp4,m4v,mov","Type":"Video","VideoCodec":"h264,hevc","AudioCodec":"aac,ac3,eac3,flac"}],
 "TranscodingProfiles":[{"Container":"mp4","Type":"Video","VideoCodec":"hevc,h264","AudioCodec":"aac,ac3,eac3","Protocol":"hls","Context":"Streaming","MaxAudioChannels":"6","MinSegments":2,"BreakOnNonKeyFrames":true}],
 "SubtitleProfiles":[{"Format":"vtt","Method":"Hls"},{"Format":"srt","Method":"External"}]}}
```

## 9. Open questions that remain for jellyOS

1. Does a user access token get the same `ApiKey=` in `TranscodingUrl`? Test with a login through `POST /Users/AuthenticateByName`.
2. Do the child playlists and segments carry the key? Fetch `master.m3u8` and read it.
3. Does the subtitle `DeliveryUrl` carry a key? Not needed if v1 uses only `Hls` subtitles.
4. Does Dolby Vision Profile 5 and 8 play as Dolby Vision on the target devices? Test on a real Apple TV.

## Cross-links

[00-INDEX.md](00-INDEX.md), [05-playback.md](05-playback.md), [06-vlc.md](06-vlc.md), [07-reporting.md](07-reporting.md), [08-images-subtitles-audio.md](08-images-subtitles-audio.md), [12-gaps.md](12-gaps.md).
