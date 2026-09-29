extends SceneTree
var failures:=0
func check(ok:bool,message:String)->void:
 if not ok:
  failures+=1
  printerr("FAIL: "+message)
func _init()->void:call_deferred("run")
func run()->void:
 var a=load("res://scripts/arena.gd").new()
 root.add_child(a)
 a.set_process(false)
 a.sound_on=false
 for id in [2,6,26,94,154,257,272,376]:
  check(not a.select_starter(id),"Evolved form rejected: %d" % id)
  check(not id in a.rules.catalog.search(),"Evolved form hidden: %d" % id)
 for id in [1,4,7,133,172,152,252,386]:
  check(a.select_starter(id),"Base or non-evolving species available: %d" % id)
 a.select_starter(4)
 a.start_run()
 a.gain_xp(250)
 check(a.player_number()==6,"In-run evolution still reaches Charizard")
 a.state="paused"
 var before:float=a.anim_time
 a._process(1)
 check(a.anim_time==before,"Pause freezes character animation")
 a.queue_free()
 await process_frame
 print("BASE FORMS: %d failures" % failures)
 quit(1 if failures else 0)
