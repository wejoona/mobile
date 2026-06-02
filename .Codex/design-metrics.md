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

After the 2026-06-02 light-theme tuning:

- Foundation depth range: `0.098`
- Foundation chroma average: `0.023`
- Primary contrast: `16.29`
- Secondary contrast: `6.36`
- Tertiary contrast: `4.10`
- Gold contrast: `2.68`
- Overall transfer score: `93.2`

The previous light score was `80.9`, mainly because foundation depth was only `0.065`.
