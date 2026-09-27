extends SceneTree
var failures := 0
func _init() -> void:
 call_deferred("run")
func press(key: int, down: bool) -> void:
 var event := InputEventKey.new()
 event.keycode = key
 event.physical_keycode = key
 event.pressed = down
 Input.parse_input_event(event)
func check(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  printerr("FAIL: " + message)
func run() -> void:
 var arena = load("res://scripts/arena.gd").new()
 root.add_child(arena)
 arena.sound_on = false
 await create_timer(0.2).timeout
 press(KEY_2,true)
 await process_frame
 press(KEY_2,false)
 check(arena.selected_starter==7 and arena.state=="menu","Number 2 selects Squirtle without starting")
 press(KEY_ENTER,true)
 await process_frame
 press(KEY_ENTER,false)
 check(arena.player_number()==7 and arena.ranks.has("watergun"),"Enter starts selected Squirtle")
 check(arena.state=="playing","Enter starts through the real input pipeline")
 var x: float = arena.player.x
 press(KEY_D,true)
 await create_timer(0.15).timeout
 press(KEY_D,false)
 check(arena.player.x>x+8,"Physical D key moves right")
 press(KEY_SPACE,true)
 await process_frame
 press(KEY_SPACE,false)
 check(arena.dash_cooldown>2,"Space activates dodge")
 press(KEY_ESCAPE,true)
 await process_frame
 press(KEY_ESCAPE,false)
 var elapsed: float = arena.elapsed
 await create_timer(0.15).timeout
 check(arena.state=="paused" and arena.elapsed==elapsed,"Escape freezes the live run")
 press(KEY_ESCAPE,true)
 await process_frame
 press(KEY_ESCAPE,false)
 check(arena.state=="playing","Escape resumes")
 arena.gain_xp(10)
 check(arena.state=="upgrade","Live XP opens upgrade modal")
 var choice: String = arena.offers[0]
 var rank: int = arena.ranks.get(choice,0)
 press(KEY_1,true)
 await process_frame
 press(KEY_1,false)
 check(arena.ranks.get(choice,0)==rank+1 and arena.state=="playing","Number key selects the offered move")
 arena.ui.show_menu()
 await process_frame
 var card: Button = arena.ui.modal.find_child("Starter_1",true,false)
 var point: Vector2 = card.get_global_transform_with_canvas() * (card.size*0.5)
 var motion := InputEventMouseMotion.new()
 motion.position = point
 root.push_input(motion,true)
 for down in [true,false]:
  var click := InputEventMouseButton.new()
  click.position = point
  click.button_index = MOUSE_BUTTON_LEFT
  click.pressed = down
  root.push_input(click,true)
  await process_frame
 check(arena.selected_starter==1,"Click selects Bulbasaur card")
 var start_button: Button = arena.ui.modal.find_child("StartRun",true,false)
 point = start_button.get_global_transform_with_canvas() * (start_button.size*0.5)
 motion = InputEventMouseMotion.new()
 motion.position = point
 root.push_input(motion,true)
 for down in [true,false]:
  var click := InputEventMouseButton.new()
  click.position = point
  click.button_index = MOUSE_BUTTON_LEFT
  click.pressed = down
  root.push_input(click,true)
  await process_frame
 check(arena.state=="playing" and arena.player_number()==1,"Click on start launches chosen Bulbasaur")
 print("INPUT: %d failures" % failures)
 arena.queue_free()
 await process_frame
 await create_timer(0.15).timeout
 quit(1 if failures else 0)
