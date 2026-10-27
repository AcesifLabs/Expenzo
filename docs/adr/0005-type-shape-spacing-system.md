# ADR 0005: Lato only, six type sizes, three radii, 4px spacing grid

## Status

Accepted

## Context

The theme used Lato while 91 inline styles asked for Work Sans, which is not bundled and silently rendered as Roboto. The code used 17 font sizes, about 15 corner radii and roughly 290 literal paddings.

## Decision

- Lato (400, 700) is the only typeface, bundled as assets. `google_fonts` is removed.
- Type scale: 32, 24, 18, 16, 14, 12, exposed through `TextTheme`; amounts use tabular figures. Nothing smaller than 12.
- Radii: 12 for cards; 24 for sheets and dialogs; 8 for buttons and inputs; full for chips and progress bars. (Revised from 24 for cards and 16 for controls: cards looked too round on device.)
- Spacing tokens: 4, 8, 12, 16, 24, 32, 48; page gutter 24.
- Widgets use `TextTheme`, `AppSpacing` and `AppPalette`; a guard test fails on inline `fontFamily` or numeric `fontSize` outside `lib/core/theme`.

## Consequences

### Positive

- Visual consistency is enforced by tests, not by review.

### Negative

- A large mechanical migration across every feature folder.
