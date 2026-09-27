extends SceneTree
var arena
func _init() -> void:
 call_deferred("run")
func capture(filename: String) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 var image = root.get_texture().get_image()
 image.save_png("res://docs/"+filename+".png")
func run() -> void:
 arena = load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.sound_on = false
 await create_timer(0.5).timeout
 await capture("preview-menu")
 for starter in [7,1]:
  arena.select_starter(starter)
  await capture("preview-selection-%d" % starter)
  arena.start_run()
  arena.set_process(false)
  arena.level=9
  arena.stage=2
  arena.ui.update_hud()
  await capture("preview-evolution-%d" % starter)
  arena.ui.show_menu()
 arena.select_starter(4)
 arena.start_run()
 arena.set_process(false)
 for i in 18:
  var p = Vector2(480,285)+Vector2.RIGHT.rotated(float(i)*TAU/18.0)*(85+i*5)
  arena.spawn_enemy([10,43,7,16,25][i%5],p)
 arena.ranks = {"ember":3,"scratch":2,"dragon":1,"flame":2}
 arena.level = 9
 arena.stage = 2
 arena.elapsed = 119
 arena.banner_time = 0
 for i in 40: arena._process(0.016)
 arena.ui.update_hud()
 await capture("preview-combat")
 arena.gain_xp(60)
 await capture("preview-upgrade")
 arena.queue_free()
 await process_frame
 print("VISUAL: menu, combat, upgrade rendered")
 quit()
