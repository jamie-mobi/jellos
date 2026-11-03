# jellyOS Engineering Guide

This document governs how jellyOS is built. It covers the architecture, the
modules, the tests, the work flow, and the architecture documents.

If another document disagrees with this one, this one wins. Change this
document first, in its own commit, then change the code.

Related documents:

| Document | Use it for |
| --- | --- |
| `CLAUDE.md` | The short list of rules that every change must follow |
| `docs/templates/README.md` | Code shape per layer, and the copy-from templates |
| `docs/templates/unittests/README.md` | Unit test shape |
| `docs/GLOSSARY.md` | One name per thing |
| `docs/openapi.json` | The full Jellyfin API (12.2.0). The only source for endpoints and DTO fields |
| `docs/spec/` | How Swiftfin uses the Jellyfin API, plus jellyOS decisions in `13-jellyos-decisions.md` |
| `docs/apple-tv-tab/STORIES.md` | The Apple TV tab stories (`ATV-`) |
| `docs/STORIES.md` | The main backlog (`S-`) that the ATV stories build on |
| `docs/adr/` | Architecture decision records |

---

## 1. Platforms

jellyOS runs on iOS, iPadOS, macOS and tvOS.

- iOS, iPadOS and macOS share one Presentation module.
- tvOS has its own Presentation module.
- All four platforms share every non-view module.

Note: `docs/spec/13-jellyos-decisions.md` section 1 lists iOS, iPadOS and tvOS.
macOS was added on 2026-11-03. This document is the current platform list.

Toolchain floor: Swift 6.2, Xcode 26, iOS 18, iPadOS 18, macOS 15, tvOS 18.
The floor comes from `docs/templates/README.md` ("Toolchain floor").

---

## 2. Modules

### 2.1 The rule

**All code that is not a view is in its own module.** The app targets hold
only the `@main` `App` type and the asset catalogue. A view module holds only
SwiftUI views and the code that maps service state to those views.

All modules are targets of one Swift package at `Packages/JellyKit`.

### 2.2 Module map

| Module | Holds | Imports | Platforms |
| --- | --- | --- | --- |
| `JellyDomain` | Domain models, feature `Error` enums, use cases (`enum` of `static func`) | Foundation only | all |
| `JellyData` | The shared networking stack (one `send`, URL catalogue, coder, error protocol, token provider), DTOs from `docs/openapi.json`, `*Request` builders, `*HTTPTransport`, repositories | `JellyDomain` | all |
| `JellyServices` | `@MainActor @Observable final class *Service` types, `SingleFlightRefreshing`, the item store | `JellyDomain`, `JellyData` | all |
| `JellyPlayback` | AVPlayer engine, `DeviceProfile`, `PlaybackInfo` resolution, progress reporting, Now Playing | `JellyDomain`, `JellyData` | all |
| `JellyComposition` | The composition root. It builds the real object graph, or the fixture graph for UI tests. Its public API exposes only services and domain types, never `JellyData` types. The fixture branch is inside `#if DEBUG` | all non-view modules, `JellyMocks` | all |
| `JellyMocks` | `Mock*` doubles and fixture data for previews and UI tests. All code is inside `#if DEBUG` | `JellyDomain`, `JellyData`, `JellyServices` | all |
| `JellyAccessibility` | The `AccessibilityID` constants. UI tests import this module too | none | all |
| `JellyPresentationCore` | SwiftUI glue that both Presentation modules use and that is not a screen: `@Entry` environment keys, `ViewModifier`s, design tokens (`AppSpacing` and the token enums), image loading helpers | `JellyServices`, `JellyDomain`, `JellyAccessibility`, `JellyComposition` (for `@Entry` defaults), `JellyMocks` (previews only) | all |
| `JellyPresentation` | Screens and views for iOS, iPadOS and macOS | `JellyPresentationCore`, `JellyServices`, `JellyDomain`, `JellyAccessibility`, `JellyMocks` (previews only) | iOS, iPadOS, macOS |
| `JellyPresentationTV` | Screens and views for tvOS | `JellyPresentationCore`, `JellyServices`, `JellyDomain`, `JellyAccessibility`, `JellyMocks` (previews only) | tvOS |

App targets:

| Target | Platforms | Links |
| --- | --- | --- |
| `jellyOS` | iOS, iPadOS, macOS | `JellyComposition`, `JellyPresentation` |
| `tvJelly` | tvOS | `JellyComposition`, `JellyPresentationTV` |

### 2.3 Dependency direction

Each module may import only the modules in its "Imports" column in section
2.2. In order, from the bottom:

1. `JellyDomain`, `JellyAccessibility`
2. `JellyData`
3. `JellyServices`, `JellyPlayback`
4. `JellyMocks`
5. `JellyComposition`
6. `JellyPresentationCore`
7. `JellyPresentation`, `JellyPresentationTV`

Rules:

1. A module imports only modules from a lower step, and only those in its
   "Imports" column. No other import is allowed.
2. `JellyDomain` never imports SwiftUI, UIKit, AppKit, AVFoundation or
   Observation.
3. `JellyData`, `JellyServices`, `JellyPlayback`, `JellyMocks` and
   `JellyComposition` never import SwiftUI.
4. A Presentation module never imports `JellyData`. It sees services and
   domain types only. `JellyComposition` exposes no `JellyData` type, so
   importing it does not break this rule.
5. A Presentation module uses `JellyMocks` only inside `#if DEBUG`, for
   `#Preview`. All of `JellyMocks` is inside `#if DEBUG`, so a release build
   that uses it outside `#if DEBUG` does not compile.
6. `JellyPresentation` and `JellyPresentationTV` never import each other.
   Code that both need moves down to `JellyPresentationCore`, or to a
   non-view module if it is not view code.
7. A new module needs an ADR (section 7).

### 2.3.1 Platform guards

SwiftPM cannot limit a target to some platforms. `swift build` and
`swift test` on a Mac compile every target for macOS. So:

- Each file in `JellyPresentation` starts with `#if os(iOS) || os(macOS)` and
  ends with `#endif`. (`os(iOS)` includes iPadOS.)
- Each file in `JellyPresentationTV` starts with `#if os(tvOS)` and ends with
  `#endif`.
- The app targets link each module only on its platforms, with
  `.when(platforms:)` in the package and the target's platform filters in
  Xcode.

### 2.4 What goes where

| You are adding | Module | Template |
| --- | --- | --- |
| A value type for a feature | `JellyDomain` | `Domain/DomainModelTemplate.swift` |
| A decision a view makes (order, filter, label text, which state to show, which item focuses next) | `JellyDomain`, as a use case | `Domain/UseCaseTemplate.swift` |
| A DTO for an endpoint in `docs/openapi.json` | `JellyData` | `Data/DTOTemplate.swift` |
| A request builder, transport or repository | `JellyData` | `Data/RequestTemplate.swift`, `Data/TransportTemplate.swift`, `Data/RepositoryTemplate.swift` |
| A screen's state and intents | `JellyServices` | `Services/ServiceTemplate.swift` |
| Anything that touches AVPlayer or reports playback | `JellyPlayback` | `Services/ServiceTemplate.swift` |
| A `Mock*` for previews or UI tests | `JellyMocks` | `Infrastructure/MockTemplate.swift` |
| Wiring a service into `@Environment` | `JellyPresentationCore` | `Presentation/EnvironmentKeyTemplate.swift` |
| A screen or view for iOS, iPadOS or macOS | `JellyPresentation` | `Presentation/ScreenTemplate.swift`, `Presentation/ViewTemplate.swift` |
| A screen or view for tvOS | `JellyPresentationTV` | the same templates |

### 2.5 Changes to the template rules

The rules in `docs/templates/README.md` apply, with these changes:

| Template rule | Change | Why |
| --- | --- | --- |
| 2. Layers: Domain, Data, Services, Presentation | Each layer is a module (section 2.2), so the compiler enforces the layers | The user requires that all non-view code is in its own module |
| 24. `Mock*` lives in the app target | `Mock*` lives in `JellyMocks`, inside `#if DEBUG` | The app target holds no non-view code |
| 23. The `@Entry` default is the real service, built by `AppDependencies` | The `@Entry` keys live in `JellyPresentationCore`. The default calls a factory in `JellyComposition` | The environment key file is SwiftUI code, so it cannot live in `JellyComposition`. The factory returns a service, so no `JellyData` type reaches a Presentation module |
| 25. Mocks are substituted under `#if TESTING` | The app target reads the launch argument `-ui-test-fixture <name>` inside `#if DEBUG` and passes the fixture name to `JellyComposition` | SwiftPM can only make a setting depend on the `debug` or `release` configuration. A custom `TESTING` condition set in Xcode does not reach package targets. SwiftPM defines `DEBUG` for debug builds, so `#if DEBUG` works in every module |

---

## 3. API and specs

1. `docs/openapi.json` is the only source for paths, query keys, request
   bodies and DTO fields. Search it with `jq` or `grep`. Do not read it whole.
2. `docs/spec/` tells you how Swiftfin calls the API and what can go wrong.
   Use it for behaviour: timeouts, retries, reporting order, image URLs.
3. `docs/spec/13-jellyos-decisions.md` overrides files 00 to 12 where they
   disagree.
4. Each spec file has a GitHub issue with the `spec` label. Each story issue
   links to the spec issues it needs. Each spec issue lists the stories that
   implement it (section 5.3).

---

## 4. Tests

### 4.1 Every story is test-driven

Write the test first. See it fail. Write the least code that makes it pass.
Then clean up. Repeat for each acceptance item.

| Story tag | Test | Where | Written |
| --- | --- | --- | --- |
| `[unit]` | Swift Testing `@Test` | the test target of the module that holds the logic | before the code |
| `[snap]` | XCUITest assertions on element presence, labels and order, plus `#Preview` variants (template rule 22) | the UI test target | before the view |
| `[self]` | XCUITest that drives the behaviour (scroll, click, keys, timers through an injected clock) | the UI test target | before the view |
| `[manual]` | XCUITest where the result can be seen in the UI (for example: the player screen shows). A manual check only for what XCUITest cannot see, such as video output | the UI test target, then a manual note in the PR | before the view |

### 4.2 Unit tests

- Swift Testing only. Follow `docs/templates/unittests/README.md`.
- Each non-view module has a test target: `JellyDomainTests`,
  `JellyDataTests`, `JellyServicesTests`, `JellyPlaybackTests`,
  `JellyCompositionTests`.
- Unit tests are fast. You may run all of them:

```sh
swift test --package-path Packages/JellyKit
```

### 4.3 UI tests

Every story has UI tests. UI tests use XCTest (`XCUIApplication`), because
Swift Testing cannot drive a UI.

Targets:

| Target | Tests | Destinations |
| --- | --- | --- |
| `jellyOSUITests` | `JellyPresentation` screens | iOS Simulator, iPadOS Simulator, macOS |
| `tvJellyUITests` | `JellyPresentationTV` screens | tvOS Simulator |

Rules:

1. **One test class per screen**, named `<Screen>UITests`, for example
   `HomeUITests`, `MovieDetailUITests`, `SeeAllUITests`. A changed screen maps
   to exactly one class.
2. **One test method per acceptance item**, named after the story:
   `test_ATV001_primaryButtonReadsResume()`.
3. **Find elements by accessibility identifier only.** Identifiers come from
   `JellyAccessibility.AccessibilityID` and have the form
   `<screen>.<element>[.<index>]`, for example `home.hero.primaryButton`.
   Never find an element by its visible text, because the text is localized.
4. **Launch with a fixture.** Each test launches the app with
   `-ui-test-fixture <name>`. The fixture graph in `JellyMocks` serves fixed
   items, so tests never need a server.
5. **No sleeps.** Wait with `waitForExistence(timeout:)` or an
   `XCTNSPredicateExpectation`. Time-based behaviour (for example the 8 s hero
   auto-advance) uses a clock injected by the fixture, not real time.
6. **Never run a full UI test suite.** Run only the UI tests you wrote, or the
   classes of the screens you changed:

```sh
# One new test
xcodebuild test -scheme jellyOS \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:jellyOSUITests/HomeUITests/test_ATV001_primaryButtonReadsResume

# A changed screen (one class)
xcodebuild test -scheme jellyOS \
  -destination 'platform=macOS' \
  -only-testing:jellyOSUITests/HomeUITests
```

   Each `xcodebuild test` call against a UI test target must have at least one
   `-only-testing:` argument.

### 4.4 Previews

Every view has a `#Preview` inside `#if DEBUG`, with the empty, long-text and
no-image variants (template rule 22). Previews use `JellyMocks`.

---

## 5. Work flow

### 5.1 GitHub issues

| Label | Meaning |
| --- | --- |
| `story` | One story from `docs/apple-tv-tab/STORIES.md` (or a later story file) |
| `spec` | One spec file from `docs/spec/` |
| `tracking` | The master task list |
| `M1-home`, `M2-details`, `M3-discover`, `M4-polish` | The story milestone |
| `tvOS` | Work for `JellyPresentationTV` |

GitHub milestones `M1 Home`, `M2 Details`, `M3 Discover` and `M4 Polish` hold
the story issues.

### 5.2 The master task list

The master task list is the pinned GitHub issue #45 with the `tracking` label,
titled "Master task list". It is the only task list. Do not copy it into the
repository.

1. Keep it up to date. Tick a task in the same change that closes it.
2. You may add a task. Add a line, with an issue link when the task has an
   issue.
3. Never remove a task. When a new task replaces an old one, tick the old one
   and add a note on the same line: `superseded by #<n>: <reason>`.
4. Each story issue has exactly one line in the list.

### 5.3 Links between stories and specs

- A story issue has a "Specs" section with one link per spec issue it needs.
- A spec issue has an "Implemented by" section with one link per story issue.
- When you change one side, change the other side in the same session.
- When you add a story, link its specs and update each spec issue.

### 5.4 Doing one story

1. Read the story issue, its spec issues, and the matching screens in
   `docs/apple-tv-tab/screens/INDEX.md`.
2. Make a branch: `story/ATV-001-featured-hero`.
3. For each acceptance item: write the failing test (section 4), make it pass,
   clean up.
4. Build the views in `JellyPresentation`. tvOS views are separate tasks
   (section 5.5).
5. Run all unit tests, and only the new or changed UI tests.
6. Open a PR with `Closes #<story issue>`. List the UI tests you ran.
7. Tick the story in the master task list.

### 5.5 tvOS

Each ATV story delivers the non-view modules and the `JellyPresentation` UI.
The tvOS UI for a story is a later task in the master task list, with its own
issue labelled `tvOS`. That issue reuses the same services and use cases and
adds only `JellyPresentationTV` views and `tvJellyUITests` tests.

### 5.6 Definition of done

A story is done when all of these are true:

- [ ] Each `[unit]` item has a Swift Testing test, written first, that passes.
- [ ] Each `[snap]`, `[self]` and `[manual]` item has an XCUITest, or a PR note
      that says why XCUITest cannot see it.
- [ ] All unit tests pass.
- [ ] The new and changed UI test classes pass. No full UI suite was run.
- [ ] No non-view code is in a Presentation module or an app target.
- [ ] Every new view has a `#Preview` with the empty, long-text and no-image
      variants.
- [ ] UI text uses the words in `docs/GLOSSARY.md`.
- [ ] The story issue is closed and ticked in the master task list.

---

## 6. Code rules

The rules in `docs/templates/README.md` and
`docs/templates/unittests/README.md` apply to all code, with the changes in
section 2.5. In short:

- MV, not MVVM. A service is the only writer of observable state.
- Swift Concurrency only. Network and decode never run on the main actor.
- Typed throws at every boundary. One minimal `Error` enum per feature.
- No comments in a body. One type per file.
- Exhaustive `switch`, no `default`. No prefix `!`.
- User-facing text uses `String(localized:)`.
- Design tokens, not literal sizes or colours.

---

## 7. Architecture documents

| Document | Path | When |
| --- | --- | --- |
| This guide | `docs/ENGINEERING.md` | Change it when a rule changes |
| Architecture decision record (ADR) | `docs/adr/NNNN-short-title.md` | Write one for each decision that is hard to reverse: a new module, a new dependency, a change to a layer rule, a new platform |
| Deliberate constraints | Section 8 of this guide | Each exception to a code rule, with its reason |
| Glossary | `docs/GLOSSARY.md` | Add a word before you use it in UI text or a type name |

An ADR has these sections: Status, Context, Decision, Consequences. Number
ADRs in order and never reuse a number. To replace an ADR, write a new one and
set the old one's Status to "Superseded by NNNN".

---

## 8. Deliberate constraints

Each exception to a code rule is listed here, with its reason.

| Exception | Where | Reason |
| --- | --- | --- |
| File-level `#if os(...)` around every Presentation file | `JellyPresentation`, `JellyPresentationTV` | SwiftPM cannot limit a target to some platforms (section 2.3.1) |
