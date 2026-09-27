extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  printerr("FAIL: " + message)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 var source = load("res://scripts/arena.gd")
 if source == null:
  printerr("FAIL: arena not implemented")
  quit(1)
  return
 var arena = source.new()
 root.add_child(arena)
 arena.set_process(false)
 arena.sound_on = false
 arena.start_run()
 arena.state = "paused"
 arena._process(1.0)
 check(arena.elapsed == 0.0, "Pause freezes encounter time")
 arena.state = "playing"
 arena.gain_xp(120)
 check(arena.state == "upgrade" and arena.pending_upgrades > 1, "Overflow XP queues paused choices")
 var first = arena.offers[0]
 arena.choose_upgrade(first)
 check(arena.state == "upgrade", "Overflow choices do not prematurely resume combat")
 arena.start_run()
 arena.spawn_enemy(10, Vector2(400,300))
 var enemy = arena.enemies[0]
 arena.hit_enemy(enemy, 999, 2.0)
 arena.hit_enemy(enemy, 999, 2.0)
 check(arena.kills == 1 and arena.gems.size() == 1, "Death awards a single drop")
 arena.invincible = 0
 arena.hp = 1
 arena.hurt_player(999, "water")
 check(arena.state == "defeat", "Lethal damage terminates the run")
 arena.start_run()
 check(arena.enemies.is_empty() and arena.gems.is_empty() and arena.level == 1 and arena.kills == 0 and arena.hp == 100, "Restart clears all prior run state")
 arena.elapsed = 180.0
 arena._process(0.01)
 check(arena.boss_spawned, "Boss spawns at encounter deadline")
 for foe in arena.enemies:
  if foe.boss:
   arena.hit_enemy(foe, 99999, 1.0)
 check(arena.state == "victory", "Boss defeat ends run successfully")
 arena.start_run()
 arena.elapsed = 270.0
 arena._process(0.01)
 check(arena.state == "defeat", "Boss timeout prevents endless runs")
 print("ARENA: " + str(failures) + " failures")
 arena.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 quit(1 if failures else 0)
