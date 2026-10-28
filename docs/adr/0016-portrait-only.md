# ADR 0016: Phones are locked to portrait

## Status

Accepted

## Context

The manifest did not lock orientation, and only one widget in `lib/` adapts to screen width, so landscape and tablet layouts were untested and likely broken. Supporting landscape well means a layout pass on every screen, for little gain in an expense tracker.

## Decision

- The app runs in portrait only, set in the manifest and with `SystemChrome.setPreferredOrientations`.
- Tablets get the phone layout. The screen registry tests include one tablet width (800×1280) to prove nothing overflows.

## Consequences

### Positive

- One orientation to design and test.

### Negative

- Tablet users get a stretched phone layout and cannot rotate.
