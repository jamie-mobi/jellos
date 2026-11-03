# jellyOS

A Jellyfin client for iOS, iPadOS, macOS and tvOS.

The engineering rules are in `docs/ENGINEERING.md`. Read it before you write
code. If this file and that guide disagree, the guide wins; then fix this file.

## Rules you must follow

### Issues and links

- Each story (for example in `docs/apple-tv-tab/STORIES.md`) is a GitHub issue
  with the `story` label. A new story gets a new issue.
- Each spec file in `docs/spec/` is a GitHub issue with the `spec` label. A new
  spec file gets a new issue.
- Each story issue has a "Specs" section that links every spec issue it needs.
- Each spec issue has an "Implemented by" section that links every story issue
  that implements it.
- When you change a link on one side, change the other side in the same
  session.

### The master task list

- The master task list is GitHub issue #45, "Master task list" (pinned,
  `tracking` label). It is the only task list.
- Keep it up to date. Tick a task in the same change that closes it.
- You may add tasks.
- Never remove a task. When a new task replaces an old one, tick the old one
  and add `superseded by #<n>: <reason>` on its line.
- Each story issue has exactly one line in the list.

Edit it with:

```sh
gh issue view 45 -R jamie-mobi/jellos --json body -q .body > /tmp/tasks.md
# edit /tmp/tasks.md
gh issue edit 45 -R jamie-mobi/jellos --body-file /tmp/tasks.md
```

### Tests

- Every story is test-driven. Write a failing test first, then the code.
- `[unit]` items are Swift Testing tests in the module's test target.
- Every story has UI tests (XCUITest). One class per screen
  (`<Screen>UITests`). Find elements only by `AccessibilityID`. Launch with
  `-ui-test-fixture <name>`.
- **Never run a full UI test suite.** Run only the UI tests you wrote, or the
  classes of the screens you changed. Each `xcodebuild test` call against a UI
  test target must have at least one `-only-testing:` argument:

```sh
xcodebuild test -scheme jellyOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:jellyOSUITests/HomeUITests/test_ATV001_primaryButtonReadsResume
```

- You may run all unit tests: `swift test --package-path Packages/JellyKit`.

### Modules

- The app is modular. All code that is not a view is in its own module in
  `Packages/JellyKit`. The app targets hold only the `@main` `App` type.
- iOS, iPadOS and macOS share one Presentation module: `JellyPresentation`.
- tvOS has its own Presentation module: `JellyPresentationTV`.
- Module map and import rules: `docs/ENGINEERING.md` section 2.

### Build

- Xcode 26, Swift 6 language mode, complete strict concurrency.
- Deployment target 26 on all platforms: iOS, iPadOS, macOS, tvOS.
- No fastlane. CI is `.github/workflows/lint.yml` and
  `.github/workflows/build.yml` (`docs/ENGINEERING.md` section 4.4).
- Run `swiftformat . --lint --config .swiftformat` and
  `swiftlint lint --strict --config .swiftlint.yml` before you push.

### Secrets

- `.env` holds `jellyfin_host` and `jellyfin_api` for live server tests. It is
  git-ignored. Never commit it, print it, or copy its values anywhere.
- The API key has admin rights. Use it only in `JellyIntegrationTests` and
  local debug runs (`docs/ENGINEERING.md` section 4.5).

### Sources

- `docs/openapi.json` is the full Jellyfin API (12.2.0). It is 1.8 MB. Search
  it with `jq` or `grep`; do not read it whole.
- `docs/spec/13-jellyos-decisions.md` overrides `docs/spec/` files 00 to 12.
- Code shape: `docs/templates/README.md` and
  `docs/templates/unittests/README.md`, with the changes in
  `docs/ENGINEERING.md` section 2.5.
- Words: `docs/GLOSSARY.md`.

### Git

- No co-author lines and no AI attribution in commits, PRs or issues.
