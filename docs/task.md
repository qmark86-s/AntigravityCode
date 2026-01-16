# Task List for Weapon Master

## Phase 1: Game Loop & Data Structure [x]
- [x] Fix Game Loop (requestAnimationFrame)
- [x] Centralize Game Data (GameBalance, SharedData)
- [x] Create Save Slots System

## Phase 2: UI & UX Improvements [x]
- [x] Implement Responsive Top Bar (HUD)
- [x] Fix Settings Modal overlapping
- [x] Improve Inventory & Shop UI

## Phase 3: 3D Graphics Integration (Three.js) [x]
- [x] Implement Basic 3D Scene (Tunnel, Floor, Walls)
- [x] Add Player Character Model (Knight)
- [x] Integrate 3D Logic with 2D Game Loop

## Phase 4: Ally System & Combat Polish [x]
- [x] Implement Ally Summoning & Slots
- [x] Fix Ally Attack Logic (Independent Loops)
- [x] Add Weapon Sync Visuals (Allies hold weapons)
- [x] Verify button grid responsiveness
  
## Phase 5: Visibility & Positioning Fixes [x]
- [x] Fix Invisible Character (Normalize 3D Y-coordinates to 0)
- [x] Fix Floating Enemy (Adjust CSS top position to 60%)
- [x] Verify fixes in browser

## Phase 6: 3D Monster Perspective & Git [x]
- [x] Refactor Enemy from 2D DOM to 3D Sprite
- [x] Implement "Approach" Animation (Z-axis lerp)
- [x] Fix Z-order issues (Monster behind Character logic)
- [x] Push to GitHub

## Phase 7: UI Responsiveness & Refactoring
- [x] Responsive Scaling for Top Bar (Stage Info) & Ally Buttons
- [x] Refactor Stat Panel (Remove on-screen clutter, improve Stat Modal)
- [x] Verify Mobile Layout (Browser Emulation)

## Phase 8: Mobile Vertical Scrolling Support [x]
- [x] Apply `max-height` and `overflow-y: auto` to all Modal Windows
- [x] Ensure `#settings-overlay` has proper modal container styles
- [x] Verify Touch Scrolling behaviour

## Phase 9: Menu Logic & Stage Bar Refinements [x]
- [x] Refactor Footer Menu Buttons to call dedicated `Game` methods
- [x] Implement `Game.restoreGameView()` to unify "Close" behavior (restores Stage Bar)
- [x] Update `Game.closeAllOverlays()` to hide Stage Bar
- [x] Ensure all "Open" methods call `closeAllOverlays()` first
- [x] Implement `game.openSettings()` properly

## Phase 10: Visual Layout Refinements (Mobile/Overlay) [x]
- [x] Configure Overlays (Shop, Stat, Smith, Settings) to not overlap Bottom UI Panel
- [x] Ensure `#ui-panel` stays on top of overlays (z-index)
- [x] Dynamic sizing for overlay windows to fit available height
- [x] Dynamic sizing for overlay windows to fit available height

## Phase 11: Mobile Layout Restructure [ ]
- [x] Convert `#game-scaler` to Flex Column (Strict Layout)
- [x] Set `#game-container` to flexible height (`flex: 1`)
- [x] Constrain Overlays to `#game-container` (`position: absolute`)
- [x] Remove legacy padding hacks from Modal Windows

## Phase 12: HUD & Resource Visibility [ ]
- [ ] Fix Resource (Gold/Dia) visibility on mobile (Remove `display: none`)
- [ ] Implement Mobile HUD Layout (2-Row Stack)
- [ ] Add "Stat Point Available" Notification Badge
- [ ] Verify HUD on Mobile Viewport
