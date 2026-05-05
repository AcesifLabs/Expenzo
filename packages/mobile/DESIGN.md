---
name: Calm Progress
colors:
  surface: '#141315'
  surface-dim: '#141315'
  surface-bright: '#3a383b'
  surface-container-lowest: '#0f0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f21'
  surface-container-high: '#2b292c'
  surface-container-highest: '#363437'
  on-surface: '#e6e1e4'
  on-surface-variant: '#cac4cd'
  inverse-surface: '#e6e1e4'
  inverse-on-surface: '#313032'
  outline: '#948f97'
  outline-variant: '#49454d'
  surface-tint: '#cdc1e5'
  primary: '#ede1ff'
  on-primary: '#342c49'
  primary-container: '#d1c4e9'
  on-primary-container: '#5a506f'
  inverse-primary: '#635979'
  secondary: '#a2d3a4'
  on-secondary: '#0a3817'
  secondary-container: '#24502c'
  on-secondary-container: '#91c193'
  tertiary: '#ffdee6'
  on-tertiary: '#5c1333'
  tertiary-container: '#ffb6cc'
  on-tertiary-container: '#8a3958'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#eaddff'
  primary-fixed-dim: '#cdc1e5'
  on-primary-fixed: '#1f1732'
  on-primary-fixed-variant: '#4b4260'
  secondary-fixed: '#bdefbe'
  secondary-fixed-dim: '#a2d3a4'
  on-secondary-fixed: '#002109'
  on-secondary-fixed-variant: '#24502c'
  tertiary-fixed: '#ffd9e2'
  tertiary-fixed-dim: '#ffb0c9'
  on-tertiary-fixed: '#3e001e'
  on-tertiary-fixed-variant: '#792b4a'
  background: '#141315'
  on-background: '#e6e1e4'
  surface-variant: '#363437'
typography:
  headline-xl:
    fontFamily: Work Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Work Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.3'
  body-md:
    fontFamily: Work Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-sm:
    fontFamily: Work Sans
    fontSize: 13px
    fontWeight: '500'
    lineHeight: '1.2'
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  gutter: 16px
  margin: 24px
---

## Brand & Style

The design system is centered on the intersection of personal finance and behavioral wellness. It moves away from the traditional high-stress, data-dense financial interface toward an aesthetic that promotes mindfulness, steady growth, and intentionality. The target audience includes individuals who view their finances as a series of habits and milestones rather than just a balance sheet.

The visual style is a blend of **Minimalism** and **Tactile Modernism**. It prioritizes extreme clarity and breathing room (airy spacing) to reduce cognitive load. The emotional response should be one of quiet confidence and organization—transforming the often-anxious experience of money management into a soothing, goal-oriented journey.

## Colors

The palette is anchored by a deep charcoal base which provides a stable, low-glare environment. The accent colors are muted pastels that function as functional identifiers for different categories or progress states:

*   **Lavender (#D1C4E9):** Used for primary actions and general savings goals.
*   **Mint Green (#A5D6A7):** Reserved for growth, completion, and positive cash flow.
*   **Dusty Rose (#F48FB1):** Used for debt management or spending limits.
*   **Light Sky Blue (#90CAF9):** Employed for long-term investments and security.

Contrast is maintained by using the deep background color for text when placed atop these pastel interactive elements, ensuring legibility while maintaining the soft aesthetic.

## Typography

This design system utilizes **Work Sans** (as a high-quality alternative to Lato that shares its friendly yet professional tone) to ensure readability across all financial data. 

Headings are treated with bold weights and tighter letter-spacing to feel impactful and encouraging. Body text is set with generous line-height to maintain the "airy" feel requested. Labels and captions use a slightly medium weight and increased letter-spacing to ensure they remain legible against the dark background even at smaller sizes.

## Layout & Spacing

The layout follows a **fluid grid** model optimized for mobile-first interactions. It relies on a consistent 8px rhythm to maintain order.

*   **Margins:** A standard 24px outer margin ensures that content never feels cramped against the screen edges.
*   **Vertical Rhythm:** Sections are separated by large (32px or 48px) gaps to reinforce the calm, organized narrative.
*   **Internal Padding:** Cards and containers use a minimum of 24px internal padding to provide a "premium" sense of space.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Subtle Outlines** rather than aggressive shadows. 

1.  **Base Layer:** The solid #0E0E0E background.
2.  **Surface Layer:** Cards and containers use a slightly lighter charcoal (#1A1A1A).
3.  **Definition:** Elements are defined by 1px subtle borders (10% opacity white) or very soft, large-radius ambient shadows (0px 10px 30px) with 5% opacity to give a slight "lift" without breaking the flat aesthetic.
4.  **Interactive Layer:** Buttons and active states use the high-saturation pastel colors to appear as the topmost layer.

## Shapes

The shape language is dominated by extreme roundness, which removes the "sharpness" and clinical feel often associated with banking apps.

*   **Containers:** Large cards use a 24px radius to feel soft and approachable.
*   **Progress Bars:** Designed as thick, pill-shaped elements (full radius) to emphasize the "habit tracker" visual metaphor.
*   **Buttons:** Use a 16px radius to distinguish them slightly from the larger containers while maintaining the rounded theme.

## Components

### Buttons & Chips
Interactive elements are filled with solid pastel colors. Text inside buttons should be the background color (#0E0E0E) at a bold weight. Secondary buttons should use a ghost style with a pastel border and pastel text.

### Cards
Cards are the primary organizational unit. They should use the surface color (#1A1A1A) and contain generous internal padding. For "Goal" cards, a small pastel accent strip or icon can be used to categorize the content.

### Progress Bars
Progress bars must be thick (at least 12px height). The background of the bar should be a dark, desaturated version of the accent color, while the fill uses the vibrant pastel accent.

### Icons
Use **Phosphor Icons** in the 'Regular' or 'Light' weight. Icons should be used sparingly and always in the same pastel color as the category they represent to aid in quick visual scanning.

### Input Fields
Inputs should be large, rounded (16px), and use the surface color. The focus state is indicated by a 2px pastel border, avoiding the use of glowing effects to keep the interface calm.
