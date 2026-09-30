# Credits and rights status

This is an unofficial, noncommercial fan prototype. It is not endorsed by Pokémon, Nintendo, Creatures, Game Freak or PokéAPI. This notice is not permission to use their intellectual property. Original Pokémon IP permission remains unresolved; this project has not been cleared for public redistribution.

## Pokémon images
Source: https://github.com/PokeAPI/sprites
Pinned upstream commit and each image's original URL, SHA-256 and byte count: ../assets/manifest.json
Original notice supplied by upstream: All image contents within are Copyright The Pokémon Company.
The complete upstream file is retained in POKEAPI-LICENCE.txt. Its CC0 repository statement does not establish a release of the Pokémon image rights identified separately in that file.

Selected images: National Pokédex IDs 1–386, one default front sprite per species. 202 base forms are selectable; evolved forms are reserved for progression. Image bytes are unchanged; rendering crops transparent margins, scales with nearest filtering, sometimes mirrors and flashes textures. These are static sprites animated using breathing, stride, lean, recoil, hit reaction and dash echoes; not directional walk sheets.

Rights-holder guidance: https://support.pokemon.com/hc/en-us/articles/360000634094-Can-I-use-Pok%C3%A9mon-images-or-materials
Research record: ../../planning/pixel-survivors/포켓몬_에셋_라이선스_검토.md

## Engine and other content
Godot Engine: https://godotengine.org/license/ (MIT and listed third-party components). The engine's license information is available in the editor About window. No engine binaries are included in this project directory; the launcher uses the separately installed sibling .tools/Godot.app.
Gameplay code, procedural meadow and synthesized feedback tones were created for this prototype. Pretendard 1.3.9 Regular, SemiBold and Bold by Kil Hyung-jin are bundled under SIL OFL 1.1. License: `assets/fonts/OFL.txt`; pinned URLs and hashes: `assets/fonts/manifest.json`. Official source: https://github.com/orioncactus/pretendard/tree/v1.3.9. No Apple font files are redistributed. No original Pokémon music, ROM or executable is included.

## Species data
Korean/English names, generation, evolution links, base statistics and historical typing are derived from pinned PokéAPI CSVs. Source commit, URLs and input-file hashes: `assets/data/sources.json`; database license: `POKEAPI-DATA-LICENSE.md`. Pokémon and character names remain trademarks of their respective owners. Data code licensing does not grant character/IP rights.

## Adapted gameplay
Evolution at levels 5 and 9, custom type-based four-move loadouts, waves, damage, boss timings and relic effects are survival prototype rules, not faithful main-series rules or learnsets. Branches follow the first available descendant inside Gen I–III, displayed before starting. Historical pre-Fairy typing is used. Move damage follows the implemented 17-type chart. Contact attacks and boss projectiles use the attacking species' primary type. Dragon Rage has base damage 40 regardless of move rank, with run relic damage bonuses applied afterward.

## Visual reference
The FireRed/LeafGreen Pokédex and battle-menu visual language informs the Pokédex device colors, cream dialogue panels and readable battle HUD: https://www.pokemon.com/us/pokemon-video-games/pokemon-firered-version-and-pokemon-leafgreen-version (official reference page, retrieved 2026-09-27; full gallery access was blocked). A real game screenshot was visually inspected at https://i.imgur.com/bOTIPYu.png (2026-09-28). No screenshot, logo or UI artwork from that gallery is bundled. The field, UI geometry and effects are drawn by the project.
