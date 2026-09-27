# Pokémon Meadow — local prototype implementation plan

Goal: a playable three-minute survival loop with actual Pokémon sprites, two evolutions, move choices and type matchups.
Architecture: pure Rules resource for damage/XP/evolution, Arena Node2D for combat state, Meadow renderer for scenery, Interface CanvasLayer for menus and HUD. No external runtime dependencies.
Tech: Godot 4.7.2, GDScript, Compatibility renderer. Single new project, existing projects unchanged.
Scope accepted: user asked to start after actual Pokémon assets and unresolved original-IP rights were explained. Local prototype only; no claim of clearance, no publication. Sources and notices accompany the selected files.

- [x] Rules: test Fire/Grass advantage, Fire/Water resistance, Normal/Ghost immunity, dual-type multiplication, fixed Dragon Rage behavior, evolution thresholds, capped moves and XP overflow. Write tests before production implementation.
- [x] Assets: fetch only selected PokéAPI files at a pinned commit; preserve source license and URL/SHA256 manifest; label unresolved original-IP rights.
- [x] Combat: move with WASD/arrows, auto aim, collect XP, modal upgrades, evolve at prototype levels 5 and 9, pause, victory/defeat, restart. Keep gameplay timers frozen during modals. Cap enemies/projectiles and coalesce XP drops.
- [x] Presentation: forest clearing, pixel sprites, restrained effect palette, Korean labels, clear menu and HUD, sound toggle, credits. Static source sprites with motion effects, not fabricated multi-directional animation claims.
- [x] Validate: Godot parse/import, rules tests, integration checks for pause, XP rewards only once, transitions and restart; rendered menu and combat screenshots; native local launch.

Data conventions: damage uses move type against defender type(s); contact damage uses Normal as a prototype simplification. Dragon Rage deals fixed 40, not Dragon effectiveness scaling. Evolution thresholds and cooldowns are custom survival-game balancing, not original-game levels. Boss spawns at 180 seconds; win on boss defeat, lose at HP zero or 270 seconds. Three offered upgrades are unique; selected move ranks cap at 5. When all moves are capped, recovery remains available.
