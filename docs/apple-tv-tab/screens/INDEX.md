# Screen index: TV app, "Apple TV" tab (macOS)

Source: the macOS TV app (`/System/Applications/TV.app`), sidebar item "Apple TV",
walked on 2026-11-03. Signed in to the user's real account, so the PNGs show a real
name, avatar and watchlist. PNGs are 3200x1986 (window 1600x993 pt at 2x) and are
git-ignored (`docs/apple-tv-tab/screens/*.png`). Dark mode unless the name says `light`.

How the walk was done: the app was driven through the macOS accessibility API only
(scroll bar values, `AXPress`, `AXShowMenu`), and each shot is a window capture
(`screencapture -l`). No mouse, so hover states are not captured.

Purpose: a layout and behaviour reference for jellyOS Home. This file describes structure
and behaviour. It copies no logos, icons or artwork. Shelf, button and menu names are quoted
only to identify the element; jellyOS uses its own words (`docs/GLOSSARY.md`).

Known gaps (not captured, and why):
- Hero and detail backdrops are video. Protected video shows black in window captures
  (11-13, 22, 29). The layout over it is still correct.
- Right-click menus on poster cards, the season picker, and the description "MORE"
  button expose no accessibility action. They need a real mouse click.
- Hover state: the left and right page arrows on shelves and the hero appear on hover only.
- Cast member (person) page: the press did not open it.
- Play, Add to Watchlist, Buy, Rent and Download were not pressed, by design.

---

## 01-tab-page-01.png

Page: Apple TV tab, top. Reached from: sidebar > Apple TV.
Layout: sidebar on the left (search, top-level sections, a "Library" group, account row at
the bottom). The content area starts with a full-bleed hero (about 60% of the window height)
under the transparent title bar.
Elements: hero backdrop (video, plays muted); mute toggle top-right; bottom-left info block:
optional badge pill ("New"), title logo image, metadata line (service glyph, type, genres,
content-rating badge), 2-line synopsis, one bold "status" line (rank or "another season is
coming"), white capsule "Play" button, round "+" (add to watchlist) button. Page dots centred
at the bottom of the hero (10 pages, dots shrink at the ends).
Then the first shelf starts: "Continue Watching" header with a chevron.
Actions: play, add to watchlist, change page (dots, arrows on hover, auto-advance), mute.

## 02-tab-page-02.png

Page: tab, scrolled. Shelves seen: Continue Watching (16:9 cards), a "spotlight" shelf,
a poster shelf, the start of a ranked Top 10 shelf.
Continue Watching card: 16:9 artwork with title logo; bottom bar: play glyph, small progress
bar (only when started), "S3, E1 · 1h 1m" or a remaining time, "..." menu button.
Spotlight card: tall card (about 3:4, 3 per row) with a large person name, a one-line blurb
and the show logo. Header has no chevron (no See All).
Poster card: 2:3 poster, 8 per row; some have a small caption under the logo ("Just Added").

## 03-tab-page-03.png

Shelves: ranked "Top 10" (poster with a big rank number top-left and a genre caption at the
bottom), "New Releases" (plain posters, small service glyph top-right), start of
"Your Next Watch" (large 16:9 cards).

## 04-tab-page-04.png

Shelves: "Your Next Watch" large cards (title logo, metadata line "Movie · Comedy · Drama"
overlaid at the bottom), "Top 10 Action" (ranked, caption is the type: Movie / TV Show),
"Must-See Hits" (posters), start of "Question Everything" (large cards).

## 05-tab-page-05.png

Shelves: large cards with a badge pill ("All Episodes Now Available") and a status line;
one large card plays an inline video preview with its own mute button (black in capture).
Then "All Movies" and "All TV Shows" poster shelves. A right page arrow shows at the shelf edge.

## 06-tab-page-06.png

Shelves: an untitled "press quote" shelf (large 3:4 cards: show logo, a critic quote,
the source name, or an award laurel), "Spies and Secrets", "Rooting for the Underdog"
(themed poster shelves with chevrons).

## 07-tab-page-07.png

Shelves: "Rooting for the Underdog", "Action-Packed Sci-Fi", "For You" (header with a
grey subtitle line "picks based on your past plays"), start of "All Kids & Family".

## 08-tab-page-08.png

Shelves: "All Kids & Family" (posters), "Browse All Originals" (category tiles: artwork
tinted in one colour with a white label bottom-left, for example Kids & Family, Sci-Fi,
Comedies), "Watchlist" (header with chevron and subtitle "Movies and shows you added",
one poster), start of "All Comedy TV Shows".

## 09-tab-page-09.png

Shelves: All Comedy / All Drama / All Documentaries / start of All Sci-Fi (genre poster shelves).

## 10-tab-page-10.png

Page: tab, bottom. Shelves: All Sci-Fi, All Non-Fiction, "More to Explore" (posters with a
small app badge top-left that links to another app: books, maps). No footer.

## 11-hero-page-1.png

Page: tab top, hero page 1 of 10. Badge pill "New", status line, "Play" and "+".
The first Continue Watching cards show below the hero. The hero auto-advances after a few
seconds (seen: it was on page 4 a minute later, in 14).

## 12-hero-page-2.png

Page: hero page 2, reached with the page control's increment action. No badge pill; the
status line says a new season is coming. Same buttons.

## 13-hero-page-3.png

Page: hero page 3. No badge pill and no status line; the synopsis is one line. Shows that
the info block shrinks to fit.

## 14-continue-watching-card-menu.png

Page: tab top, "..." menu of a Continue Watching card open.
Menu items: Download, Go to Episode, Go to Show, Remove from Watchlist, Mark as Watched,
Remove from Recently Watched, Share >.
Note: the hero had auto-advanced to page 4 (award badge, award laurel art on the right).

## 15-see-all-continue-watching.png

Page: See All for Continue Watching. Reached from: shelf header chevron.
Layout: round back button top-left in the title bar; large bold page title; grid of 16:9
cards, 5 per row, same card as the shelf (progress, "S1, E2 · 44m", "Now Available",
"Continue · 1h 36m", "..." menu). A "New" pill on one card.

## 16-see-all-top-10.png

Page: See All for Top 10. Grid of ranked posters, 8 per row, 10 items, rank + genre caption.

## 17-see-all-new-releases.png

Page: See All for New Releases. Poster grid, 8 per row, scrolls.

## 18-see-all-watchlist.png

Page: See All for Watchlist. Poster grid with one item; the rest of the page is empty.

## 19-see-all-for-you.png

Page: See All for For You. Poster grid, 8 per row, many rows.

## 20-see-all-all-movies.png

Page: See All for All Movies. Poster grid, 8 per row, many rows.

## 21-see-all-curated-theme.png

Page: See All for a themed shelf (Spies and Secrets). Poster grid, 11 items.

## 22-category-page.png

Page: category page (Sci-Fi). Reached from: Browse All Originals > a category tile.
Layout: back button; the category title over a full hero carousel (page arrows left and
right, page dots, mute). The hero button changes with state: "Resume S3, E1" and a
checkmark button (already on the watchlist) instead of "Play" and "+".
Then shelves: "Essentials" and more.

## 23-category-page-scrolled.png

Page: category page scrolled. Shelves: Essentials, Action-Packed Sci-Fi, Sci-Fi Mysteries
(poster shelves with chevrons). The page is short (3 to 4 shelves).

## 24-movie-detail.png

Page: movie detail. Reached from: any poster > press.
Layout: back button top-left; top-right round buttons: mute, expand trailer to full screen,
download, share. Full-bleed backdrop (trailer plays muted). Bottom-left: title logo,
metadata line (glyph, "Movie · Action · Sci-Fi", rating badge), 2-line synopsis with an
inline "MORE" pill, facts line (year · runtime · critic score · HD · Dolby badges · CC · AD),
"Play Again" capsule button (label depends on state), "+" button. Bottom-right: "Starring"
and "Director" lines.
Then the "Trailers" shelf.

## 25-movie-detail-scroll-0.25.png

Shelves: Trailers (16:9 card: title, "▶ Action", "..." menu), Related (posters, chevron),
start of How to Watch.

## 26-movie-detail-scroll-0.5.png

Page: movie detail, middle. The title bar now shows a blurred bar with the back button and
the item title (sticky header); top-right keeps download and share.
Sections: Related; "How to Watch" (4 wide tiles: app icon, action (Play / Buy / Rent),
state or price, small badges "4K", "30 days to watch"); "Cast & Crew" (round headshots,
name, role under it; chevron to See All); start of Bundles.

## 27-movie-detail-scroll-0.75.png

Between 26 and 28: Cast & Crew, Bundles, About.

## 28-movie-detail-scroll-1.png

Page: movie detail, bottom. Sections: "Bundles" (one poster), "About" (rounded cards:
title + genres in caps + full synopsis; a "Purchased Content" note card with "MORE"),
then a 3-column footer: Information (Studio, Released, Duration, Rated, Region of Origin),
Languages (Original Audio, Audio, Subtitles), Accessibility (CC and AD badge explanations),
copyright line.

## 29-series-detail.png

Page: series detail. Reached from: Top 10 > a series poster.
Layout: like the movie detail, but the info block shows the next episode:
"S6, E1 · Episode name: synopsis" with "MORE"; facts line (year · 48m · 4K · Dolby Vision ·
Dolby Atmos · CC · SDH · AD); "Play Episode" button; checkmark (on watchlist).
Then "Season 6" with an up-down chevron (season picker pop-up) and the episode strip.

## 30-series-detail-scroll-0.2.png

Sections: Episodes strip (16:9 cards: "EPISODE 1" caps label, episode title, 3-line
synopsis, "▶ 48m", "..." menu; the strip shows all seasons in one long row, scrolled to the
selected season); Trailers (16:9 cards, per season).

## 31-series-detail-scroll-0.4.png

Sections: Episodes, Trailers, "Bonus Content" (16:9 cards: recap, featurettes), start of Related.

## 32-series-detail-scroll-0.6.png

Between 31 and 33: Bonus Content, Related, Cast & Crew.

## 33-series-detail-scroll-0.8.png

Sections: Related (posters), Cast & Crew (headshots, name, character or job), How to Watch
(one tile: Play, Subscribed, "Seasons 1–6"), About (series card).

## 34-series-detail-scroll-1.png

Page: series detail bottom: About and the Information / Languages / Accessibility footer.

## 35-episodes-loading-placeholders.png

Page: series detail with the episode strip scrolled back to an earlier season.
State: loading. Each card not yet loaded shows as an empty rounded rectangle of the same
size (skeleton). Page arrows show at both ends of the strip. The cards stayed empty while the
window was in the background; filling in when active was not seen.

## 36-light-tab-top.png

Page: tab top in light mode. The hero stays dark (it is video); sidebar and shelf area turn light.

## 37-light-tab-shelves.png

Page: tab middle in light mode. White background, dark headers; large card text stays white
on artwork.

## 38-light-see-all.png

Page: See All (Top 10) in light mode.

## 39-light-series-detail.png

Page: series detail in light mode. The hero area stays black; the shelves below are light.

---

## Navigation map

| From | Action | Goes to |
| --- | --- | --- |
| Sidebar > Apple TV | click | Tab (01) |
| Shelf header with chevron | click | See All grid for that shelf (15-21) |
| Shelf header without chevron (spotlight, Great Movies, Your Next Watch, Question Everything, press quotes, Browse All, More to Explore) | none | not a link |
| Poster / large card | click | Movie detail (24) or series detail (29) |
| Category tile | click | Category page (22) |
| Continue Watching card | click | Probably plays the item (not pressed, not seen) |
| Continue Watching card "..." | click | Card menu (14) |
| Hero "Play" | click | Plays (not pressed) |
| Detail > Related poster | click | Another detail page |
| Detail > Cast & Crew headshot | click | Person page (not captured) |
| Detail > Cast & Crew chevron | click | Full cast list (not captured) |
| Any pushed page | Back button, or Cmd-[ | Previous page; the tab keeps its scroll position |

Sidebar items seen (not in scope): Search, Home, Apple TV, MLS, Store; Library: Recently
Added, Movies, TV Shows, 4K HDR, Family Sharing, Genres; account row at the bottom.

## Command map

Menu bar while on this tab, read from accessibility (`AXMenuItemCmdChar`, `AXMenuItemCmdVirtualKey`,
`AXMenuItemCmdModifiers`); dimmed = not available here.
Modifier codes: Cmd = ⌘, Shift-Cmd = ⇧⌘, Opt-Cmd = ⌥⌘.

| Menu | Items (shortcut) |
| --- | --- |
| TV | About TV; Settings… (⌘,); Services >; Hide TV (⌘H); Hide Others (⌥⌘H); Show All; Quit TV (⌘Q); Quit and Keep Windows (⌥⌘Q) |
| File | New >; Close (⌘W, dimmed); Close All (⌥⌘W); Library >; Import… (⌘O); Show in Finder (⇧⌘R, dimmed); Convert > |
| Edit | Undo, Redo, Cut, Copy, Paste, Select All (dimmed); AutoFill >; Start Dictation; Emoji & Symbols |
| Actions | Download; Remove Download; Mark as Watched; Video Quality >; Add to Playlist >; Get Info… (⌘I); Show Movie in Library; Show in Playlist >; Share >; Remove from Playlist; Delete from Library (all dimmed with nothing selected) |
| View | Sort By >; Show View Options (⌘J); Find (⌥⌘F); Show Status Bar (⌘/); Enter Full Screen (fn-F) (all dimmed on this tab) |
| Controls | Play (Space); Next (⌘→); Previous (⌘←); Increase Volume (⌘↑); Decrease Volume (⌘↓); Back (⌘[) |
| Account | account name and email (dimmed); Account Settings…; Authorisations >; Sign Out; Redeem…; Check for Available Downloads… |
| Window | Minimise (⌘M); Minimise All (⌥⌘M); Zoom; Zoom All; Fill; Centre; Move & Resize >; Full-Screen Tile >; TV (⌘0); Activity (⌥⌘L); Bring All to Front; Arrange in Front |
| Help | TV Help (⌘?); Keyboard Shortcuts; Apple Service and Support |

Card menu (14): Download, Go to Episode, Go to Show, Remove from Watchlist, Mark as Watched,
Remove from Recently Watched, Share >.

## Data model guess

| Noun | Fields seen |
| --- | --- |
| Page (tab, category) | title, hero (list of features), ordered list of shelves |
| Hero feature | item ref, backdrop video or image, title logo, badge text, metadata line, synopsis, status line, primary action label (Play / Resume S3, E1 / Play Again / Play Episode), on-watchlist flag |
| Shelf | title, optional subtitle, style (16:9 progress, poster, ranked poster, large card, spotlight, quote, category tile, app link), has See All, items |
| Item (movie / series) | id, type, title, title logo, poster 2:3, backdrop 16:9, genres, content rating, year, runtime, critic score, synopsis (short, long), video badges (4K, HD, Dolby Vision, Atmos), access badges (CC, SDH, AD), cast & crew, studio, region, languages (original, audio, subtitles), related items, trailers, bonus content, how-to-watch offers |
| Episode | season number, episode number, title, synopsis, runtime, thumbnail, progress |
| Progress (Continue Watching) | item ref, episode ref, position or remaining time, "new" or "now available" flag |
| Person | headshot, name, role (character or job) |
| Category | title, tint colour, artwork, page |
| Watchlist | ordered item refs |
| Rank (Top 10) | position 1-10, caption (genre or type) |
