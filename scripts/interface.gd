extends CanvasLayer
const Catalog = preload("res://scripts/catalog.gd")
const Journey = preload("res://scripts/journey.gd")
const REGULAR = preload("res://assets/fonts/Pretendard-Regular.otf")
const SEMIBOLD = preload("res://assets/fonts/Pretendard-SemiBold.otf")
const BOLD = preload("res://assets/fonts/Pretendard-Bold.otf")
const INK := Color("293c49")
const CREAM := Color("faf8ed")
const MUTED := Color("72817f")
const LINE := Color("d6ded3")
const RED := Color("ce5354")
const GOLD := Color("e5ba62")
var game: Node2D
var font: Font = REGULAR
var root: Control
var hud: Control
var modal: Control
var hp_bar: Control
var xp_bar: Control
var boss_bar: Control
var clock_label: Label
var level_label: Label
var hint_label: Label
var move_label: Label
var banner_label: Label
var region_label: Label
var hp_label: Label
var sfx_button: Button
var skill_nodes: Array = []
var query: String = ""
var generation: int = 0
var filter_type: String = ""
var page: int = 0
var results_box: Control
var count_label: Label
var page_label: Label
var search_input: LineEdit
var page_count: int = 1
func _ready() -> void:
 root=Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(root)
 var theme:=Theme.new()
 theme.default_font=font
 theme.default_font_size=14
 root.theme=theme
 hud=Control.new()
 hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
 root.add_child(hud)
 panel(hud,Rect2(18,14,283,67))
 label(hud,"PARTNER",Vector2(32,21),10,RED)
 level_label=label(hud,"",Vector2(32,36),19,INK,240)
 label(hud,"HP",Vector2(32,63),10,MUTED)
 hp_bar=bar(hud,Rect2(53,66,172,6),Color("73ac78"))
 hp_label=label(hud,"",Vector2(233,61),10,INK,58)
 panel(hud,Rect2(314,14,332,67))
 region_label=label(hud,"",Vector2(330,23),18,INK,300)
 label(hud,"EXPERIENCE",Vector2(330,52),10,MUTED)
 xp_bar=bar(hud,Rect2(416,58,212,5),Color("68a3bd"))
 panel(hud,Rect2(659,14,283,67))
 clock_label=label(hud,"",Vector2(675,25),28,INK,125)
 label(hud,"BOSS  01:30",Vector2(802,25),10,MUTED)
 sfx_button=button(hud,"音",Rect2(804,43,48,26),func():
  game.sound_on=not game.sound_on
  sfx_button.text="音" if game.sound_on else "OFF",false)
 button(hud,"Ⅱ",Rect2(861,43,63,26),func():
  if game.state=="playing":
   game.state="paused"
   show_pause(),false)
 panel(hud,Rect2(210,87,540,25),Color("f4f3df"),Color("d6ded3"),4)
 banner_label=label(hud,"",Vector2(215,91),12,INK,530)
 banner_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 boss_bar=bar(hud,Rect2(300,116,360,6),Color("ad7fa6"))
 boss_bar.visible=false
 for i in 4:
  var x:float=18+i*157
  panel(hud,Rect2(x,482,149,44))
  var mark=panel(hud,Rect2(x,482,4,44),RED,RED,0)
  var title=label(hud,"—",Vector2(x+12,488),14,INK,129)
  var rank=label(hud,"아직 배우지 않음",Vector2(x+12,509),10,MUTED,129)
  skill_nodes.append({"title":title,"rank":rank,"mark":mark})
 panel(hud,Rect2(659,482,283,44))
 hint_label=label(hud,"",Vector2(673,489),11,INK,254)
 label(hud,"WASD 이동  ·  SPACE 회피  ·  ESC 멈춤",Vector2(673,510),10,MUTED)
func panel(parent:Node,rect:Rect2,color:Color=CREAM,border:Color=LINE,radius:int=6)->Panel:
 var node:=Panel.new()
 node.position=rect.position
 node.size=rect.size
 node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var style:=StyleBoxFlat.new()
 style.bg_color=color
 style.border_color=border
 style.set_border_width_all(1)
 style.set_corner_radius_all(radius)
 node.add_theme_stylebox_override("panel",style)
 parent.add_child(node)
 return node
func label(parent:Node,text:String,pos:Vector2,size:int,color:Color=INK,width:float=0)->Label:
 var node:=Label.new()
 node.text=text
 node.position=pos
 if width>0:
  node.custom_minimum_size.x=width
  node.size.x=width
 node.add_theme_font_override("font",BOLD if size>=22 else (SEMIBOLD if size>=14 else REGULAR))
 node.add_theme_font_size_override("font_size",size)
 node.add_theme_color_override("font_color",color)
 node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)
 return node
func paragraph(parent:Node,text:String,rect:Rect2,size:int=14,color:Color=MUTED)->Label:
 var node=label(parent,text,rect.position,size,color)
 node.size=rect.size
 node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 return node
func bar(parent:Node,rect:Rect2,color:Color)->Control:
 var node=preload("res://scripts/meter.gd").new()
 node.position=rect.position
 node.size=rect.size
 node.tint=color
 node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)
 return node
func button(parent:Node,text:String,rect:Rect2,action:Callable,primary:bool=true)->Button:
 var node:=Button.new()
 node.text=text
 node.position=rect.position
 node.size=rect.size
 node.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 node.add_theme_font_override("font",SEMIBOLD)
 node.add_theme_font_size_override("font_size",16 if primary else 12)
 for st in ["normal","hover","pressed","focus"]:
  var style:=StyleBoxFlat.new()
  style.bg_color=RED if primary else Color("eef1e7")
  if st=="hover":style.bg_color=style.bg_color.lightened(0.12) if primary else Color("e1e9db")
  if st=="pressed":style.bg_color=style.bg_color.darkened(0.07)
  style.border_color=INK if st=="focus" else (RED if primary else LINE)
  style.set_border_width_all(2 if st=="focus" else 1)
  style.set_corner_radius_all(5)
  node.add_theme_stylebox_override(st,style)
 for st in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:node.add_theme_color_override(st,CREAM if primary else INK)
 node.pressed.connect(action)
 parent.add_child(node)
 return node
func sprite(parent:Node,number:int,rect:Rect2,animate:bool=false)->void:
 if not game.textures.has(number):return
 var node:=TextureRect.new()
 var atlas:=AtlasTexture.new()
 atlas.atlas=game.textures[number]
 atlas.region=game.crops[number]
 node.texture=atlas
 node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 node.position=rect.position
 node.size=rect.size
 node.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 node.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)
 if animate:
  node.pivot_offset=Vector2(rect.size.x*0.5,rect.size.y)
  var breathe=node.create_tween().set_loops()
  breathe.tween_property(node,"scale",Vector2(1.025,0.975),0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
  breathe.tween_property(node,"scale",Vector2(0.985,1.015),0.65).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
func badge(parent:Node,kind:String,pos:Vector2)->void:
 var c:Color=Catalog.COLORS.get(kind,RED)
 panel(parent,Rect2(pos,Vector2(56,23)),c,c,3)
 label(parent,Catalog.TYPE_NAMES.get(kind,"회복"),pos+Vector2(0,3),12,Color.WHITE,56).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
func close_modal()->void:
 if is_instance_valid(modal):
  root.remove_child(modal)
  modal.queue_free()
 modal=null
 hud.visible=game.state!="menu"
func overlay()->Control:
 close_modal()
 modal=Control.new()
 modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(modal)
 var shade:=ColorRect.new()
 shade.color=Color(0.09,0.17,0.18,0.38)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 modal.add_child(shade)
 return modal
func show_menu()->void:
 game.state="menu"
 overlay()
 hud.visible=false
 panel(modal,Rect2(0,0,960,540),Color("e9eddf"),Color("e9eddf"),0)
 panel(modal,Rect2(0,0,960,76),RED,RED,0)
 label(modal,"POKÉMON",Vector2(26,9),30,CREAM)
 label(modal,"M E A D O W  /  R O G U E L I K E",Vector2(29,48),10,Color("ffe3c8"))
 label(modal,"어떤 포켓몬과 떠날까요?",Vector2(332,15),24,CREAM)
 label(modal,"관동에서 호연까지, 나만의 한 번의 모험",Vector2(333,48),12,Color("ffe3c8"))
 label(modal,"FAN GAME",Vector2(835,18),13,CREAM)
 label(modal,"GEN 01 — 03",Vector2(835,40),11,Color("ffe3c8"))
 show_partner()
 search_input=LineEdit.new()
 search_input.name="DexSearch"
 search_input.placeholder_text="이름 · 영문 이름 · 도감 번호 검색"
 search_input.position=Vector2(328,91)
 search_input.size=Vector2(338,34)
 search_input.text=query
 search_input.add_theme_color_override("font_color",INK)
 search_input.add_theme_color_override("font_placeholder_color",MUTED)
 search_input.add_theme_font_override("font",REGULAR)
 var input_style:=StyleBoxFlat.new()
 input_style.bg_color=CREAM
 input_style.border_color=LINE
 input_style.set_border_width_all(1)
 input_style.set_corner_radius_all(5)
 input_style.content_margin_left=12
 search_input.add_theme_stylebox_override("normal",input_style)
 search_input.add_theme_stylebox_override("focus",input_style)
 modal.add_child(search_input)
 search_input.text_changed.connect(func(value):
  query=value
  page=0
  refresh_results())
 var generations:=OptionButton.new()
 generations.position=Vector2(678,91)
 generations.size=Vector2(120,34)
 for title in ["모든 세대","1세대 · 관동","2세대 · 성도","3세대 · 호연"]:generations.add_item(title)
 generations.select(generation)
 generations.add_theme_color_override("font_color",INK)
 generations.add_theme_stylebox_override("normal",input_style)
 modal.add_child(generations)
 generations.item_selected.connect(func(index):
  generation=index
  page=0
  refresh_results())
 var type_select:=OptionButton.new()
 type_select.position=Vector2(810,91)
 type_select.size=Vector2(121,34)
 type_select.add_item("모든 타입")
 var kinds=Catalog.TYPE_NAMES.keys()
 for kind in kinds:type_select.add_item(Catalog.TYPE_NAMES[kind])
 type_select.select(kinds.find(filter_type)+1)
 type_select.add_theme_color_override("font_color",INK)
 type_select.add_theme_stylebox_override("normal",input_style)
 modal.add_child(type_select)
 type_select.item_selected.connect(func(index):
  filter_type="" if index==0 else kinds[index-1]
  page=0
  refresh_results())
 count_label=label(modal,"",Vector2(330,137),12,MUTED)
 label(modal,"NATIONAL POKÉDEX",Vector2(785,137),10,MUTED)
 results_box=Control.new()
 results_box.position=Vector2(328,160)
 modal.add_child(results_box)
 page_label=label(modal,"",Vector2(494,455),12,MUTED,262)
 page_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 button(modal,"← 이전",Rect2(329,451,98,30),func():
  page=maxi(0,page-1)
  refresh_results(),false)
 button(modal,"다음 →",Rect2(833,451,98,30),func():
  page=mini(page_count-1,page+1)
  refresh_results(),false)
 label(modal,"01  관동의 숲     →     02  성도의 단풍길     →     03  호연의 해안",Vector2(332,500),12,INK)
 refresh_results()
func show_partner()->void:
 var number:int=game.selected_starter
 var row:Dictionary=game.rules.catalog.entries[number]
 var spec:Dictionary=game.rules.STARTERS[number]
 panel(modal,Rect2(20,91,287,391))
 label(modal,"MY PARTNER",Vector2(38,106),11,RED)
 label(modal,"No. %03d" % number,Vector2(213,106),12,MUTED)
 panel(modal,Rect2(36,135,255,153),spec.color.lightened(0.78),spec.color.lightened(0.6))
 # Poké Ball-inspired device motif, drawn locally; not a borrowed logo.
 var art=Node2D.new()
 art.position=Vector2(164,212)
 art.draw.connect(func():
  art.draw_arc(Vector2.ZERO,62,0,TAU,64,Color(1,1,1,0.65),3)
  art.draw_line(Vector2(-61,0),Vector2(61,0),Color(1,1,1,0.65),3)
  art.draw_circle(Vector2.ZERO,17,spec.color.lightened(0.78))
  art.draw_arc(Vector2.ZERO,17,0,TAU,32,Color(1,1,1,0.65),3))
 modal.add_child(art)
 sprite(modal,number,Rect2(103,149,122,126),true)
 label(modal,spec.name,Vector2(38,299),28,INK)
 for i in row.types.size():badge(modal,row.types[i],Vector2(39+i*63,343))
 var names:String=" → ".join(spec.names)
 paragraph(modal,names if spec.family.size()>1 else "완성된 모습으로 모험을 시작해요",Rect2(39,378,245,38),13,INK)
 label(modal,"Lv.5 / 9 진화 · 분기는 표시된 경로",Vector2(39,420),10,MUTED)
 label(modal,"시작 기술  /  "+game.rules.MOVES[spec.moves[0]].name,Vector2(39,442),13,spec.color)
 button(modal,"이 포켓몬과 출발  →",Rect2(20,491,287,35),func():game.start_run()).name="StartRun"
 button(modal,"출처",Rect2(243,451,48,26),func():show_credits(),false)
func refresh_results()->void:
 for child in results_box.get_children():
  results_box.remove_child(child)
  child.queue_free()
 var found:Array=game.rules.catalog.search(query,generation,filter_type)
 page_count=maxi(1,ceili(found.size()/18.0))
 page=clampi(page,0,page_count-1)
 count_label.text="%d마리 선택 가능  ·  진화체는 플레이 중 획득" % found.size()
 page_label.text="%02d / %02d   ·   클릭해서 파트너 선택" % [page+1,page_count]
 if found.is_empty():
  label(results_box,"찾는 포켓몬이 없어요",Vector2(150,94),22,INK)
  label(results_box,"기본 형태의 이름이나 필터로 찾아보세요",Vector2(167,135),13,MUTED)
 for i in mini(18,found.size()-page*18):
  var number:int=found[page*18+i]
  var row:Dictionary=game.rules.catalog.entries[number]
  var pos=Vector2((i%6)*102,(i/6)*94)
  var selected:bool=number==game.selected_starter
  var card=button(results_box,"",Rect2(pos,Vector2(94,86)),func():game.select_starter(number),false)
  card.name="Starter_%d" % number
  var style:=StyleBoxFlat.new()
  style.bg_color=Color("fff6df") if selected else CREAM
  style.border_color=RED if selected else LINE
  style.set_border_width_all(2 if selected else 1)
  style.set_corner_radius_all(5)
  card.add_theme_stylebox_override("normal",style)
  label(card,"%03d" % number,Vector2(7,5),9,RED if selected else MUTED)
  sprite(card,number,Rect2(23,14,49,46))
  label(card,row.name,Vector2(2,63),12,INK,90).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
func update_hud()->void:
 level_label.text="%s   Lv.%d" % [game.player_name(),game.level]
 region_label.text="%02d  %s · %s" % [game.region+1,Journey.STAGES[game.region].name,Journey.STAGES[game.region].place]
 clock_label.text="%02d:%02d" % [int(game.region_elapsed)/60,int(game.region_elapsed)%60]
 hp_bar.value=100.0*game.hp/game.max_hp
 hp_label.text="%d / %d" % [game.hp,game.max_hp]
 xp_bar.value=100.0*game.xp/game.rules.xp_needed(game.level)
 var moves:Array=game.rules.STARTERS[game.selected_starter].moves
 for i in 4:
  var id:String=moves[i]
  skill_nodes[i].title.text=game.rules.MOVES[id].name if game.ranks.has(id) else "미습득"
  skill_nodes[i].rank.text="● ".repeat(game.ranks.get(id,0))+"○ ".repeat(5-game.ranks.get(id,0))
  var style:StyleBoxFlat=skill_nodes[i].mark.get_theme_stylebox("panel").duplicate()
  style.bg_color=Catalog.COLORS[game.rules.MOVES[id].type] if game.ranks.has(id) else LINE
  style.border_color=style.bg_color
  skill_nodes[i].mark.add_theme_stylebox_override("panel",style)
 hint_label.text="회피 %s  ·  부적 %d개  ·  처치 %d" % ["준비" if game.dash_cooldown<=0 else "%.1fs" % game.dash_cooldown,game.relics.size(),game.kills]
 banner_label.text=game.banner if game.banner_time>0 else game.condition.name+"  /  "+game.condition.hint
 boss_bar.visible=false
 for foe in game.enemies:
  if foe.boss and not foe.dead:
   boss_bar.visible=true
   boss_bar.value=100.0*foe.hp/foe.max_hp
func choice_frame(tag:String,title:String,subtitle:String)->void:
 overlay()
 panel(modal,Rect2(45,65,870,410))
 label(modal,tag,Vector2(76,84),12,RED)
 label(modal,title,Vector2(76,109),30,INK)
 label(modal,subtitle,Vector2(78,152),13,MUTED)
 sprite(modal,game.player_number(),Rect2(826,85,60,68))
func show_upgrades(evolved:bool)->void:
 choice_frame("EVOLUTION" if evolved else "LEVEL UP / %02d" % game.level,"%s, 새로운 모습!" % game.player_name() if evolved else "어떤 기술을 키워 볼까요?","전투는 잠시 멈춰 있어요. 기술 하나를 선택하세요.  /  1 · 2 · 3")
 var count:int=game.offers.size()
 for i in count:
  var id:String=game.offers[i]
  var data:Dictionary=game.rules.MOVES[id]
  var x:float=76+i*274
  panel(modal,Rect2(x,192,260,251),Color("f0f2e8"))
  badge(modal,data.type,Vector2(x+18,210))
  label(modal,"0%d" % (i+1),Vector2(x+214,212),14,MUTED)
  label(modal,data.name,Vector2(x+18,256),25,INK)
  paragraph(modal,data.hint+"\n"+data.detail,Rect2(x+18,297,224,62),14)
  var rank:int=game.ranks.get(id,0)
  button(modal,"배우기" if rank==0 else "강화  %d → %d" % [rank,rank+1],Rect2(x+18,386,224,38),func():game.choose_upgrade(id))
func show_rewards()->void:
 choice_frame("STAGE CLEAR / %02d" % (game.region+1),"다음 모험을 위한 선물","부적 하나 선택 · 체력 25 회복 · 성장과 기술을 가지고 다음 지역으로 이동합니다.")
 for i in game.relic_offers.size():
  var id:String=game.relic_offers[i]
  var data:Dictionary=Journey.RELICS[id]
  var x:float=76+i*274
  panel(modal,Rect2(x,192,260,251),Color("f0f2e8"))
  panel(modal,Rect2(x+18,210,46,40),data.color.lightened(0.7),data.color,5)
  label(modal,"0%d" % (i+1),Vector2(x+29,216),20,data.color)
  label(modal,data.name,Vector2(x+18,265),23,INK)
  label(modal,data.hint,Vector2(x+18,310),15,MUTED)
  button(modal,"선택하고 다음 지역으로",Rect2(x+18,386,224,38),func():game.choose_relic(id))
func show_pause()->void:
 overlay()
 panel(modal,Rect2(290,130,380,290))
 label(modal,"PAUSE",Vector2(326,151),12,RED)
 label(modal,"잠깐 쉬어가기",Vector2(326,181),30,INK)
 label(modal,"%s · 부적 %d개" % [Journey.STAGES[game.region].place,game.relics.size()],Vector2(326,230),14,MUTED)
 button(modal,"계속하기",Rect2(325,279,310,42),func():
  game.state="playing"
  close_modal())
 button(modal,"도감으로 돌아가기",Rect2(325,340,310,35),func():show_menu(),false)
func show_result(won:bool)->void:
 overlay()
 panel(modal,Rect2(250,85,460,390))
 label(modal,"HALL OF FAME" if won else "UNTIL NEXT TIME",Vector2(290,108),13,RED)
 label(modal,"세 지역의 챔피언!" if won else "다음 모험을 기다릴게요",Vector2(290,139),28,INK)
 sprite(modal,game.player_number(),Rect2(427,192,104,100))
 label(modal,"지역 %d / 3   ·   Lv.%d   ·   %d마리 처치" % [game.region+1,game.level,game.kills],Vector2(286,313),15,MUTED,386).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 button(modal,"같은 파트너와 다시 출발",Rect2(290,360,380,39),func():game.start_run())
 button(modal,"다른 파트너 선택",Rect2(290,415,380,32),func():show_menu(),false)
func show_credits()->void:
 overlay()
 hud.visible=false
 panel(modal,Rect2(150,50,660,440))
 label(modal,"출처 / 이용 안내",Vector2(181,75),28)
 paragraph(modal,"비공식 · 비영리 팬 프로토타입 / 원작과 무관합니다.\n\n이미지: PokéAPI / sprites — 이미지 저작권 The Pokémon Company\nCC0 저장소 표기는 원작 IP 사용 허가를 의미하지 않습니다.\n원작 IP 권리는 미해결 상태이며 공개 배포하지 않습니다.\n\n이름·타입·진화 연결: PokéAPI 데이터 / 출처·버전·해시 기록\n폰트: Pretendard 1.3.9 · 길형진 · SIL Open Font License 1.1\n배경·이펙트·효과음: 자체 절차적 생성 / 엔진: Godot (MIT)\n\n기술 구성·진화 레벨·능력치는 생존 게임용 커스텀 규칙입니다.\n분기 진화는 도감에 표시된 대표 경로 하나를 따릅니다.",Rect2(182,126,596,285),14,MUTED)
 button(modal,"돌아가기",Rect2(182,433,596,35),func():show_menu())
