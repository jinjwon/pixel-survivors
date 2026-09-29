extends Node2D

const Motion=preload("res://scripts/motion.gd")
var walking:float=0.0
var attack_time:float=0.0
var hit_time:float=0.0

const Journey = preload("res://scripts/journey.gd")
const FX = preload("res://scripts/combat_fx.gd")
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
var region: int = 0
var region_elapsed: float = 0.0
var relics: Array = []
var relic_offers: Array = []
var bonuses: Dictionary = {}
var max_hp: float = 100.0
var run_seed: int = 0
var rng := RandomNumberGenerator.new()
var condition: Dictionary = Journey.CONDITIONS[2]
var field: Node2D

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
 field = Meadow.new()
 field.z_index = -10
 add_child(field)
 for number in range(1,387):
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
 if state != "menu" or not rules.catalog.can_start(number): return false
 selected_starter = number
 ui.show_menu()
 return true

func player_number() -> int:
 return rules.STARTERS[selected_starter].family[mini(stage,rules.STARTERS[selected_starter].family.size()-1)]

func player_name() -> String:
 return rules.STARTERS[selected_starter].names[mini(stage,rules.STARTERS[selected_starter].names.size()-1)]

func player_types() -> Array:
 return rules.STARTERS[selected_starter].types[mini(stage,rules.STARTERS[selected_starter].types.size()-1)]

func start_run() -> void:
 if not rules.catalog.can_start(selected_starter): return
 walking=0.0
 attack_time=0.0
 hit_time=0.0
 player = Vector2(480,290)
 direction = Vector2.RIGHT
 hp = 100
 max_hp = 100
 region = 0
 region_elapsed = 0
 relics.clear()
 relic_offers.clear()
 bonuses = {"damage":0.0,"haste":0.0,"speed":0.0,"guard":0.0,"magnet":0.0,"health":0.0}
 rng.randomize()
 run_seed = rng.seed
 condition = Journey.CONDITIONS[rng.randi_range(0,2)]
 field.region = region
 field.queue_redraw()
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
 if state == "menu" and get_viewport().gui_get_focus_owner() is LineEdit: return
 if state == "intermission" and event.keycode in [KEY_1,KEY_2,KEY_3]:
  var index: int = event.keycode-KEY_1
  if index<relic_offers.size(): choose_relic(relic_offers[index])
 elif state == "menu" and event.keycode in [KEY_1,KEY_2,KEY_3]:
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
 if state=="playing": anim_time += delta
 sound_clock = maxf(0,sound_clock-delta)
 queue_redraw()
 if state != "playing": return
 attack_time=maxf(0.0,attack_time-delta)
 hit_time=maxf(0.0,hit_time-delta)
 elapsed += delta
 region_elapsed += delta
 invincible = maxf(0,invincible-delta)
 dash_time = maxf(0,dash_time-delta)
 dash_cooldown = maxf(0,dash_cooldown-delta)
 banner_time = maxf(0,banner_time-delta)
 var movement := Vector2(
  float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
  float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
 walking=move_toward(walking,1.0 if movement.length_squared()>0 else 0.0,delta*9.0)
 if movement.length_squared() > 0:
  direction = movement.normalized()
  player += direction * (310.0 if dash_time > 0 else 112.0*(1.0+bonuses.get("speed",0.0))) * delta
 player = player.clamp(Vector2(67,130),Vector2(891,459))
 if region_elapsed >= Journey.DEADLINE:
  end_run(false)
  return
 if region_elapsed >= Journey.WAVE_TIME and not boss_spawned:
  boss_spawned = true
  spawn_enemy(Journey.STAGES[region].boss,Vector2(480,160))
  banner = "%s 등장! · 보스를 쓰러뜨리세요" % rules.catalog.entries[Journey.STAGES[region].boss].name
  banner_time = 4
  tone(180,0.2)
 spawn_clock -= delta
 if spawn_clock <= 0 and enemies.size() < 65:
  spawn_clock = maxf(0.4,1.1-region_elapsed/150.0)*condition.spawn
  var pool: Array = Journey.STAGES[region].pool
  var edge := randi_range(0,3)
  var at := Vector2(randf_range(75,885),135 if edge == 0 else 457)
  if edge > 1: at = Vector2(70 if edge == 2 else 890,randf_range(135,455))
  if at.distance_to(player) < 100: at = Vector2(960-at.x,590-at.y)
  spawn_enemy(pool[rng.randi_range(0,pool.size()-1)],at)
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
     hostile_shots.append({"pos":foe.pos,"vel":v*68,"life":6.0,"type":foe.types[0]})
  if offset.length() < (32 if foe.boss else 22): hurt_player(18 if foe.boss else 9,foe.types[0])
  if state != "playing": return
 for shot in projectiles:
  shot.pos += shot.vel*delta
  shot.life -= delta
  if shot.life <= 0: continue
  for foe in enemies:
   if foe.dead or foe.id in shot.hit: continue
   if shot.pos.distance_to(foe.pos) < (30 if foe.boss else 19):
    shot.hit.append(foe.id)
    hit_enemy(foe,rules.move_damage(shot.move,ranks.get(shot.move,1),foe.types)*(1.0+bonuses.get("damage",0.0)),rules.multiplier(rules.MOVES[shot.move].type,foe.types))
    add_impact(foe.pos-Vector2(0,12),shot.move)
    if state != "playing": return
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
   hurt_player(12,shot.get("type","normal"))
   shot.life = 0
  if state != "playing": return
 hostile_shots = hostile_shots.filter(func(p): return p.life > 0)
 enemies = enemies.filter(func(e): return not e.dead)
 for gem in gems:
  if gem.taken: continue
  var distance: float = gem.pos.distance_to(player)
  var reach: float = 90.0+bonuses.get("magnet",0.0)
  if distance < reach: gem.pos = gem.pos.move_toward(player, (180.0 + (reach-distance)*3)*delta)
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
 var row: Dictionary = rules.catalog.entries[number]
 var is_boss: bool = number==Journey.STAGES[region].boss
 var foe_hp: float = (620.0+region*460.0) if is_boss else (23.0+region*18.0+region_elapsed*0.15)
 next_id += 1
 enemies.append({"id":next_id,"number":number,"types":row.types,"pos":at,"hp":foe_hp,"max_hp":foe_hp,"speed":(20.0+region*3.0+float(row.stats.get("6",50))*0.08)*condition.speed,"dead":false,"flash":0.0,"boss":is_boss,"shot":2.0})

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
 attack_time=0.18
 var rank: int = ranks[move]
 tone({"fire":340.0,"water":680.0,"grass":440.0,"electric":980.0,"ghost":240.0,"ice":1100.0}.get(rules.MOVES[move].type,520.0),0.045)
 var aim: Vector2 = (target.pos-player).normalized()
 cooldowns[move] = rules.MOVES[move].cooldown / (1.0+0.12*(rank-1)+stage*0.1)*maxf(0.5,1.0-bonuses.get("haste",0.0))
 if move in ["ember","dragon","watergun","bubble","razor","swift","spark","ice","gust","sting","rock","shadow"]:
  var count: int = 1 + int(rank >= 3) + int(rank >= 5) if move in ["ember","watergun"] else 1
  if move=="bubble": count = 3+int(rank>=4)
  if projectiles.size()+count <= 150:
   for i in count:
    var angle: float = (i-(count-1)*0.5)*0.16
    projectiles.append({"pos":player-Vector2(0,8),"vel":aim.rotated(angle)*(210 if move=="ember" else 180),"move":move,"life":2.5,"pierce":4 if move=="dragon" else (2 if move in ["razor","ice","swift"] else 1),"hit":[]})
 else:
  var radius: float = 68+rank*9 if move in ["scratch","tackle","bite","vine","quake","punch","metal"] else 115+rank*12
  if effects.size()<160: effects.append({"pos":player,"aim":aim,"move":move,"radius":radius,"life":0.32,"total":0.32,"kind":"area"})
  for foe in enemies:
   if foe.dead: continue
   var offset: Vector2 = foe.pos-player
   if offset.length() <= radius and (move in ["scratch","tackle","bite","vine","quake","punch","metal"] or aim.dot(offset.normalized())>0.72):
    hit_enemy(foe,rules.move_damage(move,rank,foe.types)*(1.0+bonuses.get("damage",0.0)),rules.multiplier(rules.MOVES[move].type,foe.types))
    add_impact(foe.pos-Vector2(0,12),move)
    if state != "playing": return
    foe.pos += offset.normalized()*8

func hit_enemy(foe: Dictionary, damage: float, factor: float) -> void:
 if foe.dead: return
 foe.hp -= damage
 foe.flash = 0.09
 if messages.size() < 35:
  messages.append({"pos":foe.pos-Vector2(5,34),"text":"무효" if damage<=0 else str(int(damage)),"color":Color("a64037") if factor>1 else (Color("6b6c77") if factor<1 else Color("304452")),"life":0.55})
 if foe.hp <= 0:
  foe.dead = true
  kills += 1
  if foe.boss:
   complete_region()
   return
  if gems.size() >= 160:
   gems[0].value += 3
  else:
   gems.append({"pos":foe.pos,"value":3+int(condition.xp),"taken":false})

func hurt_player(damage: float, kind: String) -> void:
 if state != "playing" or invincible > 0: return
 hp -= damage*rules.multiplier(kind,player_types())*maxf(0.4,1.0-bonuses.get("guard",0.0))
 invincible = 0.8
 hit_time=0.18
 tone(120,0.12)
 if hp <= 0:
  hp = 0
  end_run(false)

func gain_xp(amount: int) -> void:
 var result: Dictionary = rules.add_xp(level,xp,amount)
 xp = result.xp
 level = result.level
 pending_upgrades += result.gained
 var next_stage: int = mini(rules.evolution(level),rules.STARTERS[selected_starter].family.size()-1)
 var evolved: bool = next_stage > stage
 stage = next_stage
 if evolved:
  hp = minf(max_hp,hp+25)
  banner = "%s 진화! · 체력 25 회복" % player_name()
  banner_time = 4.0
 if pending_upgrades > 0:
  state = "upgrade"
  offers = rules.choices(ranks,selected_starter)
  ui.show_upgrades(evolved)
  tone(850,0.18)

func choose_upgrade(move: String) -> void:
 if state != "upgrade" or not move in offers: return
 if move == "heal": hp = minf(max_hp,hp+35)
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

func draw_pokemon(number:int,at:Vector2,height:float,flash:bool=false,flip:bool=false,pose:Dictionary={},alpha:float=1.0)->void:
 if not textures.has(number):return
 var crop:Rect2=crops[number]
 var pixel_scale:float=height/maxf(crop.size.y,1)
 var sprite_size:Vector2=crop.size*pixel_scale
 var rect:=Rect2(Vector2(-sprite_size.x*0.5,-sprite_size.y).round(),sprite_size.round())
 if flip:
  rect.position.x+=rect.size.x
  rect.size.x=-rect.size.x
 draw_set_transform(at.round()+pose.get("offset",Vector2.ZERO),pose.get("lean",0.0),pose.get("scale",Vector2.ONE))
 var tint:Color=Color(1.65,1.65,1.65,alpha) if flash else Color(1,1,1,alpha)
 draw_texture_rect_region(textures[number],rect,crop,tint)
 draw_set_transform(Vector2.ZERO)

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
  draw_circle(Vector2.ZERO,height*0.22,Color(0.1,0.23,0.18,0.12))
  draw_set_transform(Vector2.ZERO)
  if is_player:
   draw_arc(p,21,0,TAU,32,Color("e7f4bd"),1.5)
   var pose:Dictionary=Motion.pose(anim_time,walking,attack_time,dash_time>0,-1.0 if direction.x<0 else 1.0,hit_time)
   if dash_time>0:
    for i in range(3,0,-1):
     draw_pokemon(player_number(),p-direction*i*9,height,false,direction.x<0,pose,0.07*(4-i))
   draw_pokemon(player_number(),p,height,hit_time>0,direction.x<0,pose,0.55 if invincible>0 and int(anim_time*18)%2==0 else 1.0)
  else:
   var pose:Dictionary=Motion.pose(anim_time+actor.id*0.7,0.55,0.0,false,-1.0 if p.x>player.x else 1.0,actor.flash)
   draw_pokemon(actor.number,p,height,actor.flash>0,p.x>player.x,pose)
   if actor.hp < actor.max_hp and not actor.boss:
    draw_rect(Rect2(p+Vector2(-13,3),Vector2(26,3)),Color("344b44"))
    draw_rect(Rect2(p+Vector2(-13,3),Vector2(26*maxf(0,actor.hp/actor.max_hp),3)),Color("e4c888"))
 for shot in projectiles: FX.projectile(self,shot,anim_time)
 for shot in hostile_shots:
  draw_circle(shot.pos,6,rules.catalog.COLORS.get(shot.get("type","ghost"),Color("785590")))
  draw_arc(shot.pos,8,0,TAU,16,Color("f0d5ef"),2)
 for effect in effects: FX.effect(self,effect)
 if ui and ui.font:
  for msg in messages: draw_string(ui.font,msg.pos,msg.text,HORIZONTAL_ALIGNMENT_LEFT,-1,14,msg.color)

func _exit_tree() -> void:
 if is_instance_valid(sfx):
  sfx.stop()
  sfx.stream = null

func add_impact(at: Vector2, move: String) -> void:
 if effects.size()<160:
  effects.append({"pos":at,"move":move,"kind":"impact","life":0.26,"total":0.26,"aim":Vector2.RIGHT,"radius":18.0})

func complete_region() -> void:
 if state!="playing": return
 if region==2:
  end_run(true)
  return
 state="intermission"
 var keys: Array = Journey.RELICS.keys()
 for i in range(keys.size()-1,0,-1):
  var j: int = rng.randi_range(0,i)
  var temp=keys[i]
  keys[i]=keys[j]
  keys[j]=temp
 relic_offers=keys.slice(0,3)
 ui.show_rewards()
 tone(880,0.18)

func choose_relic(id: String) -> void:
 if state!="intermission" or not id in relic_offers: return
 var reward: Dictionary = Journey.RELICS[id]
 bonuses[reward.stat] += reward.value
 relics.append(id)
 max_hp = 100.0+bonuses.health
 hp=minf(max_hp,hp+25.0+(reward.value if reward.stat=="health" else 0.0))
 region+=1
 region_elapsed=0
 condition=Journey.CONDITIONS[rng.randi_range(0,2)]
 boss_spawned=false
 enemies.clear()
 projectiles.clear()
 hostile_shots.clear()
 gems.clear()
 effects.clear()
 messages.clear()
 relic_offers.clear()
 player=Vector2(480,290)
 invincible=1.5
 spawn_clock=0.8
 field.region=region
 field.queue_redraw()
 banner="%s · %s" % [Journey.STAGES[region].place,condition.name]
 banner_time=4
 state="playing"
 ui.close_modal()
 ui.update_hud()
