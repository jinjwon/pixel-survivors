#!/bin/zsh
set -eu
cd "$(dirname "$0")"
exec ../.tools/Godot.app/Contents/MacOS/Godot --path "$PWD"
