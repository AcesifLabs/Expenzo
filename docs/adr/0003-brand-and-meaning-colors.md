# ADR 0003: Mint brand in both modes; teal income, rose expense, lavender accent

## Status

Accepted

## Context

The light theme used lavender as primary and the dark theme swapped to mint, so the app's identity changed with the theme. Mint also meant "income", two different reds meant "expense", and lavender text on white was 1.6:1.

## Decision

- Brand is mint in both modes: fill `#A2D3A4`; text and icons use a darker mint in light mode.
- Income uses teal, expense uses one rose, so money direction never looks like a brand button.
- Lavender is the secondary accent (charts, selection, focus).
- All colors come from `AppPalette` (`lib/core/theme/app_palette.dart`) and `ColorScheme` is derived from it. Text roles meet 4.5:1 and icons/fills 3:1 in both modes, enforced by tests.

## Consequences

### Positive

- One recognizable identity; consistent money semantics.

### Negative

- Light mode looks noticeably different (lavender to mint); every `colorScheme.primary` consumer changes.
- DESIGN.md and `design/expenzo.pen` need updating to match.
