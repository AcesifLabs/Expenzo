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
4. Run and approve `mobile-production` environment if required

This promotion workflow only runs `fastlane production` and does not rebuild a new binary.

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

Push to `develop` or open a PR to `main`/`develop` triggers the CI workflow (`.github/workflows/ci.yml`), which runs the same gates centrally.

### dart_code_linter rules

Configured in `packages/mobile/analysis_options.yaml`:
- **25+ rules** targeting code smells: avoid-dynamic, avoid-late-keyword, avoid-non-null-assertion, member-ordering, prefer-extracting-callbacks, etc.
- **Metrics thresholds**: cyclomatic-complexity ≤10, nesting ≤4, params ≤4, SLOC ≤50
- Generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`) are excluded
