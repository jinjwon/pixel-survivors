extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  printerr("FAIL: " + message)
func _init() -> void:
 call_deferred("run")
func run() -> void:
 var arena = load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.set_process(false)
 arena.sound_on = false
 if not arena.has_method("select_starter"):
  printerr("FAIL: starting partner cannot be selected")
  arena.queue_free()
  await process_frame
  quit(1)
  return
 var cases = [
  {"id":4,"move":"ember","evolved":6,"name":"리자몽","types":["fire","flying"]},
  {"id":7,"move":"watergun","evolved":9,"name":"거북왕","types":["water"]},
  {"id":1,"move":"vine","evolved":3,"name":"이상해꽃","types":["grass","poison"]}]
 for spec in cases:
  arena.ui.show_menu()
  check(arena.select_starter(spec.id), "Menu accepts starter selection")
  arena.start_run()
  check(arena.ranks == {spec.move:1}, "Run starts with the selected partner's move")
  check(arena.player_number() == spec.id, "Correct starting sprite")
  check(not arena.select_starter(7 if spec.id!=7 else 1), "Selection cannot change a live run")
  arena.spawn_enemy(10,Vector2(480,270))
  var hp_before: float = arena.enemies[0].hp
  arena.attack(spec.move)
  for tick in 20: arena._process(0.016)
  check(arena.kills>0 or arena.enemies[0].hp<hp_before, "Each starter's initial attack damages an enemy")
  arena.gain_xp(250)
  check(arena.player_number()==spec.evolved and arena.player_name()==spec.name, "Evolution follows the chosen family")
  check(arena.player_types()==spec.types, "Evolved defense typing follows family")
  var pool = arena.rules.STARTERS[spec.id].moves
  for offer in arena.offers: check(offer in pool or offer=="heal", "No cross-family upgrade leaks")
  var capped: Dictionary = {}
  for move in pool: capped[move]=5
  check(arena.rules.choices(capped,spec.id)==["heal"], "Each completed family falls back to recovery")
  arena.state="playing"
  arena.end_run(false)
  arena.start_run()
  check(arena.player_number()==spec.id and arena.ranks=={spec.move:1} and arena.level==1, "Retry keeps selection but resets evolution and moves")
 arena.ui.show_menu()
 check(not arena.select_starter(387), "Unavailable species rejected")
 var rules = arena.rules
 check(rules.move_damage("watergun",1,["fire"])>rules.move_damage("watergun",1,["water"]), "Water move uses Water effectiveness")
 check(rules.move_damage("vine",1,["water"])>rules.move_damage("vine",1,["fire"]), "Grass move uses Grass effectiveness")
 check(rules.move_damage("bite",1,["ghost","poison"])>0, "Squirtle has an effective option for Gengar")
 arena.queue_free()
 await process_frame
 print("STARTERS: %d failures" % failures)
 quit(1 if failures else 0)
