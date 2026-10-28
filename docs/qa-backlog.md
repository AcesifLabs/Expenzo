# QA backlog

Findings from the QA hardening work (`feat/SAAP-77`) that were too large to fix in place.

| Finding | Where | Why deferred |
|---|---|---|
| kiri_check held at 1.2.x | `pubspec.yaml` | 1.3.2 needs `timezone` ^0.11, which needs `flutter_local_notifications` 21 (two majors up). Upgrade both together. |
| sentry_flutter held at 9.x | `pubspec.yaml` | 10.x needs Dart 3.12; CI pins Flutter 3.41.7 (Dart 3.11.5). Move to 10.x with the next Flutter bump. |
| Java/Kotlin stack traces in Sentry stay obfuscated | `deploy-android.yml` | Sentry needs the Sentry Android Gradle plugin to tie `mapping.txt` to a build. The mapping goes to Play (vitals) and the workflow artifact. Dart traces are deobfuscated. |
| Release APK smoke test not run locally | task 7 | The release signing keystore exists only in CI. R8 and obfuscation were checked with a local build up to signing. Smoke-test the first obfuscated internal-track build on a device. |
| Migration tests start at v15, not v1 | `test/core/database/` | `drift_schemas/` holds v19 and v20 only. Dumping v1–v18 means compiling each old `app_database.dart` against today's drift_dev. The v15–v19 steps keep their hand-written tests, now seeded with the full v19 table set. |
| drift held at 2.34.0 | `pubspec.yaml` | drift_dev 2.35 needs `meta` ^1.18, newer than the pinned Flutter SDK has. Move drift and drift_dev to the same newer version with the next Flutter bump. |
| Conflicts use phone time corrected at the last pull | `sync_engine.dart` `_clockSkew` | The server keeps the newer edit by `updatedAt`. Push times are moved by the server-to-phone offset measured at the last pull. An edit queued before the phone's clock was changed is still off by that change. A full fix stamps edits with server time (a sync protocol change). |
| No file copy of the database before the v20 upgrade | `app_database.dart` | The plan asked for `expenzo.v19.bak`. The upgrade runs in one transaction instead, so a failed upgrade leaves the v19 file as it was. An unreadable file at start-up offers Reset local data, which keeps the old file as `expenzo_db.sqlite.corrupt`. |
| Cold start is 1.9 s on the test emulator | `scripts/cold_start.sh` | Median of 10 cold launches of the release APK on an API 35 x86_64 emulator with software rendering: 1886 ms, over the 1.5 s warning line. Emulator timing only (plan Q6); measure on a mid-range phone before acting. |
| End-to-end tests ran on API 35 locally, API 34 in CI | `integration_test/`, `nightly-mobile.yml` | The local test emulator (`expenzo_test`) is API 35. The nightly job uses API 34 as planned; its first run is the API 34 check. |
| A row that has to be pulled again brings later rows back too | `sync_engine.dart` `_nextPullCursor` | The cursor stops just before the earliest such row, so every row changed after it downloads again (at most 5 pulls per row). A pull by id needs a new server endpoint. |
