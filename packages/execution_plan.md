# Execution Plan: CI/CD Pipeline for `packages/mobile/`

## Architecture Overview

```
Developer opens PR
       ↓
ci.yml runs (format, analyze, test)
       ↓  PR merged to main
deploy-android.yml triggers
       ↓
Decodes .env.prod + keystore from secrets
       ↓
flutter pub get → flutter build appbundle --release
       ↓
Fastlane: upload_to_play_store → Internal Track
       ↓
QA tests → manually promote to production
```

## Task Summary

| # | Task | Files Affected | Dependencies |
|---|------|----------------|-------------|
| 1 | Keystore & Release Signing | `packages/mobile/android/app/build.gradle.kts` | None |
| 2 | Fastlane Setup | `packages/mobile/android/fastlane/Appfile`, `Fastfile`, `Gemfile`, `Gemfile.lock` | None |
| 3 | CI Workflow | `.github/workflows/ci.yml` (new) | None |
| 4 | CD Workflow | `.github/workflows/deploy-android.yml` (new) | Tasks 1, 2 |
| 5 | Gitignore Verification | `.gitignore` (no changes needed) | Last |

## Key Adaptations from the Guide

1. **Kotlin DSL** — `build.gradle.kts` uses Kotlin syntax: `signingConfigs.create("release")` instead of Groovy's `signingConfigs.release`, and `isMinifyEnabled` instead of `minifyEnabled`
2. **Flutter 3.41.7** — Pinned to match your local version
3. **Monorepo paths** — All workflow steps use `working-directory: packages/mobile` or `packages/mobile/android`
4. **`.env.prod` injection** — Decoded from `ENV_PROD` GitHub secret because `pubspec.yaml` bundles it as an asset (build would fail without it)
5. **Build output path** — Your Gradle redirects build output to `../../build`, so the AAB path in Fastfile is `../build/app/outputs/bundle/release/app-release.aab` (relative to `android/`)

## Manual Prerequisites

1. **Generate the keystore** — `keytool -genkey` requires interactive password input
2. **Create Google Play service account** — Follow the guide in Task 2 notes
3. **Add 6 GitHub Secrets** — Documented in Task 4:
   - `KEYSTORE_BASE64`, `KEY_STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
   - `PLAY_STORE_JSON_KEY`
   - `ENV_PROD`
4. **Base64-encode the keystore** after generation for the secret

All task files are in `tasks-ex27-cicd/`. Ready for implementation when you give the go-ahead.
