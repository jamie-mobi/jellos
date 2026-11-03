# jellyOS Home, Apple TV tab style: stories

Reference: the "Apple TV" tab of the macOS TV app, walked on 2026-11-03.
Screens: `docs/apple-tv-tab/screens/INDEX.md` (PNGs are git-ignored).
API: `docs/openapi.json` (Jellyfin 12.2.0). Words: `docs/GLOSSARY.md`.
Main backlog: `docs/STORIES.md`. These stories restyle and extend its Home (S-004, S-005)
and detail pages (S-007, S-008). They do not replace them. IDs use the `ATV-` prefix.

Mapping from the reference to Jellyfin:

| Reference | jellyOS (Jellyfin) |
| --- | --- |
| Featured hero | Featured: a few items from Latest and Next Up, with a Backdrop and a logo image |
| Continue Watching | Continue Watching (`GET /UserItems/Resume`) |
| Your Next Watch (large cards) | Next Up (`GET /Shows/NextUp`) |
| New Releases, Just Added | Latest (`GET /Items/Latest`) |
| For You | For You (`GET /Movies/Recommendations`, `GET /Items/Suggestions`) |
| Watchlist | Favorites (`/UserFavoriteItems/{itemId}`) |
| Themed shelves (Spies and Secrets) | Collections (`GET /Collections`, BoxSet items) |
| Bundles on a detail page | Collections that hold this item (`GET /Items/{itemId}/Collections`) |
| All Comedy, All Drama | Genre shelves (`GET /Genres`, items filtered by genre) |
| Browse All (category tiles) | Genre tiles to a genre page |
| Top 10 (ranked) | Top Rated: 10 items by community rating, ranked |
| Related | More Like This (`GET /Items/{itemId}/Similar`) |
| Trailers | Trailers (`GET /Items/{itemId}/LocalTrailers` and `RemoteTrailers`) |
| Bonus Content | Extras (`GET /Items/{itemId}/SpecialFeatures`) |
| Mark as Watched | Mark Played (`/UserPlayedItems/{itemId}`) |
| Remove from Recently Watched | Remove from Continue Watching: set the position to 0 (`POST /UserItems/{itemId}/UserData`) |

Milestones:
- **M1 Home**: the hero, Continue Watching, Next Up, Latest shelves, See All, back. A user can
  start the day from Home.
- **M2 Details**: movie and series detail pages in the reference layout.
- **M3 Discover**: genres, collections, Top Rated, Recommended, Favorites.
- **M4 Polish**: loading, light mode, keyboard, hover arrows.

---

## M1 Home

### ATV-001 See a featured item at the top of Home
As the user, I open Home and see one featured item large at the top, with a button to play it.
Screens: 01-tab-page-01.png, 11-hero-page-1.png, 36-light-tab-top.png
Depends: S-004
Acceptance:
- [unit] Featured takes up to 10 items: first Next Up, then Latest. It keeps only items that have a Backdrop image.
- [snap] The hero fills the content width and about 60% of the window height, under a transparent title bar.
- [snap] Bottom-left block: logo image (or the name in large type if there is no logo), metadata line "Series · Drama · Thriller" plus the rating badge, a 2-line overview, primary button, round Favorites button.
- [unit] The primary button label is "Play", "Resume" for an item with a saved position, or "Play S2, E3" for a series with a Next Up episode.
- [snap] The hero stays dark in light mode. The text on it is always white.
- [manual] The primary button starts playback (uses S-011).
UX:
- Flow: open Home -> hero shows featured item 1 -> Play or Resume starts playback; Favorites button toggles the heart
- Surface: inline at the top of the Home scroll view; it scrolls away with the page
- States: no items with a Backdrop: no hero, Home starts with the first shelf; image loading: dark gradient, text shows at once
- Words: buttons "Play", "Resume", "Play S2, E3"; Favorites button help "Add to Favorites" / "Remove from Favorites"
- Access: VoiceOver reads "Featured, <name>, 1 of 10"; Return on the focused hero runs the primary button
Status: todo

### ATV-002 Page through featured items
As the user, I move to the next featured item with the page dots, the arrows, or by waiting.
Screens: 11-hero-page-1.png, 12-hero-page-2.png, 13-hero-page-3.png, 14-continue-watching-card-menu.png
Depends: ATV-001
Acceptance:
- [snap] Page dots sit centred at the bottom of the hero. The current dot is white; the others are grey. When there are more than 7, the end dots get smaller.
- [self] The hero moves to the next item after 8 seconds. It stops moving while the pointer is over it, while a menu is open, and when Reduce Motion is on.
- [self] Left and right arrows show at the hero edges on hover. A click moves one page; the last page goes back to the first.
- [unit] Clicking a dot goes to that page.
UX:
- Flow: hover hero -> arrows show -> click arrow or dot -> crossfade to the next item (0.4 s)
- Surface: inline controls on the hero
- States: one featured item: no dots, no arrows, no auto-advance
- Words: arrow help "Previous" / "Next"; VoiceOver page control "Page 2 of 10"
- Access: Left and Right arrow keys change the page when the hero has focus; VoiceOver adjustable control
Status: todo

### ATV-003 Continue watching from a progress card
As the user, I see the items I started as wide cards with a progress bar, and click one to resume.
Screens: 01-tab-page-01.png, 02-tab-page-02.png
Depends: S-005, S-012
Acceptance:
- [unit] The shelf loads `GET /UserItems/Resume` and keeps the server order.
- [snap] Each card is a 16:9 Thumbnail, about 5 cards per row, with the series logo over the image.
- [snap] Bottom bar on the card: play glyph, a short progress bar, "S3, E1 · 1h 1m" for an episode or the time left for a movie, and a "..." button on the right.
- [manual] A click on the card resumes playback at the saved position.
UX:
- Flow: Home -> Continue Watching shelf -> click card -> player opens at the saved position
- Surface: inline Shelf on Home, second after the hero
- States: nothing started: the shelf is hidden
- Words: header "Continue Watching"; time left "23m left"; episode label "S3, E1 · 1h 1m"
- Access: VoiceOver "<series>, Season 3 Episode 1, 23 minutes left"; Return resumes
Status: todo

### ATV-004 Use the menu on a Continue Watching card
As the user, I open the "..." menu on a progress card to go to the episode or the series, mark it played, or remove it.
Screens: 14-continue-watching-card-menu.png
Depends: ATV-003, S-009
Acceptance:
- [snap] Menu items, in order: Go to Episode, Go to Series, ---, Mark Played, Remove from Continue Watching, ---, Add to Favorites (or Remove from Favorites).
- [unit] "Remove from Continue Watching" sets the playback position to 0 with `POST /UserItems/{itemId}/UserData` and removes the card at once.
- [unit] "Mark Played" calls `POST /UserPlayedItems/{itemId}` and removes the card.
- [self] A right-click on the card opens the same menu.
- [manual] Go to Episode opens the episode in the series detail; Go to Series opens the series detail.
UX:
- Flow: click "..." or right-click card -> menu -> pick an action -> card goes away (no confirm, the action can be undone with Mark Unplayed)
- Surface: menu (short list of actions on one item)
- States: movie: no "Go to Episode", "Go to Series" becomes "Go to Movie"
- Words: as in Acceptance
- Access: Shift-F10 or VoiceOver "Actions" opens the menu
Status: todo

### ATV-005 See Next Up as large cards
As the user, I see the next episode of each series I watch as a large card with its details.
Screens: 03-tab-page-03.png, 04-tab-page-04.png
Depends: ATV-003
Acceptance:
- [unit] The shelf loads `GET /Shows/NextUp`.
- [snap] Cards are 16:9 and large (4 per row). Each shows the Backdrop, the series logo, and the line "Series · Drama · Thriller" at the bottom.
- [manual] A click opens the series detail at that episode.
UX:
- Flow: Home -> Next Up shelf -> click card -> series detail (ATV-012)
- Surface: inline Shelf on Home
- States: no Next Up items: shelf hidden
- Words: header "Next Up"
- Access: VoiceOver "<series>, next: Season 2 Episode 4"
Status: todo

### ATV-006 Browse Latest as poster shelves
As the user, I see the newest items of each library as a row of posters.
Screens: 02-tab-page-02.png, 03-tab-page-03.png, 09-tab-page-09.png
Depends: S-004
Acceptance:
- [unit] One shelf per library from `GET /Items/Latest?parentId=<library>`.
- [snap] Posters are 2:3, about 8 per row at a 1600 pt window, with 20 pt gaps. Headers are bold, left-aligned with the first poster.
- [snap] An item added in the last 7 days shows the caption "Added this week" under the poster.
- [manual] A click opens the movie or series detail.
UX:
- Flow: Home -> scroll -> poster shelf -> click poster -> detail
- Surface: inline Shelf
- States: empty library: shelf hidden
- Words: header "Latest <Library name>"; caption "Added this week"
- Access: VoiceOver reads name, year, and "Added this week"
Status: todo

### ATV-007 Open the full list from a shelf header
As the user, I click a shelf header with a chevron to see all of its items in a grid.
Screens: 15-see-all-continue-watching.png, 16-see-all-top-10.png, 17-see-all-new-releases.png, 18-see-all-watchlist.png, 19-see-all-for-you.png, 20-see-all-all-movies.png, 21-see-all-curated-theme.png, 38-light-see-all.png
Depends: ATV-003, ATV-006
Acceptance:
- [snap] A header shows a chevron only when the shelf has more items than it shows.
- [snap] The See All page: back button top-left, large bold title, then a grid with the same card style as the shelf (16:9 cards 5 per row, posters 8 per row).
- [self] The grid loads more items as I scroll (pages of 50).
- [snap] A grid with one item leaves the rest of the page empty, with no filler.
UX:
- Flow: Home -> click "Latest Movies >" -> See All page pushes in -> Back returns
- Surface: pushed page in the same window (a long list needs the full width)
- States: loading: skeleton cards (ATV-020); error: "Couldn't load this list." with "Try Again"
- Words: page title is the shelf name
- Access: Cmd-[ goes back; arrow keys move in the grid
Status: todo

### ATV-008 Go back and keep my place
As the user, I go back from a pushed page and Home is where I left it.
Screens: 15-see-all-continue-watching.png, 24-movie-detail.png
Depends: ATV-007
Acceptance:
- [snap] Pushed pages show a round back button at the top-left of the content, next to the sidebar.
- [self] Back (button, Cmd-[, or a two-finger swipe) restores the Home scroll offset and each shelf's scroll offset.
- [unit] Each tab keeps its own back stack; changing sidebar section and coming back keeps it.
UX:
- Flow: Home -> detail -> detail (More Like This) -> Back -> Back -> Home at the same spot
- Surface: content toolbar button
- States: at the root of a section the back button is hidden
- Words: help "Back"
- Access: Cmd-[ ; VoiceOver "Back"
Status: todo

## M2 Details

### ATV-009 See a movie's detail header
As the user, I open a movie and see its Backdrop, logo, facts, and a play button.
Screens: 24-movie-detail.png, 25-movie-detail-scroll-0.25.png
Depends: S-007
Acceptance:
- [snap] Full-width Backdrop, about 60% of the window height. Bottom-left: logo, "Movie · Action · Sci-Fi" with the rating badge, 2-line overview with a "MORE" pill, a facts line, the play button, and the Favorites button.
- [unit] The facts line is: year · runtime · critic rating · video badges (4K, HD, HDR, Dolby Vision) · audio badges (Atmos, 5.1) · CC · SDH. Badges come from the media streams.
- [unit] The play button reads "Play", "Resume", or "Play Again" when the item is Played.
- [snap] Bottom-right: "Starring <3 names>" and "Director <name>".
- [snap] One round button top-right: "Mark Played" / "Mark Unplayed". (The reference also has mute, full-screen trailer, download and share; see Later and Dropped.)
Status: todo

### ATV-010 Read the full overview
As the user, I click "MORE" to read the full overview.
Screens: 24-movie-detail.png, 29-series-detail.png
Depends: ATV-009
Acceptance:
- [snap] "MORE" shows only when the overview is longer than 2 lines.
- [snap] A click opens a sheet with the name, the full overview, and a "Done" button.
- [self] Escape closes the sheet.
Status: todo

### ATV-011 Keep the title in view while I scroll a detail page
As the user, I scroll down a detail page and still see the name and the back button.
Screens: 26-movie-detail-scroll-0.5.png, 31-series-detail-scroll-0.4.png
Depends: ATV-009
Acceptance:
- [snap] After the header scrolls off, a blurred bar shows at the top with the back button and the item name.
- [self] The bar fades in over 0.2 s and is gone again at the top of the page.
Status: todo

### ATV-012 See a series' Next Up episode in its header
As the user, I open a series and its header tells me which episode plays next.
Screens: 29-series-detail.png, 39-light-series-detail.png
Depends: S-008, ATV-009
Acceptance:
- [unit] The header uses the Next Up episode of the series, or episode 1 of season 1 if nothing is played.
- [snap] The overview line starts "S6, E1 · <episode name>:" then the episode overview.
- [unit] The button reads "Play Episode", "Resume Episode", or "Play S1, E1".
Status: todo

### ATV-013 Browse episodes in one strip with a season picker
As the user, I scroll one strip of episode cards and jump to a season with the picker.
Screens: 29-series-detail.png, 30-series-detail-scroll-0.2.png, 35-episodes-loading-placeholders.png
Depends: ATV-012
Acceptance:
- [snap] Header "Season 6" with an up-down chevron. It is a pop-up menu of all seasons.
- [snap] Episode card: 16:9 Thumbnail; "EPISODE 1" in small caps; name; 3-line overview; "▶ 48m"; "..." button. Played episodes show a check; started ones a progress bar.
- [self] The strip holds all seasons in order. Picking a season scrolls the strip to its first episode. Scrolling past a season edge updates the picker label.
- [self] The strip opens scrolled to the Next Up episode.
- [unit] The "..." menu has Play, Mark Played / Mark Unplayed, Add to Favorites.
Status: todo

### ATV-014 Watch a trailer from the detail page
As the user, I see the trailers of an item as wide cards and play one.
Screens: 25-movie-detail-scroll-0.25.png, 30-series-detail-scroll-0.2.png
Depends: ATV-009, S-011
Acceptance:
- [unit] The shelf loads `GET /Items/{itemId}/LocalTrailers`. Remote trailers (`RemoteTrailers` on the item) open in the browser.
- [snap] 16:9 cards with the trailer name and "▶ 2m".
- [snap] No trailers: the shelf is hidden.
Status: todo

### ATV-015 Watch extras
As the user, I see an item's extras (behind the scenes, featurettes) and play one.
Screens: 31-series-detail-scroll-0.4.png
Depends: ATV-014
Acceptance:
- [unit] The shelf loads `GET /Items/{itemId}/SpecialFeatures`.
- [snap] Header "Extras"; the same 16:9 card as Trailers.
Status: todo

### ATV-016 See More Like This on a detail page
As the user, I see items like the one I opened and open one.
Screens: 25-movie-detail-scroll-0.25.png, 33-series-detail-scroll-0.8.png
Depends: ATV-009
Acceptance:
- [unit] The shelf loads `GET /Items/{itemId}/Similar?limit=20`.
- [snap] Header "More Like This" with a chevron; poster cards.
- [self] A click pushes a new detail page; Back returns (ATV-008).
Status: todo

### ATV-017 See Cast & Crew as round photos
As the user, I see who is in an item as round photos with names and roles.
Screens: 26-movie-detail-scroll-0.5.png, 33-series-detail-scroll-0.8.png
Depends: ATV-009, S-022
Acceptance:
- [snap] Round photos about 80 pt wide; name under it in white, role under that in grey (character for actors, job for crew).
- [snap] A person with no photo shows initials on a grey circle.
- [manual] A click opens the person's titles (S-022).
Status: todo

### ATV-018 Read an item's information footer
As the user, I scroll to the bottom of a detail page to read its studio, release, rating, and languages.
Screens: 28-movie-detail-scroll-1.png, 34-series-detail-scroll-1.png
Depends: ATV-009
Acceptance:
- [snap] "About" card: name, genres in small caps, full overview.
- [snap] Three columns: Information (Studio, Released, Duration, Rated, Region of Origin), Languages (Original Audio, Audio, Subtitles), Accessibility (CC, SDH, AD badge meanings).
- [unit] Audio and subtitle languages come from the item's media streams, one entry per language, with the codec in brackets ("English (Dolby Digital 5.1)").
- [unit] A field with no data is left out.
Status: todo

### ATV-019 See the collections an item belongs to
As the user, I see the collections that hold this item and open one.
Screens: 28-movie-detail-scroll-1.png
Depends: ATV-009, ATV-024
Acceptance:
- [unit] The shelf loads `GET /Items/{itemId}/Collections`.
- [snap] Header "Collections"; poster cards; hidden when there are none.
Status: todo

## M3 Discover

### ATV-020 See placeholders while a shelf loads
As the user, I see grey card shapes while items load, so the page does not jump.
Screens: 35-episodes-loading-placeholders.png
Depends: ATV-006
Acceptance:
- [snap] A loading shelf shows rounded grey rectangles at the real card size and count that fits the row.
- [self] Cards replace placeholders in place, without moving the shelves below.
- [self] A failed shelf hides itself and logs the error; the page does not show an alert.
Status: todo

### ATV-021 Browse a genre shelf
As the user, I see one shelf per main genre, for example "Comedy Series".
Screens: 09-tab-page-09.png, 10-tab-page-10.png
Depends: ATV-006
Acceptance:
- [unit] Genres come from `GET /Genres`. Home shows the 5 genres with the most items, per library type.
- [snap] Header "<Genre> Movies" or "<Genre> Series" with a chevron to See All (ATV-007).
Status: todo

### ATV-022 Open a genre page from a genre tile
As the user, I click a tinted genre tile and get a page for that genre.
Screens: 08-tab-page-08.png, 22-category-page.png, 23-category-page-scrolled.png
Depends: ATV-001, ATV-021
Acceptance:
- [snap] "Genres" shelf of 3:4 tiles: a Backdrop from the genre's top item, tinted with one colour per genre, label bottom-left in white.
- [snap] The genre page: back button, the genre title over a hero of its items (ATV-001 layout), then shelves "Top Rated", "Latest", "Movies", "Series" for that genre.
- [unit] Tint colours are fixed per genre name, so a genre keeps its colour.
Status: todo

### ATV-023 Keep a Favorites shelf
As the user, I see my Favorites on Home and open the full list.
Screens: 08-tab-page-08.png, 18-see-all-watchlist.png
Depends: S-009, ATV-007
Acceptance:
- [snap] Header "Favorites >" with the grey subtitle "Movies and series you marked with the heart."
- [unit] Items come from `GET /Items?filters=IsFavorite&recursive=true`, newest first.
- [snap] No Favorites: the shelf is hidden on Home; the See All page shows "No Favorites yet" and one line on how to add one.
- [self] Adding or removing a favourite anywhere updates the shelf without a reload.
Status: todo

### ATV-024 Browse collections as themed shelves
As the user, I see each of my server's collections as its own shelf.
Screens: 06-tab-page-06.png, 07-tab-page-07.png, 21-see-all-curated-theme.png
Depends: ATV-006
Acceptance:
- [unit] Collections come from `GET /Items?includeItemTypes=BoxSet`. Home shows up to 5, most recently changed first.
- [snap] Header is the collection name with a chevron; poster cards.
Status: todo

### ATV-025 See a Top Rated shelf with ranks
As the user, I see the 10 highest-rated items with a big rank number.
Screens: 03-tab-page-03.png, 04-tab-page-04.png, 16-see-all-top-10.png
Depends: ATV-006
Acceptance:
- [unit] 10 items, sorted by community rating, then by name.
- [snap] Poster with a large rank number top-left and a caption at the bottom: the first genre for a mixed shelf, or "Movie" / "Series".
- [snap] See All shows the same 10 in a grid of 8 per row.
Status: todo

### ATV-026 See a For You shelf
As the user, I see items picked from what I played, with a line that says why.
Screens: 07-tab-page-07.png, 19-see-all-for-you.png
Depends: ATV-006
Acceptance:
- [unit] Items come from `GET /Movies/Recommendations` and `GET /Items/Suggestions`, without items I already played.
- [snap] Header "For You >" with the subtitle "Based on what you played."
- [snap] Hidden when the user has played nothing.
Status: todo

## M4 Polish

### ATV-027 Page a shelf with hover arrows
As the user, I hover a shelf and click an arrow to move it one page.
Screens: 05-tab-page-05.png, 35-episodes-loading-placeholders.png
Depends: ATV-006
Acceptance:
- [snap] On hover, a chevron shows in the 40 pt margin at each end that can scroll; dimmed at the start or end.
- [self] A click scrolls one page of whole cards; a trackpad swipe also scrolls.
Status: todo

### ATV-028 Use Home in light mode
As the user, I use the light appearance and Home still reads well.
Screens: 36-light-tab-top.png, 37-light-tab-shelves.png, 38-light-see-all.png, 39-light-series-detail.png
Depends: ATV-001, ATV-009
Acceptance:
- [snap] Light: white page, dark headers, grey subtitles. The hero and the detail header stay dark with white text.
- [snap] Text on artwork (large cards, logos) is white in both modes, with a bottom gradient.
Status: todo

### ATV-029 Move through Home with the keyboard
As the user, I move between shelves and cards with the arrow keys and open one with Return.
Screens: 01-tab-page-01.png, 02-tab-page-02.png
Depends: ATV-006, ATV-008
Acceptance:
- [self] Up and Down move between the hero and shelves; Left and Right move in a shelf and scroll it.
- [self] Return opens, Space plays, Cmd-[ goes back.
- [snap] The focused card shows the system focus ring.
Status: todo

---

## Later

- Backdrop video in the hero and detail header (theme videos, `GET /Items/{itemId}/ThemeVideos`), with a mute button. Reference: 01, 24.
- Inline video preview on large Next Up cards. Reference: 05.
- "Spotlight" shelf of people from one series (large person name and a blurb). Reference: 02. Needs curated text Jellyfin does not have.
- Quote and award shelf (critic quotes, award laurels). Reference: 06. No data source.
- Full-screen trailer button on the detail header. Reference: 24.
- Remaining time "New" pill on Continue Watching for a newly added episode. Reference: 15.

## Dropped

- How to Watch tiles (Play / Buy / Rent / Subscribed): no store in jellyOS. Reference: 26, 33.
- Buy, Rent, prices, "30 days to watch", "Purchased Content" note: vendor only. Reference: 26, 28.
- Subscriptions, upsell, service glyph on cards: vendor only.
- "More to Explore" links to other apps (books, maps): cross-app promotion. Reference: 10.
- Sports section (MLS) and Store sidebar items: out of scope.
- Family Sharing: Apple account feature.
- Download from the card menu: not in v1 (playback is streaming; see `docs/spec/13-jellyos-decisions.md`).
- Share button and Share menu: no public link for a private server.
- Global Top 10 charts: no cross-user chart data; replaced by Top Rated (ATV-025).
- Account menu items (Authorisations, Redeem, Check for Available Downloads): Apple account only. Command map.
- Actions menu items for local files (Show in Finder, Convert, Playlists, Import): local media library features, not this tab.

## Screen coverage

| Screen | Stories |
| --- | --- |
| 01-tab-page-01 | ATV-001, ATV-003, ATV-029 |
| 02-tab-page-02 | ATV-003, ATV-006, ATV-029; spotlight in Later |
| 03-tab-page-03 | ATV-005, ATV-006, ATV-025 |
| 04-tab-page-04 | ATV-005, ATV-025 |
| 05-tab-page-05 | ATV-027; inline preview in Later |
| 06-tab-page-06 | ATV-024; quote shelf in Later |
| 07-tab-page-07 | ATV-024, ATV-026 |
| 08-tab-page-08 | ATV-022, ATV-023 |
| 09-tab-page-09 | ATV-006, ATV-021 |
| 10-tab-page-10 | ATV-021; More to Explore in Dropped |
| 11, 12, 13 hero pages | ATV-001, ATV-002 |
| 14-continue-watching-card-menu | ATV-004, ATV-002 |
| 15 to 21 See All | ATV-007, ATV-008, ATV-023, ATV-024, ATV-025, ATV-026 |
| 22, 23 category page | ATV-022 |
| 24 to 28 movie detail | ATV-009, ATV-010, ATV-011, ATV-014, ATV-016, ATV-017, ATV-018, ATV-019; How to Watch in Dropped |
| 29 to 34 series detail | ATV-012, ATV-013, ATV-014, ATV-015, ATV-016, ATV-017, ATV-018 |
| 35 loading placeholders | ATV-013, ATV-020, ATV-027 |
| 36 to 39 light mode | ATV-001, ATV-007, ATV-012, ATV-028 |
