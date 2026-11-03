# JellyOS stories

A native Mac client for a Jellyfin server, built from the tvOS reference app
(`docs/screens/INDEX.md`). API contract: `docs/openapi.json` (Jellyfin 12.2.0).
Mock content: `mock/` (fixtures, mock server, `python3 -I mock/server.py`).

Milestones:
- **M1 Browse**: connect, sign in, browse Home and libraries, open details, mark played and favourite.
- **M2 Watch**: play video, resume, report progress, audio and subtitle tracks.
- **M3 Find**: search, filters, letter jump, genres, studios, people.
- **M4 Accounts and settings**: several servers and users, settings window, customisation.
- **M5 Polish**: context menus, keyboard everywhere, empty and error states, icon.

---

## M1 Browse

### S-001 Connect to a server by URL
As the user, I type my server's address and press Connect to add it.
Screens: 01-first-run.png, 02-connect-to-server.png, 03-connect-to-server-filled.png
Acceptance:
- [unit] " demo.local:8096/ " becomes `http://demo.local:8096`; an address with no host shows "That address is not valid."
- [unit] Connect calls `GET /System/Info/Public` and keeps `ServerName`, `Id`, `Version`.
- [snap] Connect page: address field, Connect button (disabled while empty), "Try Demo Content" button.
- [self] A server that does not answer shows an inline error under the field within 20 seconds.
- [manual] The added server is still there after the app quits and opens again.
UX:
- Flow: first launch or File > Add Server… (Shift-Command-N) -> Address field has focus -> Return or Connect -> spinner in the button -> user picker
- Surface: full-window page on first run (nothing else to show); sheet from File > Add Server… later (one short task)
- States: empty field disables Connect; error under the field "Unable to connect to this address. Check it and try again."; loading "Connecting…" in the button, Escape cancels
- Words: title "Connect to a Server", field label "Address", placeholder "http://192.168.1.10:8096", buttons "Connect", "Try Demo Content"
- Access: Return connects, Escape cancels the request; VoiceOver "Server address"
Status: done

### S-002 Try the app with demo content
As the user, I click "Try Demo Content" to browse without a server.
Screens: 01-first-run.png
Depends: S-001
Acceptance:
- [unit] Demo mode loads `library.json` from the app bundle: 12 movies, 3 series, 2 users.
- [snap] After choosing demo content, the user picker shows "demo" and "guest".
- [self] Demo mode makes no network requests.
UX:
- Flow: Connect page > Try Demo Content -> user picker for "Demo Content"
- Surface: button on the Connect page (no extra step)
- States: none can fail; the server name shows "Demo Content" everywhere a server name shows
- Words: "Try Demo Content", help "Browse sample movies and series without a server"
- Access: reachable with Tab from the Address field
Status: done

### S-003 Sign in as a user
As the user, I pick my avatar, type my password (or leave it empty), and sign in.
Screens: 04-server-users.png, 05-user-sign-in.png, 06-user-sign-in-filled.png, 39-select-user.png
Depends: S-001
Acceptance:
- [snap] User picker: grid of round avatars with names from `GET /Users/Public`, plus "Other User…" for hidden accounts.
- [snap] Password sheet with the user's avatar, password field, Sign In button.
- [unit] Sign in sends `POST /Users/AuthenticateByName` with `Username` and `Pw` and the `Authorization: MediaBrowser ...` header.
- [unit] The access token is stored in the Keychain, never in UserDefaults.
- [self] A wrong password shows "The user name or password is not right." in the sheet.
- [manual] After a restart the app opens straight into Home for the last user.
UX:
- Flow: user picker -> click avatar or Return on the selected avatar -> password sheet (field has focus) -> Return signs in -> Home
- Surface: page for the picker (people come back to it); sheet for the password (short task that must finish or cancel)
- States: no public users shows only "Other User…"; error in the sheet "The user name or password is not right."; loading "Signing In…"
- Words: title "Who's Watching?", tiles show user names, "Other User…", sheet title "Sign In to <server>", fields "User Name", "Password", buttons "Sign In", "Cancel"
- Access: arrow keys move between avatars; Escape closes the sheet; VoiceOver reads "<name>, user"
Status: done

### S-004 Move between Home and libraries in the sidebar
As the user, I click Home, a library, or Favorites in the sidebar to show it.
Screens: 07-home.png, 08-home-scrolled.png, 12-tab-media.png
Depends: S-003
Acceptance:
- [snap] Sidebar: Home, then a "Libraries" section with one row per `GET /UserViews` entry (icon by collection type), then Favorites.
- [self] Command-1 shows Home; Command-2 and on show libraries in sidebar order.
- [manual] The selected sidebar row is remembered across restarts.
UX:
- Flow: click a sidebar row, or Command-1 (Home), Command-2… (libraries in order) -> page shows in the detail area
- Surface: sidebar pages (places people come back to)
- States: no libraries shows "This server has no libraries." under the Libraries heading
- Words: "Home", section "Libraries", library names from the server, "Favorites"
- Access: sidebar rows are keyboard focusable; View menu lists the same commands with shortcuts
Status: doing

### S-005 Continue watching from Home
As the user, I see what I was watching, what is next, and what is new, on one page.
Screens: 07-home.png, 08-home-scrolled.png, 09-home-bottom.png
Depends: S-004
Acceptance:
- [snap] A hero area shows the first Continue Watching item's backdrop, logo (or title), and a Resume button.
- [snap] Continue Watching shelf: landscape thumbnails, progress bar, time left, "S2:E1" line for episodes.
- [snap] Next Up shelf, then "Latest in <Library>" poster shelves, one per library.
- [unit] With mock data, Continue Watching is The Lighthouse Keeper's Daughter, Signal Lost, Second Opinion, Quiet Machines, Lifeline; Next Up is Driftwood Bay S2:E1 and The Night Market S1:E4.
- [self] An empty shelf is hidden, not shown empty.
UX:
- Flow: Home -> hover a card for a lift and play glyph -> click opens the item's detail; hero Resume opens detail (playback in M2)
- Surface: sidebar page
- States: loading shows gray placeholders of the shelf shape; all shelves empty shows "Nothing to show yet. Open a library to start browsing." with a "Browse Movies" button; error "Unable to load Home." with "Try Again"
- Words: shelves "Continue Watching", "Next Up", "Latest in <Library>"; card time "38 min left"; episode line "S2:E1"
- Access: Tab moves between shelves, arrows within a shelf; VoiceOver "<title>, <time> left"
Status: done

### S-006 Browse a library as a poster grid
As the user, I open a library and scroll a grid of posters, sorted the way I choose.
Screens: 10-tab-tv-shows.png, 11-tab-movies.png, 22-media-library-movies.png, 36-filter-sort.png, 37-filter-filters.png
Depends: S-004
Acceptance:
- [snap] Adaptive poster grid with title and year; badges: check for played, heart for favourite, progress bar, unplayed count for series.
- [snap] Toolbar Sort menu (Name, Date Added, Year, Rating; Ascending and Descending) and Show menu (All, Unplayed, Favorites).
- [unit] Sort and filter map to `sortBy`, `sortOrder`, `filters` on `GET /Items`.
- [self] Scrolling to the end loads the next page (`startIndex`, `limit`).
UX:
- Flow: sidebar library -> grid -> toolbar Sort menu or Show menu changes the grid in place -> click a poster opens detail
- Surface: sidebar page; Sort and Show are toolbar menus (a few choices tied to one control)
- States: empty filter result "No items match this filter." with "Show All"; loading next page shows a small spinner at the grid's end; long titles truncate to two lines with the full title in a tooltip
- Words: menus "Sort By" (Name, Date Added, Year, Rating, then Ascending, Descending) and "Show" (All, Unplayed, Favorites)
- Access: arrow keys move the selection in the grid, Return opens; badges have VoiceOver words ("played", "favorite")
Status: done

### S-007 Open a movie's details
As the user, I click a poster to see the movie's details.
Screens: 14-movie-detail.png, 15-movie-detail-more.png, 16-movie-detail-bottom.png
Depends: S-006
Acceptance:
- [snap] Backdrop with gradient, logo (title text if there is no logo), metadata line (year, rating, runtime, star score), genres, tagline, overview.
- [snap] Play button is shown but disabled, with help text "Playback comes in a later version."
- [snap] Cast & Crew row with avatars and roles; More Like This row (`GET /Items/{id}/Similar`).
- [self] Esc and Command-[ go back to the grid with the scroll position kept.
UX:
- Flow: click poster -> detail pushes in the same column -> Esc or Command-[ goes back, scroll kept
- Surface: pushed page in the navigation stack (part of browsing, not a modal)
- States: no logo shows the title in large type; no backdrop uses the poster blurred; missing overview hides the line; error "Unable to load this item." with "Try Again"
- Words: "Play" (disabled, help "Playback comes in a later version."), "Cast & Crew", "More Like This"
- Access: Tab order Play, Mark Played, Add to Favorites, then shelves; VoiceOver reads the metadata line as one phrase
Status: doing

### S-008 Browse a series by season
As the user, I open a series, pick a season, and see its episodes.
Screens: 17-series-detail.png, 18-series-episodes.png, 19-series-bottom.png
Depends: S-007
Acceptance:
- [snap] Series header like S-007, then a season picker and an episode list (thumbnail, "1. Title", runtime, overview, played check or progress bar).
- [unit] Seasons come from `GET /Shows/{id}/Seasons`, episodes from `GET /Shows/{id}/Episodes?seasonId=`.
- [self] The season with the Next Up episode is selected first.
- [snap] Clicking an episode opens episode details (S-007 layout plus series name and "S1:E2").
UX:
- Flow: series detail -> season picker (segmented control, or a menu when more than 6 seasons) -> episode list updates -> click an episode opens its detail
- Surface: inline picker on the page (changes one value on screen)
- States: season with no episodes "No episodes in this season."; long overviews clamp to two lines
- Words: season names from the server ("Season 1"); episode rows "1. Arrival", runtime "42 min"
- Access: Left and Right change season when the picker has focus; episode rows are focusable, Return opens
Status: done

### S-009 Mark an item played or favourite
As the user, I click the check or heart button on a detail page to mark the item.
Screens: 14-movie-detail.png, 17-series-detail.png
Depends: S-007
Acceptance:
- [unit] Played calls `POST`/`DELETE /UserPlayedItems/{id}`; favourite calls `POST`/`DELETE /UserFavoriteItems/{id}`.
- [self] The button changes at once and goes back if the request fails, with an error message.
- [self] Home shelves and grid badges show the new state without a manual refresh.
UX:
- Flow: detail -> click check or heart -> icon fills at once -> request runs -> on failure icon reverts and error shows
- Surface: inline toggle buttons (one value on screen)
- States: failure shows an inline message under the buttons "Unable to update this item. Try again."
- Words: help "Mark Played" / "Mark Unplayed", "Add to Favorites" / "Remove from Favorites"; menu Item > Mark Played (Command-U), Item > Add to Favorites (Command-L)
- Access: VoiceOver reads the toggle's state ("Played, on"); state shows by fill and icon, not color alone
Status: done

### S-010 Switch user or sign out
As the user, I choose Switch User or Sign Out from the account menu in the toolbar.
Screens: 13-tab-settings.png, 39-select-user.png
Depends: S-003
Acceptance:
- [snap] Account menu: avatar and name, server name, Switch User (Shift-Command-U), Sign Out.
- [unit] Sign Out calls `POST /Sessions/Logout` and deletes the Keychain token.
- [self] Switch User returns to the user picker without signing out other users.
UX:
- Flow: toolbar account menu -> Switch User (Shift-Command-U) -> user picker; or Sign Out -> user picker without this user's saved session
- Surface: toolbar menu (a few choices tied to one control)
- States: Sign Out never asks (nothing typed is lost); failure to reach the server still signs out locally
- Words: menu header "<user> on <server>", items "Switch User", "Sign Out"
- Access: the menu button has help "Switch user or sign out"; same items in the app menu
Status: done

---

## M2 Watch

### S-011 Play a movie or episode
Screens: 23-player.png
Acceptance:
- [unit] `POST /Items/{id}/PlaybackInfo` with a Mac device profile; direct stream URL `/Videos/{id}/stream?static=true&ApiKey=` when no `TranscodingUrl`.
- [manual] Video plays in the window and full screen (Command-Control-F).
Status: todo

### S-012 Resume from where I stopped
Acceptance:
- [unit] Start position comes from `UserData.PlaybackPositionTicks`; a sheet offers Resume or Start Over.
Status: todo

### S-013 Report progress to the server
Acceptance:
- [unit] `POST /Sessions/Playing`, `/Sessions/Playing/Progress` every 5 seconds, `/Sessions/Playing/Stopped` with `PositionTicks`.
Status: todo

### S-014 Control playback with the keyboard
Screens: 23-player.png
Acceptance:
- [self] Space play/pause, Left/Right 10 s, Up/Down volume, Esc leaves full screen.
Status: todo

### S-015 Choose audio and subtitle tracks
Acceptance:
- [snap] Player menu lists `MediaStreams` of type Audio and Subtitle by `DisplayTitle`.
Status: todo

### S-016 Play the next episode
Acceptance:
- [self] At the end of an episode, a countdown card offers the next episode.
Status: todo

### S-017 See a playback error and retry
Screens: 23-player.png
Acceptance:
- [snap] "This item can't be played." with Close and Try Again.
Status: todo

---

## M3 Find

### S-018 Search the library
Screens: 42-tab-search.png, 43-search-keyboard.png
Acceptance:
- [unit] Command-F focuses the toolbar search field; results come from `GET /Items?searchTerm=&recursive=true`, grouped by type.
Status: todo

### S-019 Jump to a letter in a library
Screens: 38-filter-letter.png
Acceptance:
- [unit] Letter menu maps to `nameStartsWith`.
Status: todo

### S-020 Filter a library by genre or year
Screens: 35-filter-genres.png
Acceptance:
- [unit] Genre and year lists come from `GET /Items/Filters2`; selections map to `genreIds`, `years`.
Status: todo

### S-021 Browse a studio's titles
Screens: 40-studio-items.png, 41-studio-items-more.png
Acceptance:
- [snap] Studio page with one shelf per item type (`studioIds`).
Status: todo

### S-022 Browse a person's titles
Screens: 16-movie-detail-bottom.png
Acceptance:
- [snap] Clicking a cast card shows the person's photo and their movies and series (`personIds`).
Status: todo

### S-023 Browse by genre from a detail page
Screens: 15-movie-detail-more.png, 19-series-bottom.png
Acceptance:
- [snap] Clicking a genre pill opens a grid filtered to that genre.
Status: todo

---

## M4 Accounts and settings

### S-024 Add and switch between servers
Screens: 04-server-users.png, 39-select-user.png
Acceptance:
- [snap] Server picker in the user picker's bottom bar lists saved servers.
Status: todo

### S-025 Find servers on the local network
Screens: 02-connect-to-server.png
Acceptance:
- [unit] UDP broadcast "who is JellyfinServer?" on port 7359 lists replies under "Servers on this network".
Status: todo

### S-026 Edit a server's address
Screens: 26-settings-server.png, 27-settings-server-more.png
Acceptance:
- [snap] Settings > Server: name, version, address list; edit an address and test it.
Status: todo

### S-027 Choose which Home shelves show
Screens: 28-settings-advanced.png, 29-settings-advanced-more.png
Acceptance:
- [snap] Settings > Home: Recently added, Recently played, Rewatching in Next Up toggles.
Status: todo

### S-028 Pick an accent color
Screens: 13-tab-settings.png
Acceptance:
- [snap] Settings > Appearance accent picker changes buttons and progress bars.
Status: todo

### S-029 See user security settings
Screens: 24-settings-demo.png, 25-settings-demo-more.png
Acceptance:
- [snap] Settings > Account shows the signed-in user and a Change Password action.
Status: todo

---

## M5 Polish

### S-030 Use a poster's context menu
Acceptance:
- [snap] Right-click a poster: Play, Mark Played, Add to Favorites, Go to Series.
Status: todo

### S-031 See network activity for troubleshooting
Screens: 30-settings-logs.png, 31-settings-logs-more.png
Acceptance:
- [snap] Window > Activity Log lists requests with status, time, method, and path; Errors Only filter.
Status: todo

### S-032 Turn on experimental features
Screens: 32-settings-experimental.png, 33-settings-experimental-more.png
Acceptance:
- [snap] Settings > Experimental has a Live TV Guide toggle (off by default).
Status: todo

### S-033 Collapse the sidebar over content
Screens: 34-movies-filter-bar.png
Acceptance:
- [self] Control-Command-S hides and shows the sidebar; content keeps its scroll position.
Status: todo

### S-034 App icon
Acceptance:
- [snap] A custom icon, not the reference app's mark.
Status: todo

---

## Dropped

- Admin dashboard, users, plugins, tasks, backups: server admin belongs in the server's web UI.
- Live TV guide and recordings: off by default in the reference app; revisit after M5.
- Quick Connect and PIN sign-in: built for TV remotes with no keyboard.
- Chromecast and remote control of other sessions: not a Mac use case for version one.
- Debug settings page (13-tab-settings.png "Debug"): developer only.
- Tab bar layout picker (28-settings-advanced.png "Layout"): the Mac always uses a sidebar.
- On-screen tvOS keyboard (43-search-keyboard.png): the Mac has a real keyboard.
- Reference app branding (logo in 01, 04, 13, 39): not copied.

## Screen coverage

| Screen | Story |
| --- | --- |
| 01, 02, 03 | S-001, S-002, S-025 |
| 04, 05, 06 | S-003, S-024 |
| 07, 08, 09 | S-004, S-005 |
| 10, 11, 22 | S-006 |
| 12 | S-004 |
| 13 | S-010, S-028 |
| 14, 15, 16 | S-007, S-009, S-022, S-023 |
| 17, 18, 19 | S-008, S-009, S-023 |
| 23 | S-011, S-014, S-017 |
| 24, 25 | S-029 |
| 26, 27 | S-026 |
| 28, 29 | S-027 |
| 30, 31 | S-031 |
| 32, 33 | S-032 |
| 34 | S-033 |
| 35 | S-020 |
| 36, 37 | S-006 |
| 38 | S-019 |
| 39 | S-003, S-010, S-024 |
| 40, 41 | S-021 |
| 42, 43 | S-018 |
