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
 var c=a.rules.catalog
 check(c.entries.size()==386,"386 species in catalog")
 check(c.entries.values().filter(func(e):return int(e.generation)==1).size()==151,"All Gen I species retained for evolution")
 check(c.search("나무지기")==[252],"Korean exact species search")
 check(c.search("treecko")==[252],"English species search")
 check(c.search("386")==[386],"Last Dex ID searchable")
 check(c.search("no-such-pokemon").is_empty(),"Empty search result")
 check(c.entries[35].types==["normal"] and c.entries[303].types==["steel"],"Historical pre-Fairy typing")
 for id in range(1,387):
  var profile:Dictionary=a.rules.STARTERS[id]
  check(a.textures.has(id),"Sprite exists %d" % id)
  check(profile.family[0]==id and profile.family.size()<=3,"Evolution begins with selected form %d" % id)
  check(profile.moves.size()==4,"Four distinct skill slots %d" % id)
  var seen:Array=[]
  for move in profile.moves:
   check(not move in seen and a.rules.MOVES.has(move),"Defined unique move %d" % id)
   seen.append(move)
  for evo in profile.family:check(evo>=1 and evo<=386,"No post-Gen III evolutions")
  if c.can_start(id):
   a.selected_starter=id
   a.start_run()
   a.gain_xp(250)
   check(a.player_number()==profile.family[-1],"Valid final form %d" % id)
 a.ui.query="impossible-name"
 a.ui.page=100
 a.ui.show_menu()
 check(a.ui.page==0 and a.ui.page_count==1,"Zero results clamp page")
 a.ui.query=""
 a.ui.generation=3
 a.ui.show_menu()
 check(a.ui.page_count==ceili(c.search("",3).size()/18.0),"Gen III pagination")
 check(a.ui.font.get_font_name().contains("Pretendard"),"Real bundled Pretendard loaded")
 a.queue_free()
 await process_frame
 print("CATALOG: %d failures" % failures)
 quit(1 if failures else 0)
