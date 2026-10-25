# ADR 0013: Sentry for crash reports, scrubbed of financial data

## Status

Accepted

## Context

Release builds report errors nowhere. `FlutterError.onError` has an empty release branch, `PlatformDispatcher.onError` prints only in debug, and the Talker logger has no remote output, so crashes and ANRs reach us only through Play vitals without readable stacks.

Crashlytics 6.x needs `firebase_core` ^5, and the app was on 2.x. Expenzo also reads bank SMS, so a report must never carry message text, amounts or account numbers.

## Decision

- Use `sentry_flutter` for Dart errors, native crashes and ANRs (5 s threshold). It has no Firebase version coupling.
- `beforeSend` and `beforeBreadcrumb` scrub every event: SMS bodies, amounts, descriptions and any digit run of 4 or more become `[redacted]`. Breadcrumbs from SMS handling, HTTP bodies and UI tap labels are dropped.
- `sendDefaultPii` is off, screenshots and session replay are off.
- Releases are tagged `versionName+build`. Dart symbols and the R8 mapping are uploaded on deploy.
- Users can turn crash reports off in Settings. Off means Sentry is never started, so the Android SDK's native crash, ANR and session reports stop too. The choice is kept in its own preferences key and read before startup; switching it in Settings closes or starts Sentry straight away. An empty DSN makes the reporter a no-op.
- Native crash and ANR events don't pass through the Dart scrubber. They carry stack traces and device data but no message text, because native breadcrumbs are off.

## Consequences

### Positive

- Release crashes and ANRs arrive with readable stacks and a version, so regressions show per release.
- The reference id on the error screen matches a stored event.

### Negative

- Adds a Data Safety entry (crash logs and diagnostics) and a privacy policy section.
- The scrubber is a filter we must keep up to date when new code logs user data.
