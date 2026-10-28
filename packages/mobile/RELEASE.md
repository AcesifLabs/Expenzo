# Android Release Guide (Fastlane + GitHub Actions)

This document describes the Android release process for `packages/mobile`.

## 1) GitHub Environments and Secrets

### `mobile-internal`

Required secrets:

- `ENV_PROD` - Base64 encoded content of `packages/mobile/.env.prod`
- `KEYSTORE_BASE64` - Base64 encoded Android release/upload keystore
- `KEY_ALIAS` - Keystore alias
- `KEY_PASSWORD` - Key password
- `KEY_STORE_PASSWORD` - Keystore password
- `PLAY_STORE_JSON_KEY` - Google Play service account JSON (raw JSON string)
- `SENTRY_AUTH_TOKEN` - Optional. Sentry auth token with `project:releases` scope; when set, the deploy job uploads the Dart symbols so crash reports show readable stack traces

Variables (not secrets), needed with `SENTRY_AUTH_TOKEN`:

- `SENTRY_ORG` - Sentry organization slug
- `SENTRY_PROJECT` - Sentry project slug

Release builds are obfuscated (`--obfuscate --split-debug-info=build/symbols`). The deploy job keeps `build/symbols` and the R8 `mapping.txt` as a workflow artifact and sends the mapping to Play with the upload. Keep the artifact: without it, stack traces from that release can't be read.

### `mobile-production`

Required secrets:

- `PLAY_STORE_JSON_KEY` - Google Play service account JSON (raw JSON string)

Recommended protection:

- Enable **required reviewers** for `mobile-production`.

## 2) Release Tag Format

Release tags must use:

`mobile-v<version>+<build-number>`

Example:

`mobile-v1.2.3+45`

Mapping:

- `1.2.3` -> Android `versionName`
- `45` -> Android `versionCode`

`versionCode` must always increase for Play Console uploads.

## 3) Prepare a Release Branch

Create a release PR branch (no tag yet):

```bash
./scripts/release.sh prepare v1.2.3+45
```

This creates and pushes:

`release/mobile-v1.2.3+45`

Then open a PR from `release/mobile-v1.2.3+45` to `main` and merge it.

## 4) Publish the Release Tag (After Merge)

After the release PR is merged to `main`, publish the release tag:

```bash
git checkout main
git pull origin main
./scripts/release.sh publish v1.2.3+45
```

This creates and pushes:

`mobile-v1.2.3+45`

The tag push triggers `.github/workflows/deploy-android.yml`.

### Why tagging happens after merge

The deploy workflow validates that the tag commit is reachable from `origin/main`. If you tag before merge, the workflow can fail this guard.

## 5) What the Internal Release Workflow Does

On tag push (`mobile-v*`), the workflow:

1. Validates tag format
2. Verifies the tag commit is reachable from `origin/main`
3. Runs quality gates in `packages/mobile`:
   - `dart format --output=none --set-exit-if-changed .`
   - `flutter analyze --no-fatal-infos`
   - `flutter test`
4. Decodes `.env.prod` and `release.jks`
5. Runs `fastlane beta` to build and upload a signed AAB to Play internal track
6. Uploads the generated AAB as a GitHub Actions artifact

## 6) Promote to Production

Use manual workflow `.github/workflows/promote-android.yml`:

1. Open GitHub Actions -> **Promote Android**
2. Click **Run workflow**
3. Set `release_tag` (for audit), e.g. `mobile-v1.2.3+45`
4. Pick `rollout`:
   - `0.1` promotes the internal build to 10% of production users (`fastlane production`).
   - `0.5` and `1.0` widen that release to 50% and then everyone (`fastlane production_rollout`).
5. Run and approve `mobile-production` environment if required

Promotion never rebuilds the binary. Tick the **Release gates** below before each step.

### Release gates

Before each rollout step (10% → 50% after 24 hours → 100% after 72 hours):

- [ ] CI and the latest nightly mobile run are green.
- [ ] The internal-track pre-launch report shows no new crashes or security warnings. Test sign-in credentials are set in Play Console (App content → App access).
- [ ] Sentry crash-free users on this release are at 99.5% or more.
- [ ] Android vitals: user-perceived crash rate under 1.09%, ANR rate under 0.47%.
- [ ] Manual smoke test on Android 14 or 15: sign in, grant SMS, an incoming bank SMS creates a record, the background scan runs, a receipt scan fills the form.
- [ ] The Play policy checks below still hold.

If a gate regresses during a staged rollout, halt the release in Play Console (Production → Manage release → Halt rollout) and fix forward.

## 7) Local Fastlane Sanity Checks

```bash
cd packages/mobile/android
bundle install
bundle exec fastlane lanes
```

## 7) Code Quality Gates

The mobile package enforces quality checks on **every push** via `.githooks/pre-push` and on **every PR** via GitHub Actions CI.

### Local checks (pre-push hook)

```bash
cd packages/mobile
dart format --output=none --set-exit-if-changed .   # formatting
flutter analyze --no-fatal-infos                      # Dart analysis
dart run dart_code_linter:metrics analyze lib          # code metrics
dart run dart_code_linter:metrics check-unused-code lib # unused code
flutter test                                           # tests
```

The hook runs automatically on `git push`. Use `git push --no-verify` to bypass (not recommended).

### CI checks (GitHub Actions)

Push to `develop` or open a PR to `main`/`develop` triggers the CI workflow (`.github/workflows/ci.yml`), which runs the same gates centrally, plus:

- `check-unnecessary-nullable` (dart_code_linter) and `scripts/check_i18n.sh` (every key translated and used).
- `flutter test --coverage`, then `scripts/coverage_gate.sh`. It fails when line coverage, without generated code and translations, drops below `coverage_baseline.txt`. When coverage passes the baseline by 2 points, raise the baseline in the same PR.
- The widget tests again with leak tracking (`--dart-define=LEAK_TRACKING=true`).

The nightly workflow (`.github/workflows/nightly-mobile.yml`) runs what is too slow for a PR on an emulator:

- The Patrol end-to-end tests (`integration_test/`).
- Frame timings compared with `perf_baseline.json` (warnings only).
- A 10,000-event monkey run and the cold-start median.
- App size compared with `size_baseline.json`.
- Property tests at 2,000 examples, the full suite with leak tracking, and mutation testing.

To run the end-to-end tests locally, use an emulator that holds no data you need: each test clears the app's data. Always pass `-d`, or Patrol takes the first device:

```bash
integration_test/support/seed_sms.sh emulator-5560
patrol test -d emulator-5560 --target integration_test
```

### dart_code_linter rules

Configured in `packages/mobile/analysis_options.yaml`:
- **25+ rules** targeting code smells: avoid-dynamic, avoid-late-keyword, avoid-non-null-assertion, member-ordering, prefer-extracting-callbacks, etc.
- **Metrics thresholds**: cyclomatic-complexity ≤10, nesting ≤4, params ≤4, SLOC ≤50
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are excluded

### Golden images

`test/goldens/` draws ten core screens in light and dark, at text sizes 1.0 and 2.0, in English and Bangla, and compares them with the images in `test/goldens/goldens/ci/`. Text is drawn as blocks, so the images match on every machine. The clock is fixed, so dates on screen never change.

After a deliberate visual change:

```bash
cd packages/mobile
flutter test --tags golden --update-goldens
```

Open every changed image in `test/goldens/goldens/ci/` before committing it. To also see the screens with real text on your machine, run with `GOLDENS_PLATFORM=true`; those images are local only and not committed.

## Tutorial screenshots

The onboarding tutorial shows six screenshots in `assets/images/onboarding/` (Home, the add sheet and Reports, light and dark). Regenerate them after any visible change to those screens:

```bash
~/Android/Sdk/emulator/emulator -avd expenzo_test &   # 720x1440 at 2x
scripts/tutorial_screenshots.sh                      # optional: device id
```

The script reinstalls the app, fills it with made-up demo data (`screenshots/demo_seed.dart`) and writes the PNGs over the old ones. Check all six by eye before committing.

## Play policy checks

Check these before each production promotion, and whenever a permission or SDK changes.

- **SMS permissions declaration** (Play Console → App content → Sensitive permissions). `READ_SMS` and `RECEIVE_SMS` are declared under "SMS-based money management". The declared use matches the app: reading bank SMS on the device to create expense records.
- **Prominent disclosure.** The app explains SMS access before asking for it (onboarding and Auto-import). The demo video in the declaration shows that screen and the permission dialog. Re-record it if that flow changes.
- **SMS content stays on the device.** Crash reports scrub amounts, account numbers and message text (ADR 0013). Sync sends records, not messages.
- **Data safety form.** It lists "Crash logs" and "Diagnostics" (Sentry), collected, not shared, not used for ads, and users can opt out in Settings. It also lists the financial info that Sync stores on the server.
- **Permissions in the release manifest.** `SCHEDULE_EXACT_ALARM` and `RECORD_AUDIO` must stay absent. `READ_EXTERNAL_STORAGE` applies to Android 12 and older only. To check, run `flutter build appbundle` and list the permissions in `build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`.
