# Mobile Layout Restructure Plan

## Goal
Prevent menu overlays (Shop, Settings, etc.) from overlapping the bottom UI Panel on mobile devices by implementing a strict Flexbox Column layout.

## Problem
Currently, overlays use `position: fixed`, which ignores the document flow and covers the screen (including safe areas). The UI Panel uses `z-index` to sit on top, but the content "underneath" is obscured. The user wants the UI Panel to reserve its own space so menus strictly stop above it.

## Proposed Changes

### HTML / CSS (`index.html`)

1.  **`#game-scaler` (Root Wrapper)**
    - Change to `display: flex; flex-direction: column; height: 100vh; width: 100vw; overflow: hidden;`.
    - This creates the main vertical container.

2.  **`#game-container` (Game Area)**
    - Set `flex: 1; position: relative; overflow: hidden; width: 100%;`.
    - This ensures the game view (and overlays) takes up all remaining space *above* the UI panel.

3.  **`#ui-panel` (Bottom Bar)**
    - Set `flex: 0 0 auto; width: 100%; max-width: 800px; margin: 0 auto;`.
    - Remove fixed height if any (let content define it).
    - Ensure it is a direct child of `#game-scaler`. (Checked: It is).

4.  **Overlays (`#shop-overlay`, `#settings-overlay`, etc.)**
    - Change `position: fixed` to `position: absolute`.
    - Since they are children of `#game-container`, they will now be constrained to the Game Area's height.
    - Set `height: 100%; width: 100%;`.

5.  **`.shop-window` (and other modal dialogs)**
    - Remove the `margin-bottom: 110px` hack.
    - Instead, center them or fill the available `#game-container` space properly.
    - Max-height can be `100%` of the container (which is already safe).

## Verification Plan

### Automated Browser Verification
1.  **Mobile Viewport Test**: Resize browser to mobile size (e.g., 390x844).
2.  **Layout Check**:
    - Open Shop.
    - Verify `#shop-overlay` height matches `#game-container` height.
    - Verify `#ui-panel` is *below* `#game-container` (y-coord check).
    - Verify no overlap between Overlay bottom and UI Panel top.
3.  **Interaction Check**:
    - Click Shop "Close" button.
    - Click UI Panel buttons (ensure they are clickable and not covered).

### Manual Verification
- Resize window and observe the boundary between Game and UI.
