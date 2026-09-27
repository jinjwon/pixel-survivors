extends SceneTree
func _init() -> void:
 call_deferred("run")
func run() -> void:
 var passed_all: bool = true
 for starter in [4,7,1]:
  var passed: bool = await run_case(starter)
  passed_all = passed_all and passed
 quit(0 if passed_all else 1)
func run_case(starter: int) -> bool:
 seed(721)
 var arena = load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.set_process(false)
 arena.sound_on = false
 arena.select_starter(starter)
 arena.start_run()
 var ticks: int = 0
 var upgrades: int = 0
 var start: int = Time.get_ticks_msec()
 while ticks < 60*280 and arena.state not in ["victory","defeat"]:
  if arena.state == "upgrade":
   var pick = arena.offers[0]
   for desired in (["flame","scratch","ember","dragon","heal"] if starter==4 else (["bubble","bite","watergun","tackle","heal"] if starter==7 else ["razor","vine","sludge","tackle","heal"])):
    if desired in arena.offers:
     pick = desired
     break
   arena.choose_upgrade(pick)
   upgrades += 1
  # Agent moves at the same speed as the player toward drops while avoiding nearby enemies.
  var destination: Vector2 = Vector2(480,290)+Vector2.RIGHT.rotated(arena.elapsed*0.10)*140
  var closest: float = 200
  for gem in arena.gems:
   var d: float = arena.player.distance_to(gem.pos)
   if d < closest:
    closest = d
    destination = gem.pos
  var movement: Vector2 = (destination-arena.player).normalized()
  for foe in arena.enemies:
   var away: Vector2 = arena.player-foe.pos
   if away.length() < 50:
    movement += away.normalized()*(50-away.length())/18.0
  arena.player += movement.normalized()*112.0/60.0
  arena._process(1.0/60.0)
  ticks += 1
  if ticks % 600 == 0: await process_frame
 print("FULL RUN: starter=%d state=%s seconds=%.1f level=%d evolution=%d kills=%d choices=%d simulated_frames=%d wall_ms=%d" % [starter,arena.state,arena.elapsed,arena.level,arena.stage,arena.kills,upgrades,ticks,Time.get_ticks_msec()-start])
 var passed: bool = arena.state == "victory" and arena.stage == 2 and upgrades >= 8
 if not passed: printerr("FAIL: seeded normal-speed movement agent did not complete the evolved boss encounter")
 arena.queue_free()
 await process_frame
 return passed
