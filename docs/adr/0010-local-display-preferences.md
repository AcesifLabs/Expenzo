# ADR 0010: Display preferences stay on the device

## Status

Accepted

## Context

New settings (number format, font size, first day of week, home page, notification toggles, monthly income, onboarding flag) could sync to the backend. Theme and currency already live only on the device, in `UserSettings`, saved as one JSON value in SharedPreferences (`settings_local_datasource.dart`, key `user_settings`).

## Decision

All Display Preferences are fields on `UserSettings` (with defaults, so older saved values still load), stored in SharedPreferences and never synced. The Drift `AppSettings` table is not used for them. Delete all data resets them, except the onboarding flag: it stays done, so Onboarding is not shown again after a wipe.

## Consequences

### Positive

- No backend changes; each device can differ (e.g. bigger text on a tablet).

### Negative

- A new device starts with default preferences.
