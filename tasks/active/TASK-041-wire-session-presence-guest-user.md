# TASK-041: Wire session presence (no fake data) + a generic guest user

**Phase:** FB — Functional board · **Severity:** MEDIUM · **Size:** small · **Depends on:** none · **Source:** user request (2026-06-26)

## User story
As a **coach**, I want **the top-right presence avatars in the session view to show me (or a stable guest identity), not invented placeholder people** so that **the board reflects who is actually here and free/not-signed-up users still get a real identity instead of fake collaborators**.

## Why this matters
The redesigned top bar ships hardcoded fake presence. `TopBar` renders three baked-in avatars — `"CR"` (with a live dot), `"JM"`, and `"+3"` — that correspond to no real users and no real presence ([Components.swift:103-110](../../Ludi%20Boards/Redesign/Components.swift)). `EngineTopBar` gates those avatars on `BEO.isLoggedIn` ([Components.swift:135](../../Ludi%20Boards/Redesign/Components.swift)), so in the free/local build presence is hidden entirely and in any logged-in build it shows invented people. Either way the user sees nothing true.

Meanwhile a real local identity already exists but the top bar never reads it: `BEO` has `@AppStorage` `currentUserId` / `currentUserName` ([BoardEngineObject.swift:60-61](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift)), and CoreEngine already synthesizes a stable guest identity when those are empty ([CanvasView.swift:65-69](../../CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/CanvasView.swift)) using `generateRandomUserId()` / `generateRandomName()` ([FireUser.swift:11-41](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECFirebase/FireUser.swift)). Desired state: the top-right shows the current user (real or guest) with correct initials and a live dot, no fake names, and no Firebase presence required yet.

## Findings / current state
- [`Ludi Boards/Redesign/Components.swift:103-110`](../../Ludi%20Boards/Redesign/Components.swift) — **fake data.** `TopBar` hardcodes three `PresenceAvatar`s: `"CR"` (live), `"JM"`, `"+3"`. None are wired to a user or to real presence. Change: remove the literals; render the current user's initials from `BEO.currentUserName` instead.
- [`Ludi Boards/Redesign/Components.swift:127-146`](../../Ludi%20Boards/Redesign/Components.swift) — **missing wiring.** `EngineTopBar` passes `showPresence: BEO.isLoggedIn` and forwards no user data, so the only thing the bar can ever show is the hardcoded trio (and only when logged in). Change: pass the current user's name/initials/live flag down to `TopBar`; show it whether or not logged in.
- [`Ludi Boards/Redesign/Components.swift:69-123`](../../Ludi%20Boards/Redesign/Components.swift) — `TopBar` is a pure (engine-free) view with a `showPresence: Bool`. Change: replace the hardcoded `HStack` with a parameter (e.g. a current-user descriptor) so the pure view stays dumb and `EngineTopBar` supplies the data.
- [`Ludi Boards/Redesign/Components.swift:15-38`](../../Ludi%20Boards/Redesign/Components.swift) — `PresenceAvatar` already takes `initials: String`, a gradient `fill`, and a `live` flag. Reusable as-is; it has no name→initials logic, so the caller must compute initials.
- [`Ludi Boards/Redesign/Panels.swift:386-389`](../../Ludi%20Boards/Redesign/Panels.swift) — the existing initials pattern: first char of the first two space-split words, uppercased. Reuse this exact logic for the presence avatar; do not invent a second initials algorithm.
- [`Ludi Boards/CanvasEngine/BoardEngineObject.swift:59-62`](../../Ludi%20Boards/CanvasEngine/BoardEngineObject.swift) — `BEO` already holds `@AppStorage` `isLoggedIn`, `currentUserId`, `currentUserName`. These are the source of truth the bar should read.
- [`CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/CanvasView.swift:65-69`](../../CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/CanvasView.swift) — existing guest-identity synthesis: when `currentUserId.isEmpty`, it sets `currentUserId = generateRandomUserId()` and `currentUserName = generateRandomName()`. This runs in the CanvasView path only; the redesign top bar does not depend on it firing. Change: guarantee the same synthesis happens before the top bar reads the name (see open questions for where).
- [`CoreEngine/Sources/CoreEngine/ECDatabase/ECFirebase/FireUser.swift:11-41`](../../CoreEngine/Sources/CoreEngine/ECDatabase/ECFirebase/FireUser.swift) — `generateRandomUserId()` (e.g. `"James-4821"`) and `generateRandomName()` (e.g. `"Harper Wilson"`). Reuse these; do not add a new generator.

## Scope
**In scope:**
- Add an initials helper (reusing the [Panels.swift:386-389](../../Ludi%20Boards/Redesign/Panels.swift) logic) so a user name maps to a 2-char avatar.
- Wire `EngineTopBar` → `TopBar` to render the **current user** in the top-right: initials from `BEO.currentUserName`, with the live dot.
- Remove the hardcoded `"CR"` / `"JM"` / `"+3"` avatars.
- Guarantee a stable guest identity for not-signed-up users: when `BEO.currentUserId` / `currentUserName` is empty, synthesize one via the existing `generateRandomUserId()` / `generateRandomName()` so the avatar always has a real name to show.
- Show the current user regardless of `isLoggedIn` (free build shows the guest user, not nothing).

**Out of scope (Firebase wiring is OUT everywhere — Firebase-ready only):**
- Any Firebase presence / collaborator list (who else is on the board). The bar should be **structured to accept** a collaborator array later, but must not read or write Firebase now (that's RD-6).
- The multi-user `"+N"` overflow count — only meaningful for logged-in multi-user boards; defer with the collaborator work.
- A sign-up / login flow, account UI, or persisting identity to a backend.
- Roster / squad name in the breadcrumb (`"U-12 Squad"` is RD-5).
- Recording (`BEO.isRecording`) and share — already wired / separate tasks.

## Files expected to change
- `Ludi Boards/Redesign/Components.swift` (`TopBar`, `EngineTopBar`, optional initials helper)
- Possibly one of: `Ludi Boards/CanvasEngine/BoardEngineObject.swift` (init / `ensureDefaultActivityPlan`) — only if the guest-identity guarantee lands there rather than in the top bar's `onAppear` (see open questions).

## Acceptance criteria
- [ ] The hardcoded `"CR"`, `"JM"`, and `"+3"` avatars no longer exist anywhere in `TopBar`.
- [ ] On a fresh free/not-signed-up build, the top-right shows exactly one avatar whose initials are derived from `BEO.currentUserName`.
- [ ] When `currentUserId` / `currentUserName` start empty, a guest identity is synthesized via `generateRandomUserId()` / `generateRandomName()` before the avatar renders, and the avatar shows non-empty initials (never blank, never a literal placeholder).
- [ ] The synthesized guest identity is **stable** across view re-renders within a session (it is not regenerated on every `body` evaluation — it persists in the `@AppStorage` fields).
- [ ] Initials are computed with the same logic as [Panels.swift:386-389](../../Ludi%20Boards/Redesign/Panels.swift) (first char of first two words, uppercased) — e.g. `"Harper Wilson"` → `"HW"`.
- [ ] The current user's avatar shows the live indicator (green dot).
- [ ] No call into Firebase / presence is introduced; the change reads only `BEO` local state.
- [ ] Logged-in behavior is not regressed: when `isLoggedIn` is true the current user still appears (collaborator fan-out remains a later task).

## Verification (build + sim)
1. `/build` clean.
2. iPad sim, scheme **"Ludi Boards"**, bundle **io.ludi.sol**, verified headlessly per the project's background-simulator convention:
   - Launch on a fresh board with no prior identity (empty `currentUserName`); confirm the top-right shows a single avatar with real initials and a live dot — not `"CR"`/`"JM"`/`"+3"`, not blank.
   - Relaunch / re-render and confirm the same guest name/initials persist (identity is stable, not re-rolled).

## Open questions / risks
- **Where to synthesize the guest identity?** Options: `EngineTopBar.onAppear` vs. `BEO.init` / `ensureDefaultActivityPlan()`. **Recommendation:** do it in `BEO` (init or the existing `ensureDefaultActivityPlan` chain) so identity is guaranteed the same way the default board is guaranteed, independent of which view mounts first — `onAppear` on a single bar is too fragile and duplicates the CanvasView path.
- **Show only the current user, or a placeholder for future collaborators?** **Recommendation:** show only the current user now; the `"+N"` overflow is for logged-in multi-user boards and should ship with the Firebase presence work (RD-6).
- **Keep the live (green) dot on the current user?** **Recommendation:** yes — they are the one actively using the board, so a live indicator on self is honest and matches the existing design.
- **Risk:** if synthesis runs inside `body`/a computed property, the guest name will re-roll on every render. Identity must be written once into `@AppStorage` and read thereafter.
- **Risk:** the existing CanvasView synthesis ([CanvasView.swift:65-69](../../CoreEngine/Sources/CoreEngine/ECViewEngine/CanvasEngine/CanvasView.swift)) writes to `self.USER`; confirm that resolves to the same `@AppStorage`-backed identity `BEO` exposes so the two paths don't diverge into two different guest users.

## Outcome (2026-06-26) — DONE (build + render verified)
`TopBar` now renders a single current-user `PresenceAvatar` from `userInitials`/`userLive` instead of the hardcoded CR/JM/+3 trio. `EngineTopBar` computes initials from `BEO.currentUserName` and calls `ensureGuestIdentity()` onAppear — synthesizing a stable guest via `generateRandomUserId()`/`generateRandomName()` when empty. Verified on sim: a generated guest avatar ("LH") shows for a not-signed-up user. Collaborator/Firebase presence remains out (structured to accept later).
