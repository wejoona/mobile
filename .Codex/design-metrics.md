# Korido Design Metrics

Use this when tuning light and dark theme tokens.

## Premium Feel Transfer Score

Purpose: transfer the dark theme's premium feeling into light mode without copying darkness.

Calculate with perceptual color values, preferably OKLCH:

1. Foundation depth
   - Measure OKLCH lightness range across `canvas`, `surface`, `container`, and `elevated`.
   - Dark target: about `0.109`.
   - Light target: `0.09` to `0.11`.

2. Foundation noise
   - Average OKLCH chroma across foundation colors.
   - Target: below `0.025` in light mode.
   - This keeps the app warm without becoming beige-heavy.

3. Text confidence
   - Contrast on canvas:
   - Primary: `15+`
   - Secondary: around `6.5`
   - Tertiary: around `3.8`

4. Gold restraint
   - Gold text/icon contrast on light canvas should sit near `3.0`.
   - The shiny display gold can be lighter, but small text/action gold must remain readable.

5. Glow softness
   - Light glow should be warm and broader than a border, but weaker than dark glow.
   - Use it for identity and premium emphasis, not for every card.

## Current Light Target

After the 2026-06-03 light-theme tuning:

- Foundation is porcelain/stone, not beige/tan:
  - canvas `#F8F6F1`
  - surface `#F0EDE6`
  - container `#FFFEFA`
  - elevated `#ECE7DD`
- Borders are low-alpha taupe hairlines:
  - subtle `#102F281C`
  - default `#1A2F281C`
  - strong `#2E2F281C`
- Common light gold is intentionally brighter than strict contrast metrics:
  - primary `#D4AF37`
  - darken with `#BE9827`, lighten with `#E0BE4B`
  - primary buttons use ivory/white text, not dark ink
  - this sacrifices some text contrast to avoid muddy/brown action surfaces
- Identity logo gold is separate from ordinary button/card gold. Do not use the
  identity logo ramp for large repeated CTAs.

The previous 2026-06-02 light pass scored well numerically, but still felt
uncanny in screenshots because the whole app was warm beige and repeated
surfaces depended on visible brown borders. The 2026-06-03 decision prioritizes
perceived neutrality, softer light-only shadows, and bright non-muddy action
gold accents.

## Logo Gold Calculation

Do not tune the light logo gold by eye.

Use `BrandColorCalculator.deriveLightIdentityGold`:

- source color: dark identity gold (`AppColors.gold500`)
- dark background: `AppColors.obsidian`
- light background: `AppColorsLight.canvas`
- method: preserve OKLCH hue/chroma from dark gold, then compress the dark contrast by square root for light mode
- material effect: use `BrandColorCalculator.deriveLightIdentityGoldRamp` for the logo gradient, producing `#CFB756`, `#C6A84F`, `#B29A3A`

This avoids both failed manual extremes:

- `AppColorsLight.gold300` / `#F0CD68`: too yellow
- muddy antique action gold around `#B58D3A`: can read dirty on large CTAs

## Light Gradient Restraint

Ordinary light-theme gold gradients should render as a calm solid fill.

- use `context.colors.goldGradient` / `context.appGradients.goldGradient` for buttons and common icon fills
- these common tokens intentionally resolve to `#D4AF37` twice in light mode
- keep visible material gradients for identity or hero-grade surfaces only, such as the Korido mark
- in light mode, the Korido mark is a solid gold surface, not a gradient
- avoid left-to-right or obvious diagonal bands on repeated cards, buttons, list items, and child-screen icons
