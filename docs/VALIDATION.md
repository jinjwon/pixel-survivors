# Verification — 2026-09-25

Environment: installed Godot 4.7.2.stable.official.ed1daf0bf; rendered on Apple M5, OpenGL Compatibility renderer.

- Rules suite: 0 failures. Effectiveness including dual typing and immunity, fixed Dragon Rage, evolution thresholds, XP overflow and capped upgrade choices.
- Arena suite: 0 failures. Pause, queued upgrades, once-only death rewards, defeat, restart cleanup, boss spawn and victory/timeout.
- Full encounter: seeded agent moving at ordinary movement speed, no invulnerability override, 60 simulation steps/second. Victory at 186.4 simulated seconds, level 19, Charizard, 224 defeats, 18 upgrades. This verifies the integrated loop; it is not a human difficulty assessment or real-time GPU benchmark.
- Native-window input suite: 0 failures. Enter start, physical D movement, Space dodge, Escape pause/resume, numeric upgrade selection.
- Native rendered captures: menu, staged combat scene and upgrade panel saved as preview-menu.png, preview-combat.png, preview-upgrade.png and visually inspected. Combat capture is an arranged inspection scenario, not a claim that a person played to that state.
- 11 original asset files match their recorded SHA-256 hashes. Source notices and original upstream licence retained.
- Headless sandbox runs can emit an OS certificate-access message. Normal user execution is used for clean final validation. The headless arena test disables sound because its dummy audio driver retained playback references at shutdown; native rendered runs did not report that warning.

Not validated: human full-run playtest, sustained 60fps at maximum density, Windows/web export, multi-directional animation, original Pokémon IP permission.

## Final verification
The complete tools/verify.command sequence was rerun after disabling irrelevant audio playback in the headless arena test. Exit code 0; rules, arena and native input each reported 0 failures. Full-run simulation again reached victory at 186.4 simulated seconds. All three native captures were regenerated. No errors or ObjectDB leak warnings appeared in the final sequence.

## Starter selection — 2026-09-27
All rule, arena and starter-family tests passed. Native input test passed keyboard Squirtle selection and pointer Bulbasaur selection/start. All three seeded full-run agents won: Charmander 186.4s, Squirtle 188.7s, Bulbasaur 213.9s (simulation, not human balance validation). Selection and evolved-sprite captures were rendered, and the menu was visually inspected. Visual-only tests now disable irrelevant audio; the final visual run completed without leak warnings. Launched the updated game in a fresh native window.


## Regional roguelike and base-form selection — 2026-09-29

Fresh complete `tools/verify.command` run exited 0 with no errors or warnings under the native user environment (Apple M5 / Godot 4.7.2 Compatibility renderer).

- Rules, Arena, Starters, Base Forms, Catalog and Journey suites: 0 failures.
- 386 data entries and sprite resources present; 202 eligible base forms (71/56/75 by generation), evolved forms excluded from search and rejected by selection. Pichu is selectable, Pikachu/Raichu are not starting choices. In-run Charmander → Charizard progression still passes.
- Three intermediate/final boss transitions, intermission freeze, single reward claim, preserved level/evolution/skills, clean region reset, final victory and restart reset passed.
- Normal-speed movement agents, without invulnerability overrides, won all three regions: Charmander 289.2s / Lv.25; Squirtle 279.1s / Lv.24; Bulbasaur 297.9s / Lv.26. These are simulated seconds, not wall time or a human balance assessment.
- Native input: starter shortcuts, pointer selection, start, movement, dash, pause/resume, upgrades; Korean search and Gen III selection; Enter in search does not start a run. 0 failures.
- Rendered and visually inspected current dex and regional combat captures. Every defined attack variant was rendered without errors. Pretendard is bundled and its loaded font name is asserted. Selection portrait breathes; combat actors use move/attack/hit/dash transforms. Pausing freezes animation time.
- 386 sprite and 3 font hashes matched provenance manifests during this implementation session. Sprites total well under the engine size; total assets approximately 7.8 MB. Runtime requires no network.

Current screenshots: preview-menu.png, preview-hoenn-dex.png, preview-search.png, preview-region-1/2/3.png, preview-upgrade.png, preview-reward.png. These are deliberately arranged render scenarios, not human play recordings. Earlier selection/evolution images are historical captures.

Remaining limits: no per-species human balance evaluation, persistent save/meta-progression, true multi-directional walk sheets, terrain collision, Windows/Web export or sustained max-density performance benchmark. Pokémon IP permission remains unresolved.
