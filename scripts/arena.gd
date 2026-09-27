extends Node2D

const Rules = preload("res://scripts/rules.gd")
const Meadow = preload("res://scripts/meadow.gd")
const Interface = preload("res://scripts/interface.gd")
const SPECIES = {
 10:{"types":["bug"],"hp":22.0,"speed":24.0,"name":"캐터피"},
 43:{"types":["grass","poison"],"hp":30.0,"speed":23.0,"name":"뚜벅쵸"},
 7:{"types":["water"],"hp":38.0,"speed":23.0,"name":"꼬부기"},
 25:{"types":["electric"],"hp":28.0,"speed":35.0,"name":"피카츄"},
 16:{"types":["normal","flying"],"hp":24.0,"speed":33.0,"name":"구구"},
 94:{"types":["ghost","poison"],"hp":1400.0,"speed":21.0,"name":"팬텀"}
}
var rules = Rules.new()
var selected_starter: int = 4
var ui: CanvasLayer
var textures: Dictionary = {}
var crops: Dictionary = {}
var state: String = "menu"
var player := Vector2(480,290)
var direction := Vector2.RIGHT
var hp: float = 100
var level: int = 1
var xp: int = 0
var stage: int = 0
var elapsed: float = 0
var kills: int = 0
var pending_upgrades: int = 0
var offers: Array = []
var ranks: Dictionary = {"ember":1}
var cooldowns: Dictionary = {}
var enemies: Array = []
var projectiles: Array = []
var hostile_shots: Array = []
var gems: Array = []
var effects: Array = []
var messages: Array = []
var boss_spawned: bool = false
var spawn_clock: float = 0
var invincible: float = 0
var dash_time: float = 0
var dash_cooldown: float = 0
var anim_time: float = 0
var next_id: int = 0
var banner: String = ""
var banner_time: float = 0
var sound_on: bool = true
var sfx: AudioStreamPlayer
var sound_clock: float = 0

func _ready() -> void:
 var field = Meadow.new()
 field.z_index = -10
 add_child(field)
 for number in [1,2,3,4,5,6,7,8,9,10,16,25,43,54,94]:
  var texture = load("res://assets/pokemon/%s.png" % number)
  if texture:
   textures[number] = texture
   crops[number] = texture.get_image().get_used_rect()
 ui = Interface.new()
 ui.game = self
 add_child(ui)
 sfx = AudioStreamPlayer.new()
 sfx.volume_db = -18
 add_child(sfx)
 ui.show_menu()
 queue_redraw()

func tone(frequency: float, duration: float = 0.08) -> void:
 if not sound_on or sound_clock > 0: return
 var audio := AudioStreamWAV.new()
 audio.format = AudioStreamWAV.FORMAT_8_BITS
 audio.mix_rate = 16000
 var samples := PackedByteArray()
 samples.resize(int(16000*duration))
 for i in samples.size():
  var envelope: float = 1.0-float(i)/samples.size()
  var wave: float = sin(TAU*frequency*float(i)/16000.0)
  samples[i] = int(wave*45*envelope) & 255
 audio.data = samples
 sfx.stream = audio
 sfx.play()
 sound_clock = 0.08

func select_starter(number: int) -> bool:
 if state != "menu" or not number in rules.STARTER_ORDER: return false
 selected_starter = number
 ui.show_menu()
 return true

func player_number() -> int:
 return rules.STARTERS[selected_starter].family[stage]

func player_name() -> String:
 return rules.STARTERS[selected_starter].names[stage]

func player_types() -> Array:
 return rules.STARTERS[selected_starter].types[stage]

func start_run() -> void:
 player = Vector2(480,290)
 direction = Vector2.RIGHT
 hp = 100
 level = 1
 xp = 0
 stage = 0
 elapsed = 0
 kills = 0
 pending_upgrades = 0
 offers.clear()
 var initial_move: String = rules.STARTERS[selected_starter].moves[0]
 ranks = {initial_move:1}
 cooldowns = {initial_move:0.0}
 enemies.clear()
 projectiles.clear()
 hostile_shots.clear()
 gems.clear()
 effects.clear()
 messages.clear()
 boss_spawned = false
 spawn_clock = 0.4
 invincible = 1.0
 dash_time = 0
 dash_cooldown = 0
 next_id = 0
 banner = "산책의 시작 · 경험치를 모아 진화하세요"
 banner_time = 3.5
 state = "playing"
 ui.close_modal()
 ui.update_hud()
 queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo: return
 if state == "menu" and event.keycode in [KEY_1,KEY_2,KEY_3]:
  select_starter(rules.STARTER_ORDER[event.keycode-KEY_1])
 elif event.keycode == KEY_ESCAPE:
  if state == "playing":
   state = "paused"
   ui.show_pause()
  elif state == "paused":
   state = "playing"
   ui.close_modal()
 elif event.keycode == KEY_SPACE and state == "playing" and dash_cooldown <= 0:
  dash_time = 0.18
  dash_cooldown = 2.4
  invincible = maxf(invincible,0.24)
  tone(600)
 elif state == "upgrade" and event.keycode in [KEY_1,KEY_2,KEY_3]:
  var index: int = event.keycode - KEY_1
  if index < offers.size(): choose_upgrade(offers[index])
 elif event.keycode == KEY_ENTER and state in ["menu","victory","defeat"]:
  start_run()

func _process(delta: float) -> void:
 anim_time += delta
 sound_clock = maxf(0,sound_clock-delta)
 queue_redraw()
 if state != "playing": return
 elapsed += delta
 invincible = maxf(0,invincible-delta)
 dash_time = maxf(0,dash_time-delta)
 dash_cooldown = maxf(0,dash_cooldown-delta)
 banner_time = maxf(0,banner_time-delta)
 var movement := Vector2(
  float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
  float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
 if movement.length_squared() > 0:
  direction = movement.normalized()
  player += direction * (310.0 if dash_time > 0 else 112.0) * delta
 player = player.clamp(Vector2(67,130),Vector2(891,459))
 if elapsed >= 270:
  end_run(false)
  return
 if elapsed >= 180 and not boss_spawned:
  boss_spawned = true
  spawn_enemy(94,Vector2(480,135))
  banner = "팬텀 등장! · 노말 기술은 통하지 않아요"
  banner_time = 5
  tone(180,0.2)
 spawn_clock -= delta
 if spawn_clock <= 0 and enemies.size() < 65:
  spawn_clock = maxf(0.42,1.4-elapsed/180)
  var pool: Array = [10,43,16]
  if elapsed > 28: pool.append(7)
  if elapsed > 60: pool.append(25)
  var edge := randi_range(0,3)
  var at := Vector2(randf_range(75,885),135 if edge == 0 else 457)
  if edge > 1: at = Vector2(70 if edge == 2 else 890,randf_range(135,455))
  if at.distance_to(player) < 100: at = Vector2(960-at.x,590-at.y)
  spawn_enemy(pool.pick_random(),at)
 for move in ranks:
  cooldowns[move] = float(cooldowns.get(move,0))-delta
  if cooldowns[move] <= 0:
   attack(move)
 # Entities are marked dead before removal so repeated projectiles cannot reward twice.
 for foe in enemies:
  if foe.dead: continue
  var offset: Vector2 = player - foe.pos
  foe.pos += offset.normalized()*foe.speed*delta
  foe.flash = maxf(0,foe.flash-delta)
  if foe.boss:
   foe.shot -= delta
   if foe.shot <= 0:
    foe.shot = 2.4
    for i in 10:
     var v := Vector2.RIGHT.rotated(TAU*float(i)/10.0+elapsed*0.2)
     hostile_shots.append({"pos":foe.pos,"vel":v*68,"life":6.0})
  if offset.length() < (32 if foe.boss else 22): hurt_player(18 if foe.boss else 9,"normal")
  if state != "playing": return
 for shot in projectiles:
  shot.pos += shot.vel*delta
  shot.life -= delta
  if shot.life <= 0: continue
  for foe in enemies:
   if foe.dead or foe.id in shot.hit: continue
   if shot.pos.distance_to(foe.pos) < (30 if foe.boss else 19):
    shot.hit.append(foe.id)
    hit_enemy(foe,rules.move_damage(shot.move,ranks.get(shot.move,1),foe.types),rules.multiplier(rules.MOVES[shot.move].type,foe.types))
    shot.pierce -= 1
    if shot.pierce <= 0:
     shot.life = 0
     break
 if state != "playing": return
 projectiles = projectiles.filter(func(p): return p.life > 0)
 for shot in hostile_shots:
  shot.pos += shot.vel*delta
  shot.life -= delta
  if shot.pos.distance_to(player) < 16:
   hurt_player(12,"normal")
   shot.life = 0
  if state != "playing": return
 hostile_shots = hostile_shots.filter(func(p): return p.life > 0)
 enemies = enemies.filter(func(e): return not e.dead)
 for gem in gems:
  if gem.taken: continue
  var distance: float = gem.pos.distance_to(player)
  if distance < 90: gem.pos = gem.pos.move_toward(player, (180.0 + (90-distance)*3)*delta)
  if distance < 17:
   gem.taken = true
   gain_xp(gem.value)
   if state != "playing": break
 gems = gems.filter(func(g): return not g.taken)
 for effect in effects: effect.life -= delta
 effects = effects.filter(func(e): return e.life > 0)
 for message in messages:
  message.life -= delta
  message.pos.y -= delta*18
 messages = messages.filter(func(m): return m.life > 0)
 ui.update_hud()

func spawn_enemy(number: int, at: Vector2) -> void:
 var spec: Dictionary = SPECIES[number]
 var max_hp: float = spec.hp * (1.0+elapsed/220.0) if number != 94 else spec.hp
 next_id += 1
 enemies.append({"id":next_id,"number":number,"types":spec.types,"pos":at,"hp":max_hp,"max_hp":max_hp,"speed":spec.speed,"dead":false,"flash":0.0,"boss":number==94,"shot":2.0})

func nearest_enemy():
 var target = null
 var best: float = INF
 for foe in enemies:
  if foe.dead: continue
  var distance: float = player.distance_squared_to(foe.pos)
  if distance < best:
   best = distance
   target = foe
 return target

func attack(move: String) -> void:
 var target = nearest_enemy()
 if target == null: return
 var rank: int = ranks[move]
 var aim: Vector2 = (target.pos-player).normalized()
 cooldowns[move] = rules.MOVES[move].cooldown / (1.0+0.12*(rank-1)+stage*0.1)
 if move in ["ember","dragon","watergun","bubble","razor"]:
  var count: int = 1 + int(rank >= 3) + int(rank >= 5) if move in ["ember","watergun"] else 1
  if move=="bubble": count = 3+int(rank>=4)
  if projectiles.size() < 150:
   for i in count:
    var angle: float = (i-(count-1)*0.5)*0.16
    projectiles.append({"pos":player-Vector2(0,16),"vel":aim.rotated(angle)*(210 if move=="ember" else 180),"move":move,"life":2.5,"pierce":4 if move=="dragon" else (2 if move=="razor" else 1),"hit":[]})
 else:
  var radius: float = 68+rank*9 if move in ["scratch","tackle","bite","vine"] else 115+rank*12
  effects.append({"pos":player,"aim":aim,"move":move,"radius":radius,"life":0.22})
  for foe in enemies:
   if foe.dead: continue
   var offset: Vector2 = foe.pos-player
   if offset.length() <= radius and (move in ["scratch","tackle","bite","vine"] or aim.dot(offset.normalized())>0.72):
    hit_enemy(foe,rules.move_damage(move,rank,foe.types),rules.multiplier(rules.MOVES[move].type,foe.types))
    foe.pos += offset.normalized()*8

func hit_enemy(foe: Dictionary, damage: float, factor: float) -> void:
 if foe.dead: return
 foe.hp -= damage
 foe.flash = 0.09
 if messages.size() < 35:
  messages.append({"pos":foe.pos-Vector2(5,34),"text":"무효" if damage<=0 else str(int(damage)),"color":Color("fff0a3") if factor>1 else (Color("afc9cc") if factor<1 else Color.WHITE),"life":0.55})
 if foe.hp <= 0:
  foe.dead = true
  kills += 1
  if foe.boss:
   end_run(true)
   return
  if gems.size() >= 160:
   gems[0].value += 3
  else:
   gems.append({"pos":foe.pos,"value":3,"taken":false})

func hurt_player(damage: float, kind: String) -> void:
 if state != "playing" or invincible > 0: return
 hp -= damage*rules.multiplier(kind,player_types())
 invincible = 0.8
 tone(120,0.12)
 if hp <= 0:
  hp = 0
  end_run(false)

func gain_xp(amount: int) -> void:
 var result: Dictionary = rules.add_xp(level,xp,amount)
 xp = result.xp
 level = result.level
 pending_upgrades += result.gained
 var evolved: bool = rules.evolution(level) > stage
 stage = rules.evolution(level)
 if evolved:
  hp = minf(100,hp+25)
  banner = "%s 진화! · 체력 25 회복" % player_name()
  banner_time = 4.0
 if pending_upgrades > 0:
  state = "upgrade"
  offers = rules.choices(ranks,selected_starter)
  ui.show_upgrades(evolved)
  tone(850,0.18)

func choose_upgrade(move: String) -> void:
 if state != "upgrade" or not move in offers: return
 if move == "heal": hp = minf(100,hp+35)
 else:
  ranks[move] = int(ranks.get(move,0))+1
  cooldowns[move] = 0.15
 pending_upgrades -= 1
 if pending_upgrades > 0:
  offers = rules.choices(ranks,selected_starter)
  ui.show_upgrades(false)
 else:
  state = "playing"
  ui.close_modal()
 ui.update_hud()

func end_run(won: bool) -> void:
 if state != "playing": return
 state = "victory" if won else "defeat"
 ui.show_result(won)
 tone(780 if won else 180,0.25)

func draw_pokemon(number: int, at: Vector2, height: float, flash: bool = false, flip: bool = false) -> void:
 if not textures.has(number): return
 var crop: Rect2 = crops[number]
 var scale: float = height/maxf(crop.size.y,1)
 var size: Vector2 = crop.size*scale
 var rect := Rect2((at-Vector2(size.x*0.5,size.y)).round(),size.round())
 if flip:
  rect.position.x += rect.size.x
  rect.size.x = -rect.size.x
 draw_texture_rect_region(textures[number],rect,crop,Color(2,2,2,1) if flash else Color.WHITE)

func _draw() -> void:
 if state == "menu": return
 for gem in gems:
  var p: Vector2 = gem.pos.round()
  draw_colored_polygon(PackedVector2Array([p+Vector2(0,-5),p+Vector2(4,0),p+Vector2(0,5),p+Vector2(-4,0)]),Color("b9e9ce"))
  draw_line(p+Vector2(0,-3),p+Vector2(0,1),Color.WHITE,1)
 var actors: Array = enemies.duplicate()
 actors.append({"pos":player,"is_player":true})
 actors.sort_custom(func(a,b):return a.pos.y<b.pos.y)
 for actor in actors:
  var is_player: bool = actor.has("is_player")
  if not is_player and actor.dead: continue
  var p: Vector2 = actor.pos
  var height: float = [43.0,52.0,67.0][stage] if is_player else (77.0 if actor.boss else 32.0)
  draw_set_transform(p,0,Vector2(1,0.3))
  draw_circle(Vector2.ZERO,height*0.29,Color(0.1,0.23,0.18,0.28))
  draw_set_transform(Vector2.ZERO)
  if is_player:
   draw_arc(p,21,0,TAU,32,Color("e7f4bd"),1.5)
   if invincible <= 0 or int(anim_time*18)%2 == 0:
    draw_pokemon(player_number(),p+Vector2(0,sin(anim_time*8)*1.6),height,false,direction.x<0)
  else:
   draw_pokemon(actor.number,p+Vector2(0,sin(anim_time*5+actor.id)*1.3),height,actor.flash>0,p.x>player.x)
   if actor.hp < actor.max_hp and not actor.boss:
    draw_rect(Rect2(p+Vector2(-13,3),Vector2(26,3)),Color("344b44"))
    draw_rect(Rect2(p+Vector2(-13,3),Vector2(26*maxf(0,actor.hp/actor.max_hp),3)),Color("e4c888"))
 for shot in projectiles:
  var c: Color = {"fire":Color("fbc17b"),"dragon":Color("c8b3fa"),"water":Color("96dcf1"),"grass":Color("c4e592")}[rules.MOVES[shot.move].type]
  draw_line(shot.pos-shot.vel.normalized()*12,shot.pos,c.darkened(0.2),5)
  if shot.move=="bubble":
   draw_arc(shot.pos,6,0,TAU,12,c,2)
  elif shot.move=="razor":
   draw_line(shot.pos-Vector2(4,4),shot.pos+Vector2(4,4),c,4)
  else:
   draw_circle(shot.pos,4,c)
  draw_circle(shot.pos,2,Color("fff1c5"))
 for shot in hostile_shots:
  draw_circle(shot.pos,6,Color("493565"))
  draw_arc(shot.pos,6,0,TAU,12,Color("e7acdb"),2)
 for effect in effects:
  var color: Color = {"normal":Color("fff0ab"),"dark":Color("c9b1d7"),"grass":Color("b8e67c"),"fire":Color("ff9552"),"poison":Color("c897dd")}[rules.MOVES[effect.move].type]
  color.a = effect.life*3
  var angle: float = effect.aim.angle()
  if effect.move in ["scratch","tackle","bite","vine"]:
   for offset in [-0.18,0.0,0.18]: draw_arc(effect.pos,effect.radius+offset*50,angle-1.0,angle+1.0,18,color,3)
  else:
   var points := PackedVector2Array([effect.pos])
   for i in 12: points.append(effect.pos+Vector2.RIGHT.rotated(angle-0.7+float(i)/11*1.4)*effect.radius)
   color.a = effect.life*1.3
   draw_colored_polygon(points,color)
 if ui and ui.font:
  for msg in messages: draw_string(ui.font,msg.pos,msg.text,HORIZONTAL_ALIGNMENT_LEFT,-1,14,msg.color)

func _exit_tree() -> void:
 if is_instance_valid(sfx):
  sfx.stop()
  sfx.stream = null
