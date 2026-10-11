# ADR 0007: slang for localization, global `t`, English in storage

## Status

Accepted

## Context

All user-facing text was hardcoded English, about 700 strings. A good share is built where there is no `BuildContext`: blocs, use cases, the notification service, enum labels and SMS range helpers. Default category names are stored in English and synced. The app needed English and Bangla with a runtime switch in Settings.

## Decision

- Use `slang` + `slang_flutter` with one namespace per feature under `lib/i18n/<feature>/<namespace>_<locale>.i18n.json`. English is the base and fallback.
- Code reads the global `t` everywhere, widgets included. `LocaleScope` marks every element dirty when the language changes, the same way `CurrencyScope` handles currency, so `context.t` is not needed.
- `flutter_localizations` supplies the Material strings (date pickers, `MaterialLocalizations`).
- `Intl.defaultLocale` follows the app language, so `DateFormat` gives localized month and weekday names. Amounts (`CurrencyFormatter`) and dates keep Latin digits.
- Stored data stays English. Untouched default categories and built-in rule templates are translated at display time. `Failure.message` is never shown; `failureText()` maps the failure to localized text.
- Text sent to the AI model stays English and only asks it to reply in the app language.

## Consequences

### Positive

- Type-safe keys; a missing translation is a compile error or a `scripts/check_i18n.sh` failure.
- Non-widget code (notifications, insights, enum labels) translates without passing a context.
- A language change applies at once without restarting or reloading data.

### Negative

- Translated text can't be `const`, so many widgets lost `const`.
- slang is a third-party package rather than the official `gen-l10n`.
- `slang analyze` only sees full `t.a.b` paths; don't alias translation nodes in local variables.
- Bangla text is a machine draft and needs native review before release (each `_bn` file carries an `@@i18n-review` note).
