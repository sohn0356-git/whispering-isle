# DNS Prototype

This repository contains the current Godot 4 prototype for **DNS**, a Steam-targeted pixel RPG. The project now includes a first-pass **procedural pixel-character generation pipeline** for village explorers and a compact **one-screen pixel-style town**.

`project.godot` is present, so the folder can be opened directly from Godot's project list.

## What Was Added

Explorer visuals no longer rely only on polygon placeholders. Each explorer now gets a structured appearance profile and, when no external sprite sheet is assigned, the game generates a small pixel character in code, converts it to a Godot `Image`, then converts that image into an `ImageTexture` used in-game.

The village still fits on one screen with no camera scrolling, and all major places remain visible at once:
- `Inn`
- `Shop`
- `Central plaza`
- `Labyrinth gate`

## Procedural Character Pipeline

The procedural system uses curated templates instead of random pixel noise.

Each generated explorer is built from:
- race rules
- class rules
- body type
- hair style
- beard style
- ear type
- armor type
- accessory type
- curated skin palette
- curated hair palette
- curated outfit palette

The generator builds a fixed pixel canvas in memory, paints the character into that grid, then converts the result like this:

1. Create a transparent `Image`
2. Fill body, head, hair, outfit, beard, ears, and accessories using grid-aligned pixel rectangles
3. Add simple shading and outline pixels
4. Convert the `Image` into an `ImageTexture`
5. Feed that texture into the explorer scene as a usable in-game sprite

This keeps explorers coherent and readable while still allowing many unique combinations.

## Chosen Canvas Size

Generated explorer visuals use:
- `32x32`

This is large enough for a readable idle-style village character and small enough to stay clearly pixel-art.

## Structured Templates Instead Of Pure Randomness

The system intentionally avoids chaotic RGB noise or arbitrary pixel placement.

Examples:
- `Elf` explorers get longer ears and lighter silhouettes
- `Dwarf` explorers support stout bodies and beard-heavy looks
- `Barbarian` explorers favor broad bodies and rougher gear
- `Rogue` explorers use darker outfit palettes
- `Mystic Mage` explorers lean toward robe silhouettes and arcane colors

Because palettes and traits come from curated sets, the results stay closer to a classic fantasy RPG roster.

## Current Rendering Behavior

- If `sprite_path` points to a real sprite sheet PNG, the explorer uses that external sheet through `AnimatedSprite2D`
- If no valid sprite sheet exists, the explorer uses the generated `ImageTexture`
- The current generated version is a single static idle-style frame reused for `front`, `back`, `left`, and `right`

This means the system is immediately usable in the village today, while still being ready for richer animation later.

## File Structure

- `scenes/village/Village.tscn`
  One-screen village scene with environment layers, player, NPCs, explorer nodes, and UI.
- `scenes/village/Village.gd`
  Builds the tile-based village at runtime and keeps explorer state positions mapped to the inn, plaza, shop, and gate.
- `scenes/explorer/Explorer.tscn`
  Explorer scene with `AnimatedSprite2D` display.
- `scenes/explorer/Explorer.gd`
  Chooses between external sprite sheets and generated pixel textures, then displays the result in-game.
- `scripts/ExplorerData.gd`
  Data model for each explorer, including race/class identity and stored generated appearance data.
- `scripts/ExplorerAppearanceData.gd`
  Structured appearance profile including traits, palettes, and pixel canvas size.
- `scripts/ExplorerAppearanceGenerator.gd`
  Generates appearance profiles and builds pixel data into `Image` and `ImageTexture`.
- `scripts/ExplorerManager.gd`
  Runs the autonomous explorer loop and assigns stable generated appearance data once per explorer.

## Tile Size

The village uses:
- `16x16` world tiles

All environment placement remains aligned to this grid.

## Future Expansion

This first-pass pipeline is set up so it can later grow into:
- multi-frame generated animations
- directional frame generation
- cached generated textures
- PNG export with `Image.save_png()`
- layered template composition using real pixel parts

The easiest upgrade path is:
1. keep `ExplorerAppearanceData.gd` as the source of visual identity
2. extend `ExplorerAppearanceGenerator.gd` to produce multiple frames instead of one
3. optionally save generated images as PNGs for debugging or caching
4. replace some generated regions with authored pixel parts while preserving the same data fields

## Future Environment Asset Pipeline

Real environment art can later be placed under:
- `res://assets/tilesets/`
- `res://assets/sprites/environment/`

## How To Open In Godot

1. Open **Godot 4**
2. Use `Import` or `Scan`
3. Select this folder
4. Open the project

## How To Run

1. Open the project in Godot
2. Press `F5`
3. Godot runs `res://scenes/main/Main.tscn`
4. The bootstrap scene loads `res://scenes/village/Village.tscn`

If the village scene fails to load, `Main.gd` shows a fallback message instead of crashing.

## Controls

- Move: `WASD` or arrow keys
- Interact: `E`
- Advance dialogue: `Enter` or `Space`

## Manual Godot Setup

No required manual scene wiring should be necessary if the project imports correctly.

Optional next steps:
- replace generated environment textures with final environment tiles
- move runtime input action setup into project settings
- add multi-frame explorer generation
- add PNG export/debug caching for generated characters

## Testing

1. Run the game with `F5`
2. Enter the village
3. Confirm the town still fits on one screen
4. Check that explorers no longer all look identical
5. Confirm race/class cues are visible even without external sprite sheets
6. Watch explorers continue moving between plaza, inn, shop, and labyrinth gate
