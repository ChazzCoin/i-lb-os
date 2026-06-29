**Target.** App Store submission readiness for the **Ludi Boards** target (`io.ludi.sol`, marketing 1.14 / build 14).
**Scope.** project.pbxproj (io.ludi.sol configs), Ludi-Boards-Info.plist, GoogleService-Info.plist(s), Package.resolved (workspace + xcodeproj), CoreEngine/Package.swift, app + CoreEngine source, AppIcon assets, a clean Release build. Multi-target attribution verified (sibling `SouthVision`/`Wrlds` settings excluded).
**Date.** 2026-06-27
**Method.** 8-dimension parallel audit + adversarial verification of every CRITICAL/HIGH (1 refuted).

# Audit — App Store readiness (Ludi Boards / io.ludi.sol)

> **TL;DR.** **Not ready for a clean submission yet — but close.** Two privacy-manifest gaps will get the build flagged/rejected by Apple's automated checks (the app has no `PrivacyInfo.xcprivacy` despite using UserDefaults; a bundled Firebase dependency, GoogleUtilities 7.12.1, ships no manifest → ITMS-91061 upload rejection). Separately, a real **functional** bug: the Firebase config bundled into `io.ludi.sol` is registered to `io.ludi.wrlds` — there is **no** Firebase config for `io.ludi.sol` anywhere, so the app talks to the wrong Firebase project. Everything else (icon, launch screen, Release build, ATS, signing, no IAP, guest-only/no-login path) is clean. Fix the two manifests + the Firebase config and you're submittable.

---

## Verdict

| Area | State |
|---|---|
| Builds for Release | ✅ BUILD SUCCEEDED, 0 errors |
| App icon (1024, no alpha) / launch screen | ✅ compliant |
| Permissions / usage strings | ✅ none required (one *unused* string to remove) |
| Signing / capabilities / entitlements | ✅ correct (no entitlement-requiring capability) |
| ATS / transport security | ✅ clean (HTTPS only) |
| IAP / payments / placeholder content | ✅ none / clean |
| Account deletion & Sign in with Apple | ✅ N/A *if* the guest-only build ships (no login) |
| **App privacy manifest** | ❌ **missing — Apple will flag** |
| **SDK privacy manifests (GoogleUtilities)** | ❌ **missing — ITMS-91061 upload rejection** |
| **Firebase config for io.ludi.sol** | ❌ **wrong bundle id — functional bug** |
| Export-compliance key | ⚠️ missing (per-upload prompt) |

---

## Part 1 — What's ready

- **Release build is green** — `xcodebuild … -scheme "Ludi Boards" -configuration Release` → `** BUILD SUCCEEDED **`, zero errors, full signed bundle. (The one prior failure was host disk-space, not code.)
- **App icon is compliant** — single 1024×1024 universal icon, `hasAlpha: no` (verified via `sips`/IHDR). No transparency → no icon rejection. `Ludi Boards/Assets.xcassets/AppIcon.appiconset/Contents.json`.
- **Launch screen** — generated (`INFOPLIST_KEY_UILaunchScreen_Generation = YES`), not blank.
- **No permissions actually used** — no camera/mic/location/contacts/calendar/Bluetooth APIs reachable. The scout's scary `NSCameraUsageDescription="AR/VR"` belongs to the **Wrlds** target, *not* `io.ludi.sol` (verified).
- **No entitlements needed** — no Push, Sign in with Apple, Associated Domains, iCloud, Background Modes, App Groups, or Keychain sharing. Absence of a `.entitlements` file is correct.
- **No IAP, no paywall, no placeholder/beta content** in the shipped path. `ShareLink` is plain text, not multiplayer UGC, so Guideline 1.2 isn't triggered.
- **Guest-only release path** — `@main → RedesignRootView → TacticalBoardView` auto-synthesizes a guest identity; no login wall, so no demo account needed and 5.1.1(v)/4.8 don't bite *as shipped*.
- **ATS clean** — no `NSAllowsArbitraryLoads`/exceptions; Firebase is HTTPS.
- **Debug scaffolding is `#if DEBUG`-gated** — `REDESIGN_SEED`/`LEGACY_BOARD`/roster seeds/state-switcher are all unreachable in Release.
- **Firebase version itself is fine** — 10.29.0 (operative), past the 10.24 manifest threshold; Firebase/Realm/abseil/grpc ship signed manifests.

---

## Part 2 — Findings (verified)

```
▌ HIGH      ·  (no PrivacyInfo.xcprivacy) — app target
  The app uses the UserDefaults required-reason API (UserDefaults.standard.set
  at BoardEngineView.swift:216/:284; @AppStorage ~191 sites incl. CoreEngine
  CanvasObject.swift:14-25, BoardEngineObject.swift:58-74) but ships NO
  PrivacyInfo.xcprivacy on the io.ludi.sol target. Apple's automated check emails
  ITMS-91053 / can reject after upload. (Verified CRITICAL→HIGH: it's an Apple
  email + approval-blocker, not an upload hard-stop.)
  └─ add PrivacyInfo.xcprivacy to the target: NSPrivacyAccessedAPICategoryUserDefaults,
     reason "CA92.1"; add it to the target's Copy Bundle Resources

▌ HIGH      ·  Package.resolved — GoogleUtilities 7.12.1 (transitive Firebase dep)
  GoogleUtilities 7.12.1 is linked into the io.ludi.sol binary (GULUserDefaults
  etc. in build products) and ships NO .xcprivacy (manifest added in 7.13.0). It
  uses required-reason APIs (UserDefaults C617.1, file timestamp, disk space, boot
  time). GoogleUtilities is on Apple's "commonly used SDK" list → ITMS-91061
  "Missing privacy manifest" is a HARD upload rejection.
  └─ force-resolve GoogleUtilities ≥ 7.13.0. NOTE: bumping Firebase alone does NOT
     fix it — firebase 10.29 constrains GoogleUtilities to 7.12.1..<8.0 and the
     resolver picked the floor. Add an explicit GoogleUtilities ≥7.13.0 dep/override
     (and re-resolve), then confirm a .xcprivacy ships in its checkout.

▌ HIGH      ·  GoogleService-Info.plist (functional, not store-review)
  The GoogleService-Info.plist the Ludi Boards target BUNDLES (repo root) is
  registered to BUNDLE_ID io.ludi.wrlds; the "Ludi Boards/GoogleService-Info.plist"
  is io.ludi.boards. NO Firebase config anywhere matches io.ludi.sol. The app
  initializes Firebase against the wrong project's GOOGLE_APP_ID — Auth/RTDB/Storage
  route to the wrong backend (Firebase only logs a bundle-id warning, doesn't stop).
  └─ download the GoogleService-Info.plist for the io.ludi.sol app from the Firebase
     console, bundle THAT, remove the duplicate plists from the target's Resources

▌ MEDIUM    ·  gtm-session-fetcher 3.1.1 / promises 2.3.1 / nanopb (Firebase transitive)
  Same SDK-manifest gap as GoogleUtilities (manifests added in gtm 3.4.0 / promises
  2.4.0). Also linked, also on the named-SDK radar.
  └─ resolve up alongside the GoogleUtilities fix; re-verify each checkout has .xcprivacy

▌ MEDIUM    ·  Two divergent Package.resolved files
  Ludi Boards.xcodeproj/project.xcworkspace/.../Package.resolved pins Firebase
  10.18.0 (PRE-manifest); the workspace one pins 10.29.0 (operative). CoreEngine
  Package.swift floor is "from: 10.18.0", so a clean checkout could resolve the
  non-compliant set.
  └─ delete/regenerate the stale xcodeproj Package.resolved; raise CoreEngine's
     Firebase floor to ≥10.25.0

▌ MEDIUM    ·  ITSAppUsesNonExemptEncryption not declared
  Not set anywhere for io.ludi.sol. App uses only standard HTTPS/TLS (exempt).
  Every upload stalls on the export-compliance question (not a rejection).
  └─ add <key>ITSAppUsesNonExemptEncryption</key><false/> to Ludi-Boards-Info.plist
     (or INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO on both io.ludi.sol configs)

▌ MEDIUM    ·  project.pbxproj:1484/1520 — NSPhotoLibraryAddUsageDescription unused
  "SOL will save screenshots of Activity Plans." is declared, but no save-to-photos
  code exists (saveImageToDocuments writes to Documents, not Photos). Unused
  permission strings draw 5.1.1 scrutiny.
  └─ remove the string, OR wire up the actual UIImageWriteToSavedPhotosAlbum feature

▌ MEDIUM    ·  Account-deletion / Sign in with Apple — latent
  Firebase email/password signup exists (UserTools.swift:257-284) with NO account-
  deletion path, but it's DEAD in Release (only reachable via legacy CanvasEngine
  behind DEBUG LEGACY_BOARD=1). Only a problem if the ASC listing declares accounts
  or the dead code is revived.
  └─ confirm App Store Connect says "no account creation"; ideally strip the dead
     auth UI. If accounts ever ship: add Auth user.delete()+RTDB cleanup AND
     Sign in with Apple.

▌ LOW       ·  Housekeeping (no store impact)
  • GoogleAppMeasurement has no manifest BUT is NOT linked (FirebaseAnalytics import
    is commented out, not in build products) — REFUTED as a blocker, no action.
  • Stale group:Pods/Pods.xcodeproj ref in the workspace (no CocoaPods) — remove.
  • Dead CoreLocation (AppLocation.swift) + dead UIImagePicker (ImagePicker.swift)
    — never instantiated; delete so they don't imply unused permissions.
  • Committed Firebase API key — normal for client config; restrict it in GCP console.
  • GENERATE_INFOPLIST_FILE=YES + INFOPLIST_FILE both set — harmless (Xcode merges),
    but means config lives in two places; add new keys deliberately.
  • PortraitUpsideDown in orientations (no iPhone/iPad split) — cosmetic.
  • ~68 deprecated onChange(of:perform:) + CGPoint:Hashable/Swift-6 warnings — fine
    on Swift 5 / iOS 17; clean up before adopting Swift 6 mode.
  • Missing AppIcon-Board asset (Components.swift:91) falls back — add the image.
```

---

## Part 3 — App Store Connect side (not in the repo — your checklist)

The code can't tell me these; confirm before you submit:
- **App Privacy "Nutrition Labels"** questionnaire — you collect user id/name via Firebase Auth/RTDB; fill it in and keep it consistent with the privacy manifest.
- **Build number uniqueness** — confirm build **14** wasn't already uploaded for version 1.14 (must be unique & increasing). Bump if so.
- **Screenshots** (iPad + iPhone, since `TARGETED_DEVICE_FAMILY = 1,2`), description, keywords, support URL, **privacy policy URL** (required).
- **Age rating** questionnaire.
- **"Sign-in required?"** answer = No (guest-only) → no demo account needed. If you flip to a login build, supply demo credentials.
- Distribution cert exists for team **248J2GKL56** and an `io.ludi.sol` App ID is registered.

---

## Bottom line

You're one focused pass from submittable. The **must-do-before-submit** set is small and mechanical: (1) add an app `PrivacyInfo.xcprivacy` (UserDefaults reason), (2) force GoogleUtilities ≥ 7.13.0 so it carries its manifest (+ gtm/promises/nanopb come along), and (3) bundle the **correct** `io.ludi.sol` Firebase config — that last one is a real runtime bug, not just paperwork. Then knock out the should-fixes (export-compliance key, stale Package.resolved + Firebase floor, remove the unused photo string). Build, asset, signing, networking, and guideline posture are all already clean.

**Adjacent observation.** The biggest latent risk over time is the dead Firebase auth code: it's safe today only because Release routes to the guest-only redesign path. If anyone re-enables it without an account-deletion flow + Sign in with Apple, the next submission gets rejected. Worth deleting outright.
