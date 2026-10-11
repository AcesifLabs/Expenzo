---
name: Expenzo
principle: Calm Progress
colors:
  light:
    background: '#F5F7FA'
    surface: '#FFFFFF'
    surface-high: '#ECEBF0'
    input-fill: '#FFFFFF'
    text-primary: '#1C1C1E'
    text-secondary: '#6C6C70'
    text-tertiary: '#636366'
    brand: '#2E6B3A'
    brand-fill: '#A2D3A4'
    on-brand-fill: '#10301A'
    accent: '#635979'
    accent-fill: '#D1C4E9'
    on-accent-fill: '#1C1C1E'
    income: '#00796B'
    expense: '#C2185B'
    warning: '#A15F00'
    info: '#1565C0'
    outline: '#7A757F'
    outline-variant: '#CAC4CF'
  dark:
    background: '#141315'
    surface: '#1C1B1D'
    surface-high: '#2B292C'
    input-fill: '#201F21'
    text-primary: '#F5F7FA'
    text-secondary: '#8E8E93'
    text-tertiary: '#CCCCCC'
    brand: '#A2D3A4'
    brand-fill: '#A2D3A4'
    on-brand-fill: '#141315'
    accent: '#D1C4E9'
    accent-fill: '#D1C4E9'
    on-accent-fill: '#141315'
    income: '#80CBC4'
    expense: '#F48FB1'
    warning: '#FFD60A'
    info: '#90CAF9'
    outline: '#948F97'
    outline-variant: '#49454D'
category-colors:
  lavender: '#D1C4E9'
  rose: '#F8BBD0'
  mint: '#C8E6C9'
  sky: '#BBDEFB'
  amber: '#FFE0B2'
  teal: '#B2DFDB'
  peach: '#FFCCBC'
  slate: '#CFD8DC'
typography:
  font-family: Lato
  weights: [400, 700]
  sizes: [32, 24, 18, 16, 14, 12]
rounded:
  card: 24px
  control: 16px
  pill: 9999px
spacing:
  scale: [4, 8, 12, 16, 24, 32, 48]
  page-gutter: 24px
  min-tap-target: 48px
---

# Expenzo design system

Expenzo is a personal expense tracker. Its design principle is **Calm Progress**: money management should feel organized and steady, not alarming. The interface stays quiet so the numbers can speak, and color carries meaning instead of decoration.

This file is the reference for both designers and code. The tokens above match `lib/core/theme/` exactly; if they ever disagree, the code is the bug. Decisions behind it are in `docs/adr/0002`–`0006` at the repo root.

## Color

Code reads every color through `AppPalette` (`context.palette`) or the theme's `ColorScheme`, never as a hex literal in a widget. Every text role reaches 4.5:1 contrast on the background and the surface in both modes; `test/core/theme/app_palette_test.dart` enforces it.

| Role | Light | Dark | Use |
|---|---|---|---|
| Background | #F5F7FA | #141315 | Page background |
| Surface | #FFFFFF | #1C1B1D | Cards, sheets, dialogs |
| Raised fill | #ECEBF0 | #2B292C | Chips, keypad keys, icon tiles |
| Text primary | #1C1C1E | #F5F7FA | Body and titles |
| Text secondary | #6C6C70 | #8E8E93 | Labels, captions |
| **Brand** (mint) text/icon | #2E6B3A | #A2D3A4 | Links, focus, selected tab, switches |
| **Brand** fill / text on it | #A2D3A4 / #10301A | #A2D3A4 / #141315 | Primary buttons, the add button |
| Accent (lavender) text/icon | #635979 | #D1C4E9 | Chart highlights, tags |
| Accent fill / text on it | #D1C4E9 / #1C1C1E | #D1C4E9 / #141315 | Info tiles, secondary chips |
| Income (teal) | #00796B | #80CBC4 | Money coming in, positive change |
| Expense (rose) | #C2185B | #F48FB1 | Money going out, over budget, errors |
| Warning (amber) | #A15F00 | #FFD60A | Budget at 80% |
| Info (sky) | #1565C0 | #90CAF9 | Neutral notices, investment insights |

Rules:

- **Mint is the brand in both modes.** It marks what you can act on. Lavender never marks a primary action.
- **Income and expense are directions, not moods.** Amounts always carry a sign (+ or −) as well as color, so color is never the only signal.
- **Rose is the only red.** There is no second "danger" red.

## Category palette

Categories are drawn as a pastel tile behind an icon (`CategoryTile`). Category colors are data: they look the same in light and dark mode.

| Name | Hex |
|---|---|
| Lavender | #D1C4E9 |
| Rose | #F8BBD0 |
| Mint | #C8E6C9 |
| Sky | #BBDEFB |
| Amber | #FFE0B2 |
| Teal | #B2DFDB |
| Peach | #FFCCBC |
| Slate | #CFD8DC |

The icon on a tile is #1C1C1E (at least 10:1 on every palette color). Colors chosen before this palette existed may be saturated; those get a white icon, picked by the tile's lightness.

## Typography

Lato is the only typeface, bundled in the app (weights 400 and 700). Widgets use `Theme.of(context).textTheme`; `test/core/theme/typography_guard_test.dart` stops inline font families and stops inline font sizes from growing.

| Size | Weight | Text theme slots | Use |
|---|---|---|---|
| 32 | 700 | headlineLarge (display slots too) | Key figures, the hero amount |
| 24 | 700 | headlineMedium, headlineSmall | Page titles |
| 18 | 700 | titleLarge | Section titles |
| 16 | 400 / 700 | bodyLarge / titleMedium | Body text, list titles |
| 14 | 400 / 700 | bodyMedium / titleSmall, labelLarge | Secondary text, buttons |
| 12 | 400 / 700 | bodySmall, labelSmall / labelMedium | Captions, nav labels |

Nothing is smaller than 12. Amounts use tabular figures so digits line up.

## Spacing and layout

A 4px grid: 4, 8, 12, 16, 24, 32, 48 (`AppSpacing`). Pages have a 24px side gutter. Sections are separated by 24 or 32. Anything tappable is at least 48 × 48, even when the visible shape is smaller.

## Shape

Three radii only:

| Radius | Used for |
|---|---|
| 24 | Cards, bottom sheets, dialogs |
| 16 | Buttons, text fields, list tiles, snackbars |
| Full | Chips, badges, progress bars |

## Elevation

Hierarchy comes from tone, not shadow. Cards are one step lighter than the page in dark mode and white on a light grey page in light mode. Shadows are reserved for floating elements: the bottom navigation bar and the add button.

## Components

- **Primary button.** Mint fill, dark text, 16 radius, bold label. One per screen.
- **Secondary button.** Text or outlined in brand mint.
- **Destructive action.** Rose text; confirm in a dialog before deleting.
- **Cards.** Surface color, 24 radius, 16–24 padding.
- **Text fields.** Input fill, 1px outline, 16 radius. Focus shows a 1.5px brand outline.
- **Progress bars.** At least 12px tall, pill shaped. Income teal while on track, warning amber from 80%, expense rose when over.
- **Bottom navigation.** Four tabs (Home, Activity, Budgets, Reports) and one center add button that always adds a transaction.
- **Back and close.** A page you navigated to shows a back caret on the left. A short task opened from a form or sheet (choosing or adding a category) opens as a full-screen dialog with a close (✕) on the left. Never both.

## Icons

Phosphor icons through the `picons` package. Regular weight everywhere; Fill only for the selected tab. No Material icons. Icon-only buttons always have a tooltip or semantic label.

## Money

One formatter (`CurrencyFormatter`) renders every amount from the user's currency in Settings (ISO code, for example BDT or USD). Lists show two decimals for currencies that have them; summary figures may drop decimals. Editable fields show the plain number ("122", never "122.0").

## Writing

- Sentence case for titles, buttons and labels.
- One verb per action: **Add** to create, **Save** to keep edits, **Delete** to remove.
- Name things the way people think of them: "Auto-import from SMS", "SMS formats", "Matching rules", not template or parser terms.
- Empty states say what is missing and offer the next step.
- No exclamation marks; "…" only while something is in progress.
- All user-facing text lives in slang translation files under `lib/i18n/<feature>/` (English `_en`, Bangla `_bn`) and is read through the global `t`. Words used on many screens (Cancel, Save, Try again, Add expense) live in `t.common`.
- Translations: write whole sentences with placeholders (`"{amount} left"`), never glue fragments; use plural forms for counts. Bangla follows the same rules (one verb per action, no exclamation marks) and keeps Latin digits for amounts and dates. Run `scripts/check_i18n.sh` after adding keys (docs/adr/0007).

## Accessibility

- Everything tappable is at least 48×48dp, even when it looks smaller (chips keep a compact look inside a 48dp touch area).
- Icon-only controls carry a tooltip or semantics label.
- Money is never shown by color alone: amounts carry a + or − sign, and screen readers hear "Expense, 122 Bangladeshi taka".
- `test/a11y/` checks tap targets and labels on Home, Activity, Budgets, Reports and the transaction sheet.

## Logo

The logo is supplied by the product owner. It lives at `assets/images/logo.png` and appears on the splash screen, the sign-in screen and the launcher icon (adaptive background `#A2D3A4`). Until it exists, those places show the app name in the brand color.
