extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  printerr("FAIL: "+message)
func _init() -> void: call_deferred("run")
func run() -> void:
 var arena = load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.set_process(false)
 arena.sound_on=false
 if not arena.has_method("choose_relic"):
  check(false,"Region reward transition is not implemented")
  arena.queue_free()
  await process_frame
  quit(1)
  return
 arena.start_run()
 arena.level=6
 arena.stage=1
 arena.ranks={"ember":3,"scratch":2}
 for region in 3:
  check(arena.region==region,"Regions advance in order")
  arena.region_elapsed=90
  arena._process(0.01)
  var bosses = arena.enemies.filter(func(e):return e.boss)
  check(bosses.size()==1,"Exactly one region boss")
  arena.hit_enemy(bosses[0],999999,1)
  if region<2:
   check(arena.state=="intermission","Intermediate boss opens reward")
   var elapsed: float=arena.elapsed
   arena._process(2)
   check(arena.elapsed==elapsed,"Intermission freezes simulation")
   check(arena.relic_offers.size()==3,"Three reward choices")
   var relic=arena.relic_offers[0]
   arena.choose_relic(relic)
   check(arena.level==6 and arena.stage==1 and arena.ranks.ember==3,"Growth and skill ranks persist between regions")
   check(arena.region_elapsed==0 and not arena.boss_spawned,"Fresh region resets local timers")
   arena.choose_relic(relic)
   check(arena.relics.size()==region+1,"Reward cannot be claimed twice")
   check(arena.enemies.is_empty() and arena.hostile_shots.is_empty(),"No old combat entities cross regions")
  else: check(arena.state=="victory","Final boss wins run")
 arena.start_run()
 check(arena.region==0 and arena.relics.is_empty() and arena.level==1,"Restart clears run progress")
 arena.region_elapsed=150
 arena._process(0.01)
 check(arena.state=="defeat","Region timeout terminates run")
 arena.queue_free()
 await process_frame
 print("JOURNEY: %d failures" % failures)
 quit(1 if failures else 0)
