# Credits and rights status

This is an unofficial, noncommercial local prototype. It is not endorsed by Pokémon, Nintendo, Creatures, Game Freak or PokéAPI. This notice is not permission to use their intellectual property. Original Pokémon IP permission remains unresolved; this project has not been cleared for public redistribution.

## Pokémon images
Source: https://github.com/PokeAPI/sprites
Pinned upstream commit and each image's original URL, SHA-256 and byte count: ../assets/manifest.json
Original notice supplied by upstream: All image contents within are Copyright The Pokémon Company.
The complete upstream file is retained in POKEAPI-LICENCE.txt. Its CC0 repository statement does not establish a release of the Pokémon image rights identified separately in that file.

Selected images: Bulbasaur (1), Ivysaur (2), Venusaur (3), Charmander (4), Charmeleon (5), Charizard (6), Squirtle (7), Wartortle (8), Blastoise (9), Caterpie (10), Pidgey (16), Pikachu (25), Oddish (43), Psyduck (54), Gengar (94). 54 is a reserved candidate, not currently displayed in gameplay. No image bytes were altered; rendering crops transparent margins, scales, sometimes mirrors, and flashes the textures. These are static sprites with movement effects, not directional walking sprite sheets.

Rights-holder guidance: https://support.pokemon.com/hc/en-us/articles/360000634094-Can-I-use-Pok%C3%A9mon-images-or-materials
Research record: ../../planning/pixel-survivors/포켓몬_에셋_라이선스_검토.md

## Engine and other content
Godot Engine: https://godotengine.org/license/ (MIT and listed third-party components). The engine's license information is available in the editor About window. No engine binaries are included in this project directory; the launcher uses the separately installed sibling .tools/Godot.app.
Gameplay code, procedural meadow and synthesized feedback tones were created for this prototype. The system font is requested from macOS; no Apple font files are redistributed. No original Pokémon music, ROM or executable is included.

## Adapted gameplay
Evolution at levels 5 and 9, cooldowns, waves, damage values and level-up move availability are custom prototype rules, not faithful main-series rules. Fire/Normal/Dragon effectiveness against the included defenders is implemented; Dragon Rage respects Fairy immunity and otherwise deals fixed 40. Enemy contact and Gengar's prototype projectiles currently use Normal damage; this is a deliberate simplified prototype model, not Gengar's canonical move typing.
