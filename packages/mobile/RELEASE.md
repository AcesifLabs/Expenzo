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

## 3) Create and Push a Release Tag

Create release tags from `main`:

```bash
git checkout main
git pull origin main
git tag mobile-v1.2.3+45
git push origin mobile-v1.2.3+45
```

This triggers `.github/workflows/deploy-android.yml`.

## 4) What the Internal Release Workflow Does

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

## 5) Promote to Production

Use manual workflow `.github/workflows/promote-android.yml`:

1. Open GitHub Actions -> **Promote Android**
2. Click **Run workflow**
3. Set `release_tag` (for audit), e.g. `mobile-v1.2.3+45`
4. Run and approve `mobile-production` environment if required

This promotion workflow only runs `fastlane production` and does not rebuild a new binary.

## 6) Local Fastlane Sanity Checks

```bash
cd packages/mobile/android
bundle install
bundle exec fastlane lanes
```
