extends SceneTree
var arena
func _init()->void:call_deferred("run")
func capture(filename:String)->void:
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://docs/"+filename+".png")
func run()->void:
 arena=load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.sound_on=false
 arena.set_process(false)
 await create_timer(0.3).timeout
 await capture("preview-menu")
 arena.ui.generation=3
 arena.ui.show_menu()
 arena.select_starter(252)
 await capture("preview-hoenn-dex")
 arena.ui.query="라티"
 arena.ui.show_menu()
 await capture("preview-search")
 arena.ui.query=""
 arena.ui.generation=0
 for region in 3:
  arena.ui.show_menu()
  arena.select_starter([4,7,252][region])
  arena.start_run()
  arena.region=region
  arena.field.region=region
  arena.field.queue_redraw()
  arena.level=9
  arena.stage=2
  arena.elapsed=region*100+38
  arena.region_elapsed=38
  arena.invincible=0
  arena.banner_time=0
  var pool:Array=arena.Journey.STAGES[region].pool
  for i in 18:
   arena.spawn_enemy(pool[i%pool.size()],Vector2(480,295)+Vector2.RIGHT.rotated(i*TAU/18.0)*(70+i*6))
  for move in arena.rules.STARTERS[arena.selected_starter].moves:arena.ranks[move]=3
  for tick in 12:arena._process(0.016)
  # Capture a visible player and a representative active skill frame.
  arena.invincible=0
  arena.effects.clear()
  for move in arena.ranks:arena.attack(move)
  for effect in arena.effects:effect.life=effect.total*0.6
  arena.ui.update_hud()
  await capture("preview-region-%d" % (region+1))
  if region==0:
   await capture("preview-combat")
   arena.gain_xp(60)
   await capture("preview-upgrade")
   arena.state="playing"
   arena.complete_region()
   await capture("preview-reward")
 # Render every actual attack implementation to catch missing type/effect branches.
 arena.ui.show_menu()
 arena.select_starter(4)
 arena.start_run()
 arena.invincible=0
 for move in arena.rules.MOVES:
  if move=="heal":continue
  arena.enemies.clear()
  arena.spawn_enemy(10,arena.player+Vector2(40,0))
  arena.enemies[0].hp=99999
  arena.ranks={move:1}
  arena.attack(move)
  await process_frame
  await RenderingServer.frame_post_draw
 arena.queue_free()
 await process_frame
 print("VISUAL: dex, search, three regions, rewards and every attack rendered")
 quit()
