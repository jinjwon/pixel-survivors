#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
engine='../.tools/Godot.app/Contents/MacOS/Godot'
"$engine" --headless --path . --log-file /private/tmp/meadow-rules.log --script tests/test_rules.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-arena.log --script tests/test_arena.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-starters.log --script tests/test_starters.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-base.log --script tests/test_base_forms.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-catalog.log --script tests/test_catalog.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-journey.log --script tests/test_journey.gd
"$engine" --headless --path . --log-file /private/tmp/meadow-run.log --script tests/test_run.gd
"$engine" --path . --log-file /private/tmp/meadow-input.log --script tests/test_input.gd
"$engine" --path . --log-file /private/tmp/meadow-visual.log --script tests/visual_smoke.gd
