# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZSteeringBehaviors is a Godot 4.5 project implementing AI steering behaviors for game characters. The project uses the GL Compatibility rendering method and is designed to demonstrate various AI movement patterns.

## Project Structure

- **scripts/** - GDScript files implementing steering behavior logic
  - `AI_Seek.gd` - Base steering behavior implementation attached to character sprites
- **scenes/** - Godot scene files (.tscn) that combine scripts with visual elements
  - `seek.tscn` - Demo scene for the Seek steering behavior
- **art/** - Visual assets organized into source and runtime
  - `art/source/` - Original Aseprite files for sprites
  - `art/runtime/` - Exported PNG files and Godot import metadata used in scenes

## Development Workflow

**Running the project:**
Open the project in Godot Editor 4.5+ and press F5 or click the Play button. Individual scenes can be run using F6.

**Testing specific behaviors:**
Navigate to the scene file in `scenes/` for the behavior you want to test (e.g., `scenes/seek.tscn`) and run it directly from the Godot editor.

**Scene-Script relationship:**
Each scene in `scenes/` is paired with a corresponding script in `scripts/`. The script is attached to a Sprite2D node that displays the character sprite from `art/runtime/`. When implementing new steering behaviors, follow this pattern:
1. Create the GDScript in `scripts/` (e.g., `AI_NewBehavior.gd`)
2. Create a scene in `scenes/` with a Sprite2D node
3. Attach the script to the Sprite2D node
4. Reference the character texture from `art/runtime/`

## Technical Details

- **Godot Version:** 4.5
- **Rendering:** GL Compatibility mode (for broader device support)
- **Language:** GDScript (Godot's Python-like scripting language)
- **Node Structure:** Steering behavior scripts extend `Node` and are attached to `Sprite2D` nodes
