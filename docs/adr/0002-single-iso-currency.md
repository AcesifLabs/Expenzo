# ADR 0002: One ISO currency per user, one formatter

## Status

Accepted

## Context

Settings stored only a free-text currency symbol (default `$`), while `CurrencyFormatter` fell back to `৳` and several widgets hardcoded `$` or `৳`. The same Record showed as ৳122.00 on Home and $122.00 on Activity. Without a currency code the app also cannot apply per-currency decimals or names.

## Decision

Settings store one ISO 4217 code (`currencyCode`). `CurrencyConfig` holds the supported currencies (code, symbol, decimal digits, display name). `CurrencyFormatter` reads the current currency from a notifier that `ExpenzoApp` updates from `SettingsBloc`, and every amount in the UI goes through it. Records keep storing a plain amount.

## Consequences

### Positive

- One source of truth; changing currency updates every screen.
- Per-currency decimals and names become possible.

### Negative

- Existing installs must migrate the stored symbol to a code (`$` → USD, `৳` → BDT, unknown → BDT).
- No multi-currency support; adding it later means a currency field on Records.

## Implementation Notes

- New installs default to BDT.
- Formatting happens in widgets, not in bloc state, so a currency change re-renders without reloading data.
