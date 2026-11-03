# 07 - Playback Reporting, Watched State, Resume Points

> **Jellyfin SDK source.** A citation `jellyfin-sdk-swift@3.3.0:PATH:LINE` points into [jellyfin/jellyfin-sdk-swift](https://github.com/jellyfin/jellyfin-sdk-swift) at tag `3.3.0` (commit `8ce10a167ad0b4145b2bc005acf8bebcfe6ebe46`). Open it as `https://github.com/jellyfin/jellyfin-sdk-swift/blob/8ce10a167ad0b4145b2bc005acf8bebcfe6ebe46/PATH#LLINE`; for a range `A-B`, use `#LA-LB`. There is no local copy of the SDK.

Scope: how the client tells the server that playback started, progressed and stopped; how watched ("played") state and resume points are read, written and kept in sync. Engine mechanics are in `05-playback.md` and `06-vlc.md` (the app has no VLC; this spec covers AVPlayer, `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift`; Swiftfin also has a second, non-AVPlayer engine that is out of scope, `docs/jellyfin-spec/_work/BRIEF.md:19`, `Shared/Objects/MediaPlayerManager/Players/MPVMediaPlayer.swift`). Endpoint index is `01-endpoints.md`. Transport, headers and auth are in `02-networking.md` and `03-auth-session.md`. Models are in `04-models.md`. Persistence and caches are in `09-state-cache-persistence.md`. Error handling is in `10-errors-edge-cases.md`. Flows are in `11-sequence-flows.md`. Open questions are in `12-gaps.md`. Index: `00-INDEX.md`.

Citation format: `path:line` is repo-relative to the Swiftfin app root. Dependency citations are `jellyfin-sdk-swift@3.3.0:Sources/...:LINE`.

## 1. Summary

- Reporting is engine-agnostic. One `MediaProgressReporter` per `MediaSession` sends all reports for every engine alike (`Shared/Objects/MediaPlayerManager/MediaSession.swift:87`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:209-211`).
- Three HTTP calls carry playback state: `POST /Sessions/Playing` (start), `POST /Sessions/Playing/Progress` (progress), `POST /Sessions/Playing/Stopped` (stop). All three are fire-and-forget. Failures are only logged (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:130-134`).
- Progress is a self-rearming 5 second timer, not event driven. Seek and pause do not trigger an extra report (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:41-47`, `Shared/Objects/PokeIntervalTimer.swift:21`). A track change that needs a stream rebuild does: `selectTracks` calls `mediaSession?.reload(self)`, `reload` calls `resolve`, and `resolve` calls `progressReporter.stop()`, so an extra Stopped and then a new Started are sent (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:91-92`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:105-106`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:734-737`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:321`; section 5.6). A track change that needs no rebuild waits for the next tick.
- The client never writes a resume point, never sends a "played" flag, and never calls mark-played at the end of playback. Nothing in the repo writes resume or watched state at the end of playback, so the design depends on the server doing so from the Stopped report (server behavior, not verifiable here; see section 4.1 and `12-gaps.md`). The client would learn any result via the `UserDataChanged` WebSocket push (see section 8.4, `Shared/Services/UserSession/UserSession+ItemChanges.swift:24-29`). No call to `Paths.markPlayedItem` exists in player code; a grep of `Shared/`, `Objects/` and `Swiftfin tvOS/` finds exactly one call site, `Shared/Services/UserSession/UserSession+Items.swift:86` (line 87 is `Paths.markUnplayedItem`).
- Manual watched toggling uses `POST` / `DELETE /UserPlayedItems/{itemId}`, with optimistic UI and per-item serialized writes (section 8; `Shared/Services/UserSession/UserSession+Items.swift:83-89`, `Shared/Objects/ItemStore/ItemStore.swift:186-204`).

## 2. Endpoints

| # | Method | Path | Request body | Response | Caller |
|---|--------|------|--------------|----------|--------|
| 1 | POST | `/Sessions/Playing` | `PlaybackStateReport` (section 3.1) | `Void`, ignored | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:158-160` |
| 2 | POST | `/Sessions/Playing/Progress` | `PlaybackStateReport` | `Void`, ignored | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:158-160` |
| 3 | POST | `/Sessions/Playing/Stopped` | `PlaybackStopInfo` (section 3.2) | `Void`, ignored | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:67` |
| 4 | POST | `/LiveStreams/Close?liveStreamId=` | none | `Void`, result discarded with `try?` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:95`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:212` |
| 5 | POST | `/UserPlayedItems/{itemId}?userId=` | none | `UserItemDataDto` | `Shared/Services/UserSession/UserSession+Items.swift:86` |
| 6 | DELETE | `/UserPlayedItems/{itemId}?userId=` | none | `UserItemDataDto` | `Shared/Services/UserSession/UserSession+Items.swift:87` |
| 7 | POST | `/UserFavoriteItems/{itemId}?userId=` | none | `UserItemDataDto` | `Shared/Services/UserSession/UserSession+Items.swift:78` |
| 8 | DELETE | `/UserFavoriteItems/{itemId}?userId=` | none | `UserItemDataDto` | `Shared/Services/UserSession/UserSession+Items.swift:79` |
| 9 | GET | `/UserItems/Resume` | none | `BaseItemDtoQueryResult` | `Shared/Objects/Libraries/ResumeItemsLibrary.swift:40`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:399` |
| 10 | GET | `/Shows/NextUp` | none | `BaseItemDtoQueryResult` | `Shared/Objects/Libraries/NextUpLibrary.swift:48`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:384` |

Path strings verified in the SDK: `jellyfin-sdk-swift@3.3.0:Sources/Paths/ReportPlaybackStartAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/ReportPlaybackProgressAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/ReportPlaybackStoppedAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/CloseLiveStreamAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/MarkPlayedItemAPI.swift:15-20`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/MarkUnplayedItemAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/MarkFavoriteItemAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/UnmarkFavoriteItemAPI.swift:15-20`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/GetResumeItemsAPI.swift:15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/GetNextUpAPI.swift:15`.

Transport facts common to rows 1-3:

| Fact | Value | Citation |
|------|-------|----------|
| JSON encoder | `JSONEncoder`, `dateEncodingStrategy = .formatted(OpenISO8601DateFormatter)`, `outputFormatting = .prettyPrinted` | `jellyfin-sdk-swift@3.3.0:Sources/JellyfinClient.swift:49`, `jellyfin-sdk-swift@3.3.0:Sources/JellyfinClient.swift:55-58` |
| Request timeout | `timeoutIntervalForRequest = 20` seconds on the shared `.swiftfin` session configuration | `Shared/Extensions/URLSessionConfiguration.swift:16` |
| Client used | `userSession.client`, read at enqueue time, so a connection change between reports uses the current client | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:116`, `Shared/Services/UserSession/UserSession.swift:32-47` |
| Retry | none | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:130-134` |
| Auth headers | produced by `JellyfinClient` configuration, see `02-networking.md` and `03-auth-session.md` | `Shared/Services/UserSession/UserSession.swift:40-44` |

Request-level overrides: the SDK builds the request with `body: PlaybackStateInfo?` (`jellyfin-sdk-swift@3.3.0:Sources/Paths/ReportPlaybackStartAPI.swift:14-15`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/ReportPlaybackProgressAPI.swift:14-15`); the app replaces `request.body` with its own `PlaybackStateReport` for start and progress (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:158-162`).

## 3. Request bodies

All JSON keys are PascalCase: the SDK encoders write PascalCase string keys (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStateInfo.swift:124-144`, `jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStopInfo.swift:76-86`) and the app's one extra key is `"SecondarySubtitleStreamIndex"` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:148`). The SDK encodes with `encodeIfPresent`, so any nil field is omitted from the body (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStateInfo.swift:122-144`, `jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStopInfo.swift:74-87`).

### 3.1 Start and Progress body (`PlaybackStateReport`)

`PlaybackStateReport` flattens all `PlaybackStateInfo` keys into one object and adds one key the SDK lacks (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:139-156`). The effective body is one JSON object: `encode(to:)` calls `info.encode(to: encoder)` and then writes the extra key into a container of the same encoder (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:151-156`). Start and progress bodies are identical in shape, because one `report(isStart:)` builds both and passes `isStart` only to choose the request (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:70-85`). Only the path differs (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:159`).

| JSON key | Type | Value sent | Source | Citation |
|----------|------|------------|--------|----------|
| `AudioStreamIndex` | Int | `item.selectedAudioStreamIndex` (the configuration choice, may be omitted if nil) | `configuration.audioStreamIndex` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:74`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:14-17` |
| `IsPaused` | Bool | `mediaSession?.playbackRequestStatus == .paused` (false when the session is gone) | the requested transport state, not engine state | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:75` |
| `ItemId` | String | `item.baseItem.id` | resolved item | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:76` |
| `LiveStreamId` | String | `item.mediaSource.liveStreamID` (omitted for non-live) | PlaybackInfo response media source | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:77` |
| `MediaSourceId` | String | `item.mediaSource.id` | PlaybackInfo response media source | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:78` |
| `PlaySessionId` | String | `item.playSessionID` | PlaybackInfo response `PlaySessionId` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:79`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:130-137` |
| `PositionTicks` | Int | `mediaSession?.observedSeconds.ticks` | last position the engine reported | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:80` |
| `SessionId` | String | `item.playSessionID` (same value as `PlaySessionId`) | PlaybackInfo response | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:81` |
| `SubtitleStreamIndex` | Int | `item.selectedSubtitleStreamIndex ?? -1` (`-1` means none) | `configuration.subtitleStreamIndex` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:82`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:23-26` |
| `SecondarySubtitleStreamIndex` | Int | `item.selectedSecondarySubtitleStreamIndex ?? -1`. Not an SDK field. Comment says servers that ignore it still use the primary index | `configuration.secondarySubtitleStreamIndex` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:84`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:139-148`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:32-34` |

Keys the SDK type has but the app never sets (so never sent): `AspectRatio`, `Brightness`, `CanSeek`, `IsMuted`, `Item`, `NowPlayingQueue`, `PlayMethod`, `PlaybackOrder`, `PlaybackStartTimeTicks`, `PlaylistItemId`, `RepeatMode`, `VolumeLevel` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStateInfo.swift:13-49`; the app sets only lines 74-82 of `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift`). The reference app never sends `PlayMethod` (nor `CanSeek`) on start or progress: `report()` assigns no `playMethod` or `canSeek` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:73-82`). The Stopped body has no such field: `PlaybackStopInfo` declares no play method or seek property (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStopInfo.swift:13-31`). The SDK enum values are `Transcode`, `DirectStream`, `DirectPlay` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlayMethod.swift:12-15`); the start report is built from the same `PlaybackStateInfo` as progress (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:70-86`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:158-163`). Its own stream-info panel reads `playState.playMethod` from the server's session info and shows no Method row when it is nil (`Shared/Extensions/JellyfinAPI/SessionInfoDto.swift:21-22`, `Shared/Objects/MediaPlayerManager/Supplements/PlaybackInfoSupplement.swift:85-86`). Whether the server fills that field from reports is not verifiable from this repo; verdict: not blocking for parity with this client, but a rebuild that wants dashboards to show the method should set `PlayMethod` (derived from the resolved media source, see `05-playback.md`) on start and progress.

Reported track indexes are the persistent configuration selection: the reporter reads `selectedAudioStreamIndex`, `selectedSubtitleStreamIndex` and `selectedSecondarySubtitleStreamIndex` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:74`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:82`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:84`), and those getters return `configuration.audioStreamIndex`, `configuration.subtitleStreamIndex` and `configuration.secondarySubtitleStreamIndex` (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:14-34`). Temporary replay captions never change Jellyfin reports (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:60`, compare `effectiveSubtitleStreamIndex` at `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:68-70`, which the reporter does not use).

Example start/progress body (key order not significant):

```json
{
  "AudioStreamIndex": 1,
  "IsPaused": false,
  "ItemId": "<item id>",
  "MediaSourceId": "<media source id>",
  "PlaySessionId": "<play session id>",
  "PositionTicks": 123450000,
  "SessionId": "<play session id>",
  "SubtitleStreamIndex": -1,
  "SecondarySubtitleStreamIndex": -1
}
```

### 3.2 Stop body (`PlaybackStopInfo`)

Plain SDK type. No `SecondarySubtitleStreamIndex`, no track indexes, no `IsPaused` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:59-67`).

| JSON key | Type | Value sent | Citation |
|----------|------|------------|----------|
| `ItemId` | String | `item.baseItem.id` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:60` |
| `LiveStreamId` | String | `item.mediaSource.liveStreamID` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:61` |
| `MediaSourceId` | String | `item.mediaSource.id` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:62` |
| `PlaySessionId` | String | `item.playSessionID` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:63` |
| `PositionTicks` | Int | `mediaSession?.observedSeconds.ticks`, nil (omitted) if the `MediaSession` is already deallocated (`mediaSession` is a `weak var`) | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:24`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:64` |
| `SessionId` | String | `item.playSessionID` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:65` |

Never sent: `Failed` (`isFailed`), `Item`, `NextMediaType`, `NowPlayingQueue`, `PlaylistItemId` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/PlaybackStopInfo.swift:13-31`). Playback errors do not set `Failed`: `stop()` builds the body at `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:59-67` and never assigns `isFailed`. An error after start reaches `core.send(\.error, error)` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:464`), and the `.error` state runs `tearDown()`, which sends a normal Stopped report (`Shared/Objects/MediaPlayerManager/MediaSession.swift:213-218`; see section 5).

### 3.3 Tick conversion

| Rule | Value | Citation |
|------|-------|----------|
| 1 tick | 100 ns; 10,000,000 ticks per second | `Shared/Extensions/Duration.swift:19-21`, `Shared/Extensions/Duration.swift:55-57` |
| Ticks to Duration | `Duration.microseconds(Int64(ticks) / 10)` | `Shared/Extensions/Duration.swift:19-21` |
| Duration to ticks | `Int(microseconds * 10)` | `Shared/Extensions/Duration.swift:55-57` |
| Position floor | `observed = max(0, position)` | `Shared/Objects/MediaPlayerManager/PlaybackState.swift:41-43` |

## 4. Where `PositionTicks` comes from

`observedSeconds` is the last position the engine reported. It is not the displayed position and not a pending seek target (`Shared/Objects/MediaPlayerManager/PlaybackState.swift:33-39`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:688-690`).

| Step | Detail | Citation |
|------|--------|----------|
| Engine pushes position | `MediaSession.playerDidUpdatePosition`, accepted only if `self.player === player`, `playbackItem != nil`, and state is `.preparing` or `.playback` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:595-596` |
| Timeline update | `timeline.observe(position)`, then `publishTimeline()` copies `timeline.observed` to `observedSeconds` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:598-599`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:688-690` |
| AVPlayer | periodic observer, interval `CMTime(seconds: 1, preferredTimescale: 1000)`, only while `isReady`, only if time is numeric | `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:258-269` |
| AVPlayer at end of item | on `AVPlayerItemDidPlayToEndTime` (not live): publishes position = item runtime (else `playerItem.duration`), then calls `mediaSession.ended` | `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:345-358` |
| AVPlayer on ready | one position push after `isReady = true` | `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:458-463` |
| Seek completion | `completeSeek(id, position:)` observes the landed position if the engine gives one | `Shared/Objects/MediaPlayerManager/PlaybackState.swift:62-67` |
| Initial value | on each resolve, `timeline.reset(position: item.baseItem.startSeconds ?? .zero)` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:416` |
| Reset on teardown | `resetPlayback()` sets position back to zero, but the Stopped body reads `observedSeconds` synchronously first | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:64`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:321-328`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:477-482` |

Consequences for a rebuild:

- A seek requested but not yet applied is not reported. `PositionTicks` reads `observedSeconds`, which only `observe(_:)`, `completeSeek(_:position:)` and `PlaybackTimeline.reset(position:)` change (reset runs at resolve and in `resetPlayback`, `Shared/Objects/MediaPlayerManager/PlaybackState.swift:78-81`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:416`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:702`); a pending seek target lives in `pending` and affects only the displayed `seconds` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:80`, `Shared/Objects/MediaPlayerManager/PlaybackState.swift:33-43`, `Shared/Objects/MediaPlayerManager/PlaybackState.swift:62-67`). Stopped carries the last engine-confirmed position.
- When an AVPlayer item plays to the end, the final observed position is the full runtime, so Stopped reports a position at the end (`Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:350-356`).
- Swiftfin also has a second, non-AVPlayer engine and a Chromecast path; both are out of scope, and neither snaps the final position to the runtime (`Shared/Objects/MediaPlayerManager/Players/MPVMediaPlayer.swift:418-421`, `Objects/Chromecast/ChromecastMediaPlayer.swift:411-418`).
- Paused playback still reports progress every 5 s with `IsPaused: true`. `report()` has no paused guard and the timer re-arms itself unconditionally (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:41-47`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:70-86`).

### 4.1 Server thresholds the design relies on (played and resume)

The app never calls mark-played at the end of playback (the only `Paths.markPlayedItem` call site is `Shared/Services/UserSession/UserSession+Items.swift:86`, from a grep of `Shared/`, `Objects/`, `Swiftfin tvOS/`) and never reads `MinResumePct`, `MaxResumePct` or `MinResumeDurationSeconds` (grep of `Shared/`, `Objects/`, `Swiftfin tvOS/` finds none). These are server settings in `ServerConfiguration`: `MaxResumePct` is documented as "the maximum percentage of an item that can be played while still saving playstate. If this percentage is crossed playstate will be reset to the beginning and the item will be marked watched"; `MinResumePct` as the minimum percentage that must be played for playstate to be updated; `MinResumeDurationSeconds` as the minimum item duration eligible for playstate updates (`jellyfin-sdk-swift@3.3.0:Sources/Entities/ServerConfiguration.swift:76-78`, `jellyfin-sdk-swift@3.3.0:Sources/Entities/ServerConfiguration.swift:86-89`). The app therefore relies on the server applying those thresholds to the Stopped `PositionTicks`. Server default values and exact server behavior are not in this repo and are unverified (`12-gaps.md`). A rebuild that cannot guarantee a final position near the runtime must either snap `PositionTicks` to the runtime on natural end, as the AVPlayer path does, or call `POST /UserPlayedItems/{itemId}` itself (section 8.1).

## 5. Lifecycle

### 5.1 Triggers

| Event | Effect on reporting | Citation |
|-------|---------------------|----------|
| Resolve finishes and engine reports ready while state is `.preparing` | `_beginPlayback` runs `reportPlaybackStarted`, which calls `progressReporter.start(playbackItem)` once per item (`hasReportedPlayback` guard) | `Shared/Objects/MediaPlayerManager/MediaSession.swift:564-586` |
| `MediaSession.resolve(...)` begins (new item, queue advance, bitrate or resolution change, transfer to or from remote player, retry, reload) | `progressReporter.stop()` first, so a Stopped report is sent for the previous item; then `discardUnstartedItem()`; `hasReportedPlayback = false` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:302-326`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:717-738` |
| `start()` is called while an item is already set | `start()` calls `stop()` first | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:35-36` |
| Session state becomes `.error` or `.stopped` | `tearDown()` runs `progressReporter.stop()` then `discardUnstartedItem()` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:213-218`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:467-482` |
| `MediaSession` deinit | `progressReporter.stop()` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:222-228` |
| User closes player, confirms close, Close button on the error alert, or tvOS close | `mediaSession.stop()` -> `cancel()` -> `.stopped` -> tearDown | `Shared/Objects/MediaPlayerManager/MediaSession.swift:431-436`, `Shared/Views/VideoPlayer/VideoPlayer.swift:89-92`, `Shared/Views/VideoPlayer/Container/VideoPlayer+Container.swift:922`, `Shared/Views/VideoPlayer/Container/VideoPlayer+Container.swift:1179`, `Shared/Views/VideoPlayer/Components/Toolbar/VideoPlayer+Toolbar.swift:34`, `Swiftfin tvOS/Views/VideoPlayer/PlaybackControls/PlaybackControls.swift:68` |
| Dismissing the player view while Picture in Picture is active or transitioning | `stop()` is NOT called; reporting continues | `Shared/Views/VideoPlayer/Container/VideoPlayer+Container.swift:915-924` |
| `MediaPlayerManager.play(...)` | `stop()` on the previous session before creating the new one | `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:72-77` |
| App terminates (`applicationWillTerminate`) | `MediaPlayerManager.stop()` -> `currentSession.stop()` | `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:52-55`, `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:115-117` |
| Media ends (`ended(from:)`) | guarded by `canControlPlayback`, not seeking, not live (`Shared/Objects/MediaPlayerManager/MediaSession.swift:496`). If no queue or `enableNextEpisodeAutoPlay != true`: `stop()` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:497-500`). If `queue.nextItem` is non-nil: `playNewItem(intent: next)` at once (`Shared/Objects/MediaPlayerManager/MediaSession.swift:502-505`). Otherwise it awaits `queue.next()` in `queueAdvanceTask` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:507-527`): `playNewItem` if a next item exists and autoplay is still on, else `stop()` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:516-520`); if `queue.next()` throws, `fail(error)` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:521-524`). `playNewItem` ends in the same `resolve`, so Stopped(old) then Started(new), see the `resolve` row above (`Shared/Objects/MediaPlayerManager/MediaSession.swift:249-269`) | `Shared/Objects/MediaPlayerManager/MediaSession.swift:495-528`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:249-269` |
| Server `Playstate` `Stop` command | `mediaSession.stop()` | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:119-120` |
| Playback error after start | `fail(error)` -> `core.send(\.error)` -> tearDown -> normal Stopped report (no `Failed`), unless one of the two early-return branches in the next row applies | `Shared/Objects/MediaPlayerManager/MediaSession.swift:444-464`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:213-218` |
| Retry after error | `retry()` (only in state `.error`) -> `resolve(intent)` with `startSeconds = observedSeconds` set in `fail`, then a new Started after ready. `fail` sets that start only when `canControlPlayback` (lines 458-461). Two earlier branches return before it: a pending `handoffRecovery` resolves the recovery intent on the recovery player (lines 447-452), and `canReturnToLocalPlayback` calls `returnToLocalPlayback()` (lines 453-457). In those two branches `fail` neither sets `startSeconds = observedSeconds` nor reaches `core.send(\.error)` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:444-464`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:551-554` |

`enableNextEpisodeAutoPlay` is read from `userSession.user.data.configuration` (server-side user configuration), see `04-models.md` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:497`). An episode queue is auto-created only for `.episode` items (`Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:79-82`).

### 5.2 Sequence

```mermaid
sequenceDiagram
    participant UI as Player UI / engine
    participant S as MediaSession
    participant R as MediaProgressReporter
    participant Q as MediaPlaybackReportQueue
    participant J as Jellyfin server
    participant W as WebSocket

    S->>J: POST Items/{id}/PlaybackInfo (Paths.getPostedPlaybackInfo, Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:78-81; see 05-playback.md) -> PlaySessionId
    UI->>S: playerDidUpdate(isReady) in .preparing
    S->>S: _beginPlayback -> reportPlaybackStarted (once per item)
    S->>R: start(item)
    R->>Q: enqueue(POST /Sessions/Playing)
    Q->>J: POST /Sessions/Playing
    R->>R: timer.poke() (5 s)
    loop every 5 s after previous fire
        R->>R: report() then timer.poke()
        R->>Q: enqueue(progress) only if no progress pending
        Q->>J: POST /Sessions/Playing/Progress
    end
    UI->>S: stop() / error / end / new item / deinit
    S->>R: stop()
    R->>R: timer.stop(), pendingProgressID = nil
    R->>Q: enqueue(POST /Sessions/Playing/Stopped)
    Q->>J: POST /Sessions/Playing/Stopped (PositionTicks = observedSeconds)
    J-->>W: UserDataChanged (server behavior, see 8.4)
    W-->>S: userData merged into ItemStore
```

Diagram citations: ready to `_beginPlayback` to `reportPlaybackStarted` to `progressReporter.start` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:564-586`); `start` sends the start report, subscribes the timer and pokes it (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:35-47`); progress is enqueued only if no progress is pending (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:107-111`); `stop` runs `timer.stop()` and sets `pendingProgressID = nil` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:50-53`), then enqueues Stopped with `PositionTicks = observedSeconds` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:64-67`); all reports run on one queue (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:172-178`); `UserDataChanged` is merged into the store (`Shared/Services/UserSession/UserSession+ItemChanges.swift:24-29`).

### 5.3 Timer, coalescing and ordering

| Rule | Detail | Citation |
|------|--------|----------|
| Interval | `PokeIntervalTimer(defaultInterval = 5)` seconds | `Shared/Objects/PokeIntervalTimer.swift:21`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:26` |
| Self-rearming | `start()` subscribes, then `timer.poke()`. Each fire calls `report()` then `timer.poke()` again. `poke` cancels any pending work item and schedules `DispatchQueue.main.asyncAfter(deadline: .now() + interval)` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:41-47`, `Shared/Objects/PokeIntervalTimer.swift:29-42` |
| First progress | about 5 s after start. Subsequent ones 5 s after the previous fire, not after the previous request completes | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:41-47` |
| Start report | `report(isStart: true)` is called before the timer subscription; `isProgress` is false so it is never coalesced | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:39`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:85` |
| Coalescing | a progress report is dropped if `pendingProgressID != nil` (an earlier progress is queued or in flight). Otherwise a fresh `UUID` is stored | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:107-111` |
| Invalidation | a queued progress closure aborts if `pendingProgressID` no longer equals its ID. `stop()` sets `pendingProgressID = nil`. After sending, a `defer` clears it if still equal | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:50-53`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:118-128` |
| Ordering | one `MediaPlaybackReportQueue` per `MediaPlayerManager`, shared by all sessions. Each enqueued closure awaits the previous task's completion, so Stopped(old) always precedes Started(new) | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:166-179`, `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:31`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:209` |
| Concurrency | `MediaProgressReporter` and the queue are `@MainActor` (reporter line 16, queue line 167); a failed task does not block the chain because errors are caught inside the closure | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:16`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:167`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:130-134` |
| Stop idempotence | `stop()` returns without sending if `item` is nil; sets `item = nil` after capturing. A Stopped is only possible for an item passed to `start()` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:55-57` |
| Not event driven | no progress report on seek, pause, resume, or a track change that needs no rebuild; only the timer sends progress. `IsPaused` and indexes reflect state at the next tick. A track change that needs a rebuild sends Stopped then a new Started through `reload` -> `resolve` -> `progressReporter.stop()` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:41-47`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:105-106`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:321`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:734-737` |
| DEBUG gate | in DEBUG builds, all report enqueues return early when the UserDefaults value `sendProgressReports` is false (default true, `DebugKey`, app suite, DEBUG-only key). Release builds always send | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:100-102`, `Shared/Services/SwiftfinDefaults.swift:455`, `Shared/Views/SettingsView/DebugSettingsView.swift:20-27` |

### 5.4 No Stopped for items that never started

`reporter.item` is set only in `start()` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:38`), and `stop()` returns without sending when `item` is nil (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:55`). `start()` is called only from `reportPlaybackStarted` (`_beginPlayback`); a grep of `Shared/`, `Objects/` and `Swiftfin tvOS/` finds the single call at `Shared/Objects/MediaPlayerManager/MediaSession.swift:586` (function at `Shared/Objects/MediaPlayerManager/MediaSession.swift:580-586`). So if an item was installed but never reached `_beginPlayback`, no Stopped is sent. Instead `discardUnstartedItem()` closes its live stream, if any, via `/LiveStreams/Close` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:707-715`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:88-97`). Closing is wrapped in an unstructured `Task { }.value`, so parent cancellation does not cancel it (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:94-96`).

### 5.5 Position used when playback resumes elsewhere

Bitrate or resolution change, reload, and transfer rebuild the intent from `seconds` (the displayed position, which includes a pending seek target), not `observedSeconds` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:295-300`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:717-738`, `Shared/Objects/MediaPlayerManager/PlaybackState.swift:37-39`). The Stopped for the old stream still carries `observedSeconds`: `resolve` calls `progressReporter.stop()` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:321`) before `resetPlayback()` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:327`), and `stop()` reads `mediaSession?.observedSeconds.ticks` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:64`). Error recovery uses `observedSeconds` (`Shared/Objects/MediaPlayerManager/MediaSession.swift:459-461`).

### 5.6 Server-driven remote control that touches reporting

Commands received over the WebSocket are mapped onto `MediaSession`; reporting then follows normally (`Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:87-128`):

| Playstate command | Effect | Citation |
|-------------------|--------|----------|
| `seek` | `mediaSession.seek(to: .ticks(seekPositionTicks))`; ignored if `seekPositionTicks` is nil | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:114-117` |
| `fastForward` / `rewind` | `seek(by:)` the UserDefaults setting `jumpForwardInterval` / minus `jumpBackwardInterval` | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:92-93`, `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:111-112` |
| `pause` / `unpause` / `playPause` | `setPlaybackRequestStatus(.paused)` / `setPlaybackRequestStatus(.playing)` / `togglePlayPause()`; `IsPaused` reads `playbackRequestStatus` at the next tick | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:100-104`, `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:122-123`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:75` |
| `nextTrack` / `previousTrack` | `playNewItem(intent:)` with `queue?.nextItem` / `queue?.previousItem`, ignored if nil (Stopped then Started via `resolve`) | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:95-98`, `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:106-109` |
| `stop` | `mediaSession.stop()` | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:119-120` |

The `Play` command (`playNow` or no command) hands `startPositionTicks: playCommand.startPositionTicks` to `playItem` (`Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:64-67`), which sets `configuration.startSeconds = startPositionTicks.map { .ticks($0) }` (`Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:204`). A non-nil value overrides the stored resume point. A nil value leaves `startSeconds` nil, so the stored resume point minus the offset is used (section 7.1). `SetAudioStreamIndex` and `SetSubtitleStreamIndex` general commands write `selectedAudioStreamIndex` / `selectedSubtitleStreamIndex` (`Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:135-148`). The setters call `selectTracks`, which ignores an index that is not a known stream (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:14-30`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:81-86`). An accepted index is written to `configuration` (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:98-103`). If the change needs a rebuild, `mediaSession?.reload(self)` runs, which calls `resolve` when the item is current and `canControlPlayback` (Stopped, then a new Started) (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem+Tracks.swift:105-106`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:734-737`). Otherwise the next progress report reads the new value from `configuration` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:74`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:82`). WebSocket details are in `02-networking.md`.

## 6. Live stream release

| Case | Behavior | Citation |
|------|----------|----------|
| PlaybackInfo succeeded but later resolution step throws | every distinct `liveStreamID` in `response.mediaSources` is closed with `POST /LiveStreams/Close?liveStreamId=<id>` | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:177-180`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:204-215` |
| Resolved item arrives after cancel or supersede | `MediaProgressReporter.discard(item, session:)` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:410-413` |
| Item installed but never started | `discardUnstartedItem()` at resolve and tearDown | `Shared/Objects/MediaPlayerManager/MediaSession.swift:322`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:478`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:707-715` |
| Item that did start | released through the Stopped report's `LiveStreamId`, not `/LiveStreams/Close` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:61` |

`discard` does nothing if the item has no `liveStreamID` or the session is nil (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:90`). Errors are swallowed (`try?`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:95`).

## 7. Resume points

### 7.1 Read path

The resume position is `UserItemDataDto.PlaybackPositionTicks` of the item, read by `BaseItemDto.startSeconds` (`Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:305-309`). The app never writes it to the server: a grep of `Shared/`, `Objects/` and `Swiftfin tvOS/` finds no `updateUserItemData` call, and the only `playbackPositionTicks =` writes are the local overlay (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:109`) and a settings preview (`Shared/Views/SettingsView/CustomizeSettings/Components/PosterSection.swift:75`). `UserItemDataDto` JSON keys: `Key`, `ItemId`, `Played`, `PlaybackPositionTicks`, `PlayedPercentage`, `PlayCount`, `LastPlayedDate`, `UnplayedItemCount`, `IsFavorite`, `Likes`, `Rating` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/UserItemDataDto.swift:64-74`). `Key` is the only non-optional field and decoding throws if it is missing (`jellyfin-sdk-swift@3.3.0:Sources/Entities/UserItemDataDto.swift:68`).

| Step | Detail | Citation |
|------|--------|----------|
| Source field | `BaseItemDto.startSeconds = Duration.ticks(userData.playbackPositionTicks)`, nil if absent | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:305-309` |
| User data included | list requests set `enableUserData = true` | `Shared/Objects/Libraries/ResumeItemsLibrary.swift:33`, `Shared/Objects/Libraries/NextUpLibrary.swift:39` |
| Configuration prep | `startSeconds = max(.zero, startSeconds ?? ((item.startSeconds ?? .zero) - resumeOffset))`. An explicit `startSeconds` is used as is, with no offset subtracted | `Shared/Objects/MediaPlayerManager/MediaPlaybackConfiguration.swift:120` |
| Resume offset | UserDefaults user setting `resumeOffset` (key `"resumeOffset"`, Int seconds, default 0), snapshot into `MediaPlaybackConfiguration.resumeOffset` at construction. UI stepper range 0...30 step 1 | `Shared/Services/SwiftfinDefaults.swift:290-292`, `Shared/Objects/MediaPlayerManager/MediaPlaybackConfiguration.swift:36`, `Shared/Views/SettingsView/VideoPlayerSettingsView.swift:211` |
| Local overlay | `MediaPlayerItem.baseItem` writes `userData.playbackPositionTicks = configuration.startSeconds.ticks` into a local copy, so engines read the effective start from `baseItem.startSeconds`. Never sent to the server | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:103-114` |
| AVPlayer | for non-live, `player.seek(to: CMTime(seconds: startSeconds.seconds, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)` | `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:440-447` |
| Not in PlaybackInfo | no `StartTimeTicks` is sent in the PlaybackInfo request body (`PlaybackInfoDto` fields set at `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:56-76`; grep for `startTimeTicks` in `Shared/` finds none) | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:56-76` |
| Session timeline | `timeline.reset(position: item.baseItem.startSeconds ?? .zero)` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:416` |

### 7.2 Overrides

| Case | `startSeconds` | Citation |
|------|----------------|----------|
| Play button | nil, so stored resume minus offset. The provider builds the intent with `getPlaybackIntent(userSession:)`, which passes a fresh `MediaPlaybackConfiguration()`, whose `startSeconds` has no default. `select(_:)` changes only media source, tracks and bitrate. `play()` sets `startSeconds` only when `fromBeginning` | `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:366-377`, `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:267-281`, `Shared/Objects/MediaPlayerManager/PlaybackIntent.swift:30-34`, `Shared/Objects/MediaPlayerManager/MediaPlaybackConfiguration.swift:35`, `Shared/Objects/MediaPlayerManager/MediaPlaybackConfiguration.swift:43`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:324-338`, `Shared/Views/ItemView/Components/PlayButton.swift:31-41` |
| "Play from beginning" (menu only when `playbackPositionTicks > 0`) | `.zero` | `Shared/Views/ItemView/Components/PlayButton.swift:37-39`, `Shared/Views/ItemView/Components/PlayButton.swift:77-82` |
| Episode queue next/previous | `.zero` | `Shared/Objects/MediaPlayerManager/Supplements/EpisodeMediaPlayerQueue.swift:175-180` |
| Shuffle queue | `.zero` | `Shared/Objects/MediaPlayerManager/Supplements/ShuffleMediaPlayerQueue.swift:92-94` |
| Server `Play` command with `startPositionTicks` | `.ticks(startPositionTicks)` | `Shared/Services/UserSession/UserSessionManager+SocketCommands.swift:202-205` |
| Error retry | `observedSeconds` | `Shared/Objects/MediaPlayerManager/MediaSession.swift:459-461` |
| Reload, bitrate, resolution, transfer | `max(.zero, seconds)` via `resumingIntent(at:)` | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItem.swift:191-195` |

### 7.3 Choosing what to resume

| Surface | Request | Citation |
|---------|---------|----------|
| Home "Continue" row | `GET /UserItems/Resume` with `enableUserData=true`, `fields=PosterSubtitleField.itemFields`, `limit=pageSize`, `mediaTypes`, `startIndex=pageOffset`, `userId=<user id>`. Default `mediaTypes = [.video]` | `Shared/Objects/Libraries/ResumeItemsLibrary.swift:20-40`, `Shared/ViewModels/ContentGroupViewModel/DefaultContentGroupProvider.swift:56-61` |
| Home "Next Up" row | `GET /Shows/NextUp` with `enableRewatching` (from the UserDefaults setting `resumeNextUp`), `enableUserData=true`, `fields`, `limit`, `startIndex`, and `nextUpDateCutoff = now - maxNextUp` only when `maxNextUp > 0` (from the UserDefaults setting `maxNextUp`) | `Shared/Objects/Libraries/NextUpLibrary.swift:14-52` |
| Series play button | NextUp for `seriesId`, else first Resume item with `parentId`, else first episode (`GetItems` with `includeItemTypes=[episode]`, `isMissing=false`, `isRecursive=true`, `limit=1`, `parentId`, `sortOrder=[ascending]`) | `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:345-353`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:380-418` |
| Season play button | first Resume item with `parentId` (limit 1), else first episode | `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:355-360`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:394-403` |

`nextUpItem` and `resumeItem` in `ItemContentGroupProvider` do not set `userId`, `enableUserData` or `fields` (`Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:380-403`). Which user the server applies is not verifiable from the app source (see `12-gaps.md`).

Local filter matcher used to keep lists consistent with confirmed user data (`Shared/Extensions/JellyfinAPI/ItemFilter+ItemTrait.swift:60-72`):

| Filter | Predicate |
|--------|-----------|
| `.isResumable` | `isPlayed != true && playbackPositionTicks != 0` |
| `.isPlayed` | `isPlayed != false` |
| `.isUnplayed` | `isPlayed != true` |
| `.isFavorite` | `isFavorite != false` |
| `.likes` / `.dislikes` | `isLikes != false` / `isLikes != true` |

The "Continue" library keeps an element only if `confirmedUserData?.matches([.isResumable]) != false` (`Shared/Objects/Libraries/ResumeItemsLibrary.swift:46-48`). Missing fields cannot disqualify a partial response (`Shared/Extensions/JellyfinAPI/ItemFilter+ItemTrait.swift:59`). Exact predicate (`UserItemDataDto.matches`, `Shared/Extensions/JellyfinAPI/ItemFilter+ItemTrait.swift:66`): an item is shown in Continue unless `isPlayed == true` or `playbackPositionTicks == 0` (nil `isPlayed` and nil `playbackPositionTicks` both pass). `confirmedUserData == nil` also passes (`!= false`). The page contents come from the server's `/UserItems/Resume` response (`Shared/Objects/Libraries/ResumeItemsLibrary.swift:40-43`); `includes` adds no other test, so this predicate only drops elements whose store-confirmed user data has become played or zero-position (`Shared/Objects/Libraries/ResumeItemsLibrary.swift:46-48`).

### 7.4 Progress display

| Display | Rule | Citation |
|---------|------|----------|
| Progress fraction | `playedPercentage / 100` when `playedPercentage > 0`, else nil. Live programs use time-in-program instead | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:384-405` |
| Remaining label | `(runTimeTicks - playbackPositionTicks) / 10_000_000` seconds, formatted hours and minutes abbreviated, when both ticks are non-zero | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:334-358` |
| Play button label | `unaired`, `ended`, `missing`, else `progressLabel`, else `play` | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:598-617` |

## 8. Watched (played) state

### 8.1 Toggle request

| Item | Value | Citation |
|------|-------|----------|
| API | `isPlayed ? Paths.markPlayedItem(itemID:, userID:) : Paths.markUnplayedItem(itemID:, userID:)` | `Shared/Services/UserSession/UserSession+Items.swift:83-89` |
| Mark played | `POST /UserPlayedItems/{itemID}`; query `userId=<self.user.id>`; `datePlayed` is never passed | `Shared/Services/UserSession/UserSession+Items.swift:86`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/MarkPlayedItemAPI.swift:23-28` |
| Mark unplayed | `DELETE /UserPlayedItems/{itemID}`; query `userId` | `Shared/Services/UserSession/UserSession+Items.swift:87`, `jellyfin-sdk-swift@3.3.0:Sources/Paths/MarkUnplayedItemAPI.swift:15-22` |
| Favorites | same pipeline with field `\.isFavorite`; `POST` / `DELETE /UserFavoriteItems/{itemID}?userId=` | `Shared/Services/UserSession/UserSession+Items.swift:75-81` |
| Response handling | decoded `UserItemDataDto` plus the raw JSON object's key set (`Set(object.keys)`) | `Shared/Services/UserSession/UserSession+Items.swift:97-101` |

Callers and targets:

| UI | Target value | Citation |
|----|--------------|----------|
| Poster context menu (shown only if `item.canBePlayed`) | `!isPlayed` | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto+Poster.swift:248-253`, `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto+Poster.swift:265-274` |
| Item view action button (`.played` available iff `canBePlayed`) | `item.userData?.isPlayed != true` | `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:307-314`, `Shared/Views/ItemView/Components/ActionButtons/ItemActionButtons.swift:95-97` |

`canBePlayed` is true for these types only: `.audio`, `.audioBook`, `.book`, `.boxSet`, `.channelFolderItem`, `.collectionFolder`, `.episode`, `.manualPlaylistsFolder`, `.movie`, `.musicAlbum`, `.musicArtist`, `.musicVideo`, `.playlist`, `.playlistsFolder`, `.recording`, `.season`, `.series`, `.trailer`, `.video` (`Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:572-582`). Seasons, series, box sets and folders are toggled with a single call on the container id, because `setPlayed` builds one request with `entry.itemID` (`Shared/Services/UserSession/UserSession+Items.swift:83-89`); how the server cascades to children is not visible in the app (see `12-gaps.md`).

### 8.2 Optimistic update and serialization (`ItemStore.mutateUserData`)

| Rule | Detail | Citation |
|------|--------|----------|
| Precondition | the record must be the live record in the store and have a value, else `StoreError.itemUnavailable` | `Shared/Objects/ItemStore/ItemStore.swift:182-184` |
| Optimistic overlay | `item.beginChange(id:, field:, value:)` immediately overlays the boolean on `ItemRecord.value` (creating `UserItemDataDto(key: id)` if none) | `Shared/Objects/ItemStore/ItemStore.swift:189`, `Shared/Objects/ItemStore/ItemRecord.swift:40-48`, `Shared/Objects/ItemStore/ItemRecord.swift:57-63` |
| Per-item serial queue | each write awaits the previous write's `result`; a failed previous write does not block the next | `Shared/Objects/ItemStore/ItemStore.swift:188`, `Shared/Objects/ItemStore/ItemStore.swift:201-204` |
| Overlay removal | in `defer`, `endChange(id:)` and queue cleanup run on success or failure, so a failed write reverts the badge | `Shared/Objects/ItemStore/ItemStore.swift:191-199` |
| Confirmation | after the response, `data.value.itemID = itemID` (local id wins over any response `ItemId`), then `mergeUserData(data.value, fields: data.fields, token: beginRequest())` with a new revision so reads started during the write cannot overwrite it | `Shared/Objects/ItemStore/ItemStore.swift:213-220` |
| Cancellation | caller cancel propagates via `withTaskCancellationHandler`; `delete(id:)` and `invalidate()` cancel pending tasks | `Shared/Objects/ItemStore/ItemStore.swift:225-229`, `Shared/Objects/ItemStore/ItemStore.swift:242-244`, `Shared/Objects/ItemStore/ItemStore.swift:256-258` |
| Errors | rethrown to the caller. Poster path: `session.itemActionErrors.send(error)`. Item view path: sets `actionError` | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto+Poster.swift:269-273`, `Shared/Views/ItemContentGroupView/ItemContentGroupProvider.swift:307-314` |

### 8.3 Merge rules for `UserItemDataDto`

| Rule | Detail | Citation |
|------|--------|----------|
| Ignore without id | `mergeUserData` returns silently if `data.itemID == nil`; throws `StoreError.invalidItemID` if blank | `Shared/Objects/ItemStore/ItemStore.swift:144-145` |
| Unavailable ids | ignored if `!isAvailable(id:)` | `Shared/Objects/ItemStore/ItemStore.swift:146` |
| Unloaded item | emits `.updated(Update(itemID:, userDataChanged: true))` only, with no retained record | `Shared/Objects/ItemStore/ItemStore.swift:149-152` |
| Loaded item | builds `ItemPatch` with `fields: ["UserData"]` and `userDataFields = fields ?? keys of encoded data`, merges with `revision` | `Shared/Objects/ItemStore/ItemStore.swift:154-162` |
| Revision gating | field-level merge accepts a patch only if its revision is accepted by `FieldRevisions`; for partial scope, absent encoded fields are not cleared, for full-item scope they are replaced | `Shared/Objects/ItemStore/ItemRecord.swift:113-135` |
| Clear | a patch with `UserData` in fields but nil value clears user data if `revision >= latest` | `Shared/Objects/ItemStore/ItemRecord.swift:130-134` |
| Key difference | list and full-item responses can use different `Key` values for the same item; the merge adopts the new key before comparing | `Shared/Objects/ItemStore/ItemRecord.swift:153-157` |
| Change detection | `userDataChanged` is `previousUserData != value.userData`; metadata changes ignore user data | `Shared/Objects/ItemStore/ItemRecord.swift:159-163` |
| Item response paths | `UserSession.send` merges any `BaseItemPatchProvider` response into the store using a fresh request token | `Shared/Services/UserSession/UserSession+Items.swift:41-61` |

### 8.4 How the client learns watched state after playback

The client sends no explicit "played" write when playback ends: the only `Paths.markPlayedItem` call site is `Shared/Services/UserSession/UserSession+Items.swift:86` (grep), and the reporter's stop path builds only a `PlaybackStopInfo` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:50-67`). Observed code path:

1. The Stopped report is sent (section 3.2; `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:67`).
2. The server is expected to compute played and resume state and push `UserDataChanged` over the WebSocket. The server side is not in this repo; see `12-gaps.md`.
3. `UserSession.observeItemChanges()` is started in `willStart()` (`Shared/Services/UserSession/UserSession.swift:72-73`). On `.userDataChangedMessage` it ignores the message unless `data.userID == user.id`, then for each `UserItemDataDto` in `userDataList` calls `items.mergeUserData(data, token: items.beginRequest())` with `try?` (`Shared/Services/UserSession/UserSession+ItemChanges.swift:24-29`).
4. `UserDataChangeInfo` JSON keys: `UserDataList` (required `[UserItemDataDto]`), `UserId` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/UserDataChangeInfo.swift:25-26`). Discriminator string `"UserDataChanged"` (`jellyfin-sdk-swift@3.3.0:Sources/Entities/OutboundWebSocketMessage.swift:83`).
5. Store `.updated(userDataChanged)` events refresh libraries whose filters or sorts depend on user data (`Shared/Objects/PagingLibrary/PagingLibraryViewModel.swift:182-190`). Libraries that opt in: Resume and NextUp always (`Shared/Objects/Libraries/ResumeItemsLibrary.swift:24-26`, `Shared/Objects/Libraries/NextUpLibrary.swift:29-31`); `ItemLibrary` when traits include isFavorite, isPlayed, isUnplayed, isResumable, likes, dislikes, isFavoriteOrLikes, or sort includes datePlayed, playCount, isUnplayed, isPlayed, isFavoriteOrLiked, seriesDatePlayed (`Shared/Objects/Libraries/ItemLibrary.swift:211-223`). The protocol default is false (`Shared/Objects/PagingLibrary/PagingLibrary.swift:119-121`).
6. The same socket also handles `LibraryChanged`: `itemsRemoved` are deleted from the store, `itemsUpdated` for loaded records trigger `getFullItem` (`Shared/Services/UserSession/UserSession+ItemChanges.swift:31-48`).

If the WebSocket is down, no HTTP refetch is triggered after Stopped. Grep of `Shared/`, `Objects/` and `Swiftfin tvOS/` for `reportPlaybackStopped` finds only `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:67`, and the only `getFullItem` calls under `Shared/Objects/MediaPlayerManager/` are the pre-playback resolve fetch (`Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:40`) and the live-program refresh (`Shared/Objects/MediaPlayerManager/NowPlayable/NowPlayableObserver.swift:257`); neither runs after Stopped. Badges and resume rows therefore update on the next library refresh (the absence is verified by grep; the resulting refresh timing is not, see `12-gaps.md`).

### 8.5 Played UI indicators (read side)

| Indicator | Condition | Citation |
|-----------|-----------|----------|
| Unplayed badge | `.unplayed` indicator on, `canBePlayed`, not live, `isPlayed == false`, `playbackPositionTicks ?? 0 == 0`. Count shown when `unplayedStyle == .count` from `userData.unplayedItemCount` | `Shared/Components/PosterIndicators/PosterIndicatorsOverlay.swift:42-48`, `Shared/Components/PosterIndicators/PosterIndicatorsOverlay.swift:96-102` |
| Played checkmark | `.played` indicator on, `canBePlayed`, not live, `isPlayed == true`, not in the Resume row (`.isInResume` view context), `playbackPositionTicks ?? 0 == 0` | `Shared/Components/PosterIndicators/PosterIndicatorsOverlay.swift:59-66` |
| Progress bar | `.progress` indicator on and `progressLabel != nil` | `Shared/Components/PosterIndicators/PosterIndicatorsOverlay.swift:50-53` |
| Resume row context | the home Resume `PosterGroup` sets `_viewContext: .isInResume` on non-tvOS (the `#else` branch of `#if os(tvOS)`; tvOS uses `CinematicSelectionContentGroup` instead) | `Shared/ViewModels/ContentGroupViewModel/DefaultContentGroupProvider.swift:48-62` |
| "Recently played" row | `ItemLibrary` with `itemTypes [.movie, .series]`, `sortBy [.datePlayed]`, `sortOrder [.descending]`, `traits [.isPlayed]`, shown if the UserDefaults setting `showRecentlyPlayed` is on | `Shared/ViewModels/ContentGroupViewModel/DefaultContentGroupProvider.swift:87-99` |

## 9. Local state

| State | Where | Lifetime | Citation |
|-------|-------|----------|----------|
| `item` (current reported `MediaPlayerItem`) | `MediaProgressReporter`, memory | `start()` to `stop()` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:22` |
| `pendingProgressID` | `MediaProgressReporter`, memory | enqueue until sent or `stop()` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:25` |
| `timer` | `MediaProgressReporter` | per reporter (per session) | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:26` |
| `MediaPlaybackReportQueue.task` | `MediaPlayerManager.reportQueue` | manager lifetime, shared by sessions | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:170`, `Shared/Objects/MediaPlayerManager/MediaPlayerManager.swift:31` |
| `hasReportedPlayback` | `MediaSession` (`@ObservationIgnored`) | reset on resolve and tearDown | `Shared/Objects/MediaPlayerManager/MediaSession.swift:122-123` |
| `observedSeconds` / `timeline.observed` | `MediaSession`, memory | reset on resolve to item start | `Shared/Objects/MediaPlayerManager/MediaSession.swift:120`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:416` |
| `playbackRequestStatus` | `MediaSession`, default `.playing`; set by `setPlaybackRequestStatus` / `togglePlayPause` (user, remote command), by native controls via `playerDidRequestPlayback`, and to `.paused` on a failed transfer; background pause is in `MediaPlaybackTransitions` | session | `Shared/Objects/MediaPlayerManager/MediaSession.swift:84`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:394`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:530-549`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:558-562`, `Shared/Objects/MediaPlayerManager/MediaPlaybackTransitions.swift:30-41` |
| `sendProgressReports` | UserDefaults app suite, key `"sendProgressReports"`, DEBUG only | persistent | `Shared/Services/SwiftfinDefaults.swift:455` |
| `resumeOffset` | UserDefaults via `UserKey("resumeOffset", default: 0)` | persistent | `Shared/Services/SwiftfinDefaults.swift:290-292` |
| `optimisticChanges` | `ItemRecord`, memory | each entry until its write ends (`endChange`); all removed on invalidate | `Shared/Objects/ItemStore/ItemRecord.swift:24`, `Shared/Objects/ItemStore/ItemRecord.swift:65-67`, `Shared/Objects/ItemStore/ItemRecord.swift:178` |
| `userDataRevisions` (`FieldRevisions`) | `ItemRecord`, memory | whole record lifetime; updated by every merge; reset only by `invalidate()` | `Shared/Objects/ItemStore/ItemRecord.swift:29`, `Shared/Objects/ItemStore/ItemRecord.swift:113-148`, `Shared/Objects/ItemStore/ItemRecord.swift:176` |
| `mutations` per item | `ItemStore`, memory | until write ends; cancelled on delete or invalidate | `Shared/Objects/ItemStore/ItemStore.swift:223`, `Shared/Objects/ItemStore/ItemStore.swift:238-270` |

Nothing about reporting is persisted to disk: all reporter state is in-memory properties (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:19-28`) and the queue holds only an in-memory `task` (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:170`); the DEBUG `sendProgressReports` toggle is the only persisted value, and it is a setting, not report data. No offline queue exists: a report that fails is lost (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:130-134`). See `09-state-cache-persistence.md`.

## 10. Errors

| Condition | Handling | User-visible | Citation |
|-----------|----------|--------------|----------|
| Start, progress or stopped request fails | `logger.warning("Unable to report playback: <localizedDescription>")`; queue continues | none | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:130-134` |
| `closeLiveStream` fails | swallowed with `try?` | none | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:95`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:212` |
| PlaybackInfo response lacks `PlaySessionId` | throws `ErrorMessage("No associated play session ID")` before any report; open live streams are closed | playback error | `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:130-132`, `Shared/Objects/MediaPlayerManager/MediaPlayerItem/MediaPlayerItemResolver.swift:177-180` |
| Played or favorite write fails | overlay reverted; error sent to `itemActionErrors` or `actionError` | badge reverts, views observing those show the error | `Shared/Objects/ItemStore/ItemStore.swift:191-199`, `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto+Poster.swift:269-273` |
| Item deleted or store invalidated during write | `StoreError.itemUnavailable` / task cancelled | write result discarded | `Shared/Objects/ItemStore/ItemStore.swift:206-212`, `Shared/Objects/ItemStore/ItemStore.swift:242-258` |
| Response lacks `ItemId` | local id is assigned before merge | none | `Shared/Objects/ItemStore/ItemStore.swift:213` |
| WebSocket `UserDataChanged` with blank `ItemId` | `mergeUserData` throws, swallowed by `try?` | none | `Shared/Objects/ItemStore/ItemStore.swift:145`, `Shared/Services/UserSession/UserSession+ItemChanges.swift:28` |

Cross-reference `10-errors-edge-cases.md`.

## 11. Constants

| Name | Value | Citation |
|------|-------|----------|
| Progress interval | 5 seconds | `Shared/Objects/PokeIntervalTimer.swift:21` |
| Ticks per second | 10,000,000 | `Shared/Extensions/Duration.swift:19-21`, `Shared/Extensions/Duration.swift:55-57` |
| "No subtitle" index | `-1` (primary and secondary) | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:82-84` |
| Extra JSON key | `"SecondarySubtitleStreamIndex"` | `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:148` |
| AVPlayer position observer | 1 second | `Shared/Objects/MediaPlayerManager/Players/AVMediaPlayer.swift:259` |
| Seek coalesce delay / timeout | 80 ms / 8 s | `Shared/Objects/MediaPlayerManager/MediaSession.swift:634`, `Shared/Objects/MediaPlayerManager/MediaSession.swift:647` |
| HTTP request timeout | 20 s | `Shared/Extensions/URLSessionConfiguration.swift:16` |
| Resume offset | default 0 s, range 0...30 s | `Shared/Services/SwiftfinDefaults.swift:290-292`, `Shared/Views/SettingsView/VideoPlayerSettingsView.swift:211` |
| Progress percentage divisor | `playedPercentage / 100` | `Shared/Extensions/JellyfinAPI/BaseItemDto/BaseItemDto.swift:404` |

## 12. Explorer notes and conflicts

- No conflict remains on reporting behavior. Every claim in this file was re-checked against source (cited inline). The explorer outputs (`_work/explorers/topic-reporting.json`, `shard-player-manager-1.json`, `topic-endpoints.json`, `topic-errors.json`, `topic-images-subtitles-audio.json`) were the starting point only; the cited source lines are the authority.
- Citation drift only: `_work/explorers/topic-endpoints.json` and its `constants[0]` cite the 5 s default at `Shared/Objects/PokeIntervalTimer.swift:19`, but the default `= 5` is on line 21 (`init(defaultInterval: TimeInterval = 5)`). The source settles it: line 21 (`Shared/Objects/PokeIntervalTimer.swift:21`).
- `_work/explorers/topic-reporting.json` cites `MediaProgressReporter.swift:131` as a call site for the start/progress path; the actual `client.send(request)` is line 131 inside the enqueue closure (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:131`) and request construction is at line 159. Both are consistent.
- `_work/explorers/topic-reporting.json` says Stopped is sent "even if the start was never reported only if reporter.item was set"; the code sets `item` only in `start()`, so Stopped is never sent for an item that never started (`Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:38`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:55`).

## 13. Rebuild checklist

Each item restates the cited sections above (citations are in those sections).

1. After PlaybackInfo, keep `PlaySessionId`, the selected `MediaSource` (`Id`, `LiveStreamId`) and the chosen audio/subtitle indexes (section 3.1).
2. When the engine is ready, send one `POST /Sessions/Playing` with the section 3.1 body.
3. Every 5 s thereafter send `POST /Sessions/Playing/Progress`, skipping a tick while the previous progress report is queued or in flight (`pendingProgressID` clears in the `defer` after `client.send` finishes, only if the ID still matches, and also in `stop()`; `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:53`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:107-111`, `Shared/Objects/MediaPlayerManager/MediaProgressReporter.swift:124-131`). Do not send extra reports on seek or pause.
4. Send `PositionTicks` as `seconds * 10_000_000`, from the last engine-observed position.
5. On stop, error, end, new item or app termination, send `POST /Sessions/Playing/Stopped` with section 3.2. Serialize all reports on one chain so Stopped(old) precedes Started(new).
6. Do not send Stopped for an item that never started; close its live stream with `POST /LiveStreams/Close?liveStreamId=`.
7. Read resume from `UserData.PlaybackPositionTicks`, subtract the user's resume offset, clamp at zero.
8. Manual watched toggle: `POST` or `DELETE /UserPlayedItems/{id}?userId=`, apply optimistically, serialize per item, merge the response, revert on failure.
9. Listen for `UserDataChanged` on the WebSocket and merge each entry for the current user id.
