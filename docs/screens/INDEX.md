# Screen index: tvOS reference app

Source: the Swiftfin tvOS target in `Swiftfin/`, built from a scratch copy and driven by an
XCUITest robot (`mock/walk/ScreenshotTests.swift`) on a tvOS 27 Apple TV 4K simulator.
Content: the mock server in `mock/` (`python3 -I mock/server.py`), so every title,
person and image is invented. PNGs are 1920x1080 (downscaled from 3840x2160) and are
git-ignored.

Mac translation rules used throughout:
- tvOS focus becomes hover plus keyboard selection.
- The tvOS sidebar tab bar becomes a Mac `NavigationSplitView` sidebar.
- The Menu button becomes Back (Esc, Cmd-[).
- Full-screen modal lists (filters, settings sub-pages) become popovers, menus or Settings tabs.

---

## 01-first-run.png

Page: Empty start. Reached from: first launch, no saved servers.
Layout: app mark at top centre; one line of help text; one Connect button, centred.
Elements: help text, Connect button.
Actions: Connect opens the connect-to-server page.

## 02-connect-to-server.png

Page: Connect to server. Reached from: 01 > Connect.
Layout: two columns. Left: "Connect to server" header, URL text field, Connect button
(disabled while empty). Right: "Local servers" list from UDP discovery, with an empty
state "No local servers found".
Actions: type URL, connect, pick a discovered server.

## 03-connect-to-server-filled.png

Page: Connect to server, URL entered (`http://localhost:8096`). Connect button enabled.
Behaviour: on Connect the app calls `GET /System/Info/Public`, then saves the server.

## 04-server-users.png

Page: User picker for one server, no signed-in users yet. Reached from: 03 > Connect.
Layout: large round "Add user" tile, centred. Bottom bar: settings gear button and a
server picker button (server name with up/down chevron).
Actions: add user, open app settings, switch server.

## 05-user-sign-in.png

Page: Sign in. Reached from: 04 > Add user.
Layout: two columns. Left: "Sign in to <server name>", username field, password field,
Sign in button (disabled while empty). Right: "Public users" grid of round avatars with
names (from `GET /Users/Public`).
Actions: type credentials, sign in, or pick a public user to fill the username.

## 06-user-sign-in-filled.png

Page: Sign in, username "demo" typed, password empty. Sign in is enabled with an empty
password. Calls `POST /Users/AuthenticateByName`.

## 07-home.png

Page: Home. Reached from: sign in success; sidebar > Home.
Layout: floating sidebar at top left (Home, TV Shows, Movies, Search, Media, Settings),
open because focus is on it. Full-screen blurred backdrop of the focused item. First
shelf: Continue Watching, landscape thumbs with remaining-time badge ("1h 38m"),
progress bar, favourite heart, title, and "S2:E1" line for episodes. Next shelf title
"Next Up" below.
Data: `GET /UserItems/Resume`, `GET /Shows/NextUp`, `GET /Items/Latest`.

## 08-home-scrolled.png

Page: Home with focus moved into the sidebar list (Search highlighted). Same shelves.
Shows the sidebar's selected and focused states.

## 09-home-bottom.png

Page: Home, sidebar focus on Settings. Same content. Confirms the sidebar is a vertical
list of six tabs with icons.

## 10-tab-tv-shows.png

Page: TV Shows library. Reached from: sidebar > TV Shows.
Layout: title pill "TV Shows" top left with back chevron; poster grid (2:3) with title
below; corner triangle marks unplayed items; heart badge for favourites. Right edge:
vertical column of filter icons (Audio, Genres, Letter, Rating, Sort, Subtitles, Tags,
Filters, Years, Category).
Data: `GET /Items?includeItemTypes=Series&recursive=true`.

## 11-tab-movies.png

Page: Movies library. Same layout as 10. Badges: check mark for played, heart for
favourite, progress bar under in-progress posters, corner triangle for unplayed.
Focused poster grows and lifts.

## 12-tab-media.png

Page: Media. Reached from: sidebar > Media.
Layout: row of large landscape tiles: Favorites, then one tile per library
(Movies, Shows) from `GET /UserViews`.
Actions: open a library or the Favorites collection.

## 13-tab-settings.png

Page: Settings. Reached from: sidebar > Settings.
Layout: large app mark on the left; list on the right: user row (avatar, name),
Server row (server name), Switch user button (accent), CUSTOMIZE section (Accent
color swatch, Advanced), help text "Some views may need an app restart to update",
Experimental, Logs, Debug.

## 14-movie-detail.png

Page: Movie detail. Reached from: any poster > select.
Layout: full-screen backdrop. Bottom left: logo image, wide Play button showing
runtime ("1h 5m" = remaining time), row of round buttons: mark played (check),
favourite (heart), versions/media info, more (...). Bottom right: tagline (bold),
overview, metadata badges (critic score, community star rating, rating "M", HD, CC),
genre, year, runtime.
Data: `GET /Items/{id}`.

## 15-movie-detail-more.png

Page: Movie detail scrolled one step. Header compresses upwards. Sections: Genres
(pill buttons), Studios (pill buttons).

## 16-movie-detail-bottom.png

Page: Movie detail scrolled to bottom. Sections: Studios, Cast & Crew (portrait cards
with name and role), Recommended (landscape thumbs with progress and badges, header
with chevron = see all).
Data: `GET /Items/{id}/Similar`.

## 17-series-detail.png

Page: Series detail. Same header as 14. Round buttons: played, favourite (filled red),
shuffle, more. Play button shows the next episode's runtime. Season tabs peek at the
bottom.

## 18-series-episodes.png

Page: Series detail scrolled to seasons. Season tab bar (Season 1, Season 2, Season 3,
selected Season 2 as a filled pill). Below: horizontal episode cards (image loading
placeholder in this capture).
Data: `GET /Shows/{id}/Seasons`, `GET /Shows/{id}/Episodes?seasonId=`.

## 19-series-bottom.png

Page: Series detail bottom. Sections: Genres, Studios, Seasons (poster cards with
played check), Cast & Crew.

Numbers 20 and 21 are not used: those captures repeated 40 and 41.

## 22-media-library-movies.png

Page: Movies library opened from Media > Movies. Same as 11, first poster focused
(grown, shadowed).

## 23-player.png

Page: Video player. Reached from: detail > Play.
Layout: black video area; bottom: title, scrubber with elapsed and remaining time,
buttons (aspect fill, more). Centre: error alert "Error / Unable to load this item."
with Close and Retry, because the mock server serves no media bytes.

## 24-settings-demo.png

Page: User settings. Reached from: Settings > user row.
Layout: big avatar on the left; list on the right: Security row. Sub page title "User".

## 25-settings-demo-more.png

Page: User settings, scrolled. No more rows: the page only has Security.

## 26-settings-server.png

Page: Server settings. Reached from: Settings > Server.
Layout: server icon left; SERVER section: Name, Version (12.2.0), Connection
(URL, chevron to edit).

## 27-settings-server-more.png

Page: Server settings scrolled. Same content; confirms nothing below Connection.

## 28-settings-advanced.png

Page: Advanced (customize). Reached from: Settings > Advanced.
Layout: gear icon left; list: TAB BAR Layout (Sidebar picker); FILTERS: Search, Items,
Libraries, Posters, Video player (each a sub page); HOME: Recently added (On),
Recently played (Off), Rewatching in Next Up (Off).

## 29-settings-advanced-more.png

Page: Advanced scrolled, focus on Recently added. Same rows.

## 30-settings-logs.png

Page: Console (network log). Reached from: Settings > Logs.
Layout: left: list of requests (status, size, time, host, method and path, timestamp).
Right: QUICK FILTERS (Errors Only, Network Only, Network Filters), SESSIONS, STORE
(Store Info, Remove Logs in red), SETTINGS.

## 31-settings-logs-more.png

Page: Console scrolled. Shows the requests the app made during the walk
(`/Sessions/Capabilities`, `/MediaSegments/{id}`, `/Items/{id}/PlaybackInfo`,
`/Playback/BitrateTest`, `/Items/{id}`).

## 32-settings-experimental.png

Page: Experimental. Reached from: Settings > Experimental. One toggle: Live TV EPG (Off).

## 33-settings-experimental-more.png

Page: Experimental scrolled. Same single row.

## 34-movies-filter-bar.png

Page: Movies library with the sidebar opened over it (focus moved left). Shows the
sidebar overlaying content, and the filter icon column on the right.

## 35-filter-genres.png

Page: Movies library, focus on first poster after the Genres filter attempt. Genre list
did not open in this capture; layout same as 11.

## 36-filter-sort.png

Page: Sort filter. Reached from: library filter column > Sort.
Layout: big sort icon left; list right with Reset button: ORDER (Ascending, Descending,
check on current); SORT (Name, Random, Sort name, Air time, Date created, Date of last
added content, Date played, Premiere date, ...).

## 37-filter-filters.png

Page: Filters filter. Rows: Unplayed, Played, Favorites, Liked items. Multi-select, Reset.

## 38-filter-letter.png

Page: Letter filter. Rows: #, A to Z. Single select, Reset.

## 39-select-user.png

Page: User picker with one signed-in user. Reached from: Settings > Switch user.
Layout: app mark, round avatar "demo", bottom bar: settings gear, server picker,
add (+) button.

## 40-studio-items.png

Page: Studio items. Reached from: detail > Studios > studio pill.
Layout: sections per item type: Movies (poster row, header chevron to see all), Series.

## 41-studio-items-more.png

Page: Studio items scrolled: Series row, Episodes row (landscape thumbs, title,
"S1:E6" line, played check).

## 42-tab-search.png

Page: Search. Reached from: sidebar > Search.
Layout: title pill "Search"; large search field; inline tvOS keyboard row (123, SPACE,
a-z, delete); filter pill row (Audio, Genres, Letter, Rating, Sort, Subtitles, Tags,
Filters, Years, Category); suggestion list of titles below.
Data: `GET /Items?searchTerm=` and suggestions from `GET /Items` (random sort).

## 43-search-keyboard.png

Page: Search with the numeric keyboard shown ("Press to change keyboards" hint).
Same suggestion list.

---

## Not captured

- Episode detail: the robot could not focus the episode row. Code shows the same layout
  as movie detail (14) plus series name and "S1:E2" line (`Shared/Views/ItemView`).
- Genre filter list (35 missed it), Live TV (off by default, needs the Experimental toggle).
- Quick Connect, PIN, edit server connection, accent color picker.
- Video player overlay with real media (the mock server has no media bytes).

---

## Navigation map

| Sidebar item | Leads to | Mac version |
| --- | --- | --- |
| Home | 07: Continue Watching, Next Up, Latest per library | Sidebar > Home |
| TV Shows | 10: all series, poster grid, filter column | Sidebar > Shows library |
| Movies | 11: all movies, poster grid, filter column | Sidebar > Movies library |
| Search | 42: search field, filters, suggestions | Toolbar search field (Cmd-F) |
| Media | 12: Favorites plus one tile per library | Sidebar section "Libraries" plus Favorites |
| Settings | 13: user, server, switch user, customize, logs | Settings window (Cmd-,) and account menu |

Detail flow: poster > item detail (14) > Genres / Studios (40) / Cast / Recommended.
Series: detail (17) > season tabs (18) > episode > episode detail.
Account flow: first run (01) > connect (02-03) > user picker (04) > sign in (05-06) > Home.
Switch user: Settings > Switch user (39).

## Command map

tvOS has no menu bar. Remote input and the matching Mac commands:

| tvOS input | Action | Mac command |
| --- | --- | --- |
| Arrows | Move focus | Arrow keys, Tab, hover |
| Select | Open / press | Click, Return |
| Menu | Back; at a tab root, open the sidebar | Esc, Cmd-[ |
| Play/Pause | Play focused item | Space (milestone 2) |
| Long press on a poster | Context menu (mark played, favourite) | Right-click menu |
| Sidebar tabs | Switch section | Cmd-1 Home, Cmd-2.. libraries |
| Filter column | Sort, filter, letter jump | Toolbar sort menu and filter menu |
| Settings > Switch user | Back to user picker | Account menu > Switch User (Shift-Cmd-U) |

## Data model guess

- **Server**: Id, ServerName, Version, URLs (`PublicSystemInfo`).
- **User**: Id, Name, PrimaryImageTag, HasPassword, Policy.IsAdministrator (`UserDto`).
- **Session**: AccessToken, User, ServerId (`AuthenticationResult`).
- **Library (view)**: Id, Name, CollectionType (movies, tvshows), image (`BaseItemDto`, Type CollectionFolder).
- **Item**: Id, Name, Type (Movie, Series, Season, Episode), Overview, Taglines,
  ProductionYear, PremiereDate, RunTimeTicks, OfficialRating, CommunityRating,
  CriticRating, Genres/GenreItems, Studios, People, ImageTags (Primary, Thumb, Logo),
  BackdropImageTags, ParentBackdropItemId, SeriesId/SeriesName, SeasonId,
  IndexNumber, ParentIndexNumber, MediaSources/MediaStreams (HD, CC badges).
- **UserData** per item: Played, IsFavorite, PlaybackPositionTicks, PlayedPercentage,
  UnplayedItemCount.
- **Person**: Id, Name, Role, Type (Actor, Director, Writer), PrimaryImageTag.
- **Filters**: sort by (name, date added, premiere date, rating, random...), order,
  played/unplayed/favourites, letter, genres, years.
