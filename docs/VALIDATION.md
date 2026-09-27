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
