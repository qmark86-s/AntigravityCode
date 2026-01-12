# Speed System Refactor & Nerf

## Goal Description
Refactor the game's speed calculation logic to reduce the overall game speed (Nerf). The current speed multipliers (up to 6x) are too high, causing gameplay issues or imbalance. We will adjust the Diamond and Gold speed upgrades to provide more reasonable boosts.

## User Review Required
> [!IMPORTANT]
> **Breaking Change to Game Balance**: 
> - **Diamond Speed Tiers**: Changed from `1x, 2x, 4x` to `1x, 1.5x, 2x`.
> - **Gold Speed Upgrade**: Changed from `+10%` per level to `+5%` per level.
> - **Maximum Speed**: Reduced from `600%` (6x) to `250%` (2.5x).

## Proposed Changes

### Logic & Data
#### [MODIFY] [index.html](file:///c:/Users/idopa/.gemini/antigravity/scratch/weapon-master/index.html)
- `getSpeedMultiplier()`: Update multiplier arrays and formulas.
- `buyDiamondSpeed()`: Update log messages and purchase logic if needed (prices remain same, effect changes).
- `buyGoldSpeed()`: Update bonus calculation (level * 5 instead of 10).
- `updateSpeedShopUI()`: Update UI labels to show "1.5x", "2.0x" instead of "2x", "4x".

## Verification Plan

### Manual Verification
1.  **Check Values**: Open Console, call `game.getSpeedMultiplier()` to verify base speed.
2.  **Shop Interface**: Open Shop -> Speed tab. Verify text says "1.5배속", "2배속" etc.
3.  **Upgrade Test**:
    - Add resources (`game.p.diamond += 10000`).
    - Buy upgrades and check if `getSpeedMultiplier` updates correctly to expected values (e.g. 1.5, 2.0).
4.  **Gameplay**: Enter battle, observe animation speed and attack speed. Ensure it is not too slow or too fast.
