extends CanvasLayer

var game: Node2D
var font: SystemFont
var root: Control
var hud: Control
var modal: Control
var hp_bar: Control
var xp_bar: Control
var clock_label: Label
var level_label: Label
var hint_label: Label
var move_label: Label
var boss_bar: Control
var banner_label: Label
var sfx_button: Button
const CREAM := Color("f4f0d6")
const MUTED := Color("b7c9b6")
const INK := Color("152f2c")
const GOLD := Color("e7cb83")

func _ready() -> void:
 font = SystemFont.new()
 font.font_names = PackedStringArray(["Apple SD Gothic Neo","Arial"])
 root = Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(root)
 var theme := Theme.new()
 theme.default_font = font
 theme.default_font_size = 16
 root.theme = theme
 hud = Control.new()
 hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
 root.add_child(hud)
 panel(hud,Rect2(20,16,920,67),Color("193a32"),Color("547761"))
 label(hud,"POKÉMON  /  MEADOW",Vector2(38,26),13,GOLD)
 level_label = label(hud,"파이리  ·  Lv.1",Vector2(38,45),19,CREAM)
 clock_label = label(hud,"00:00",Vector2(426,25),30,CREAM,110)
 label(hud,"SURVIVE / 03:00",Vector2(424,61),10,MUTED)
 hp_bar = bar(hud,Rect2(686,34,164,9),Color("d58d7c"))
 label(hud,"HP",Vector2(659,27),11,MUTED)
 xp_bar = bar(hud,Rect2(253,78,454,5),Color("dfd28b"))
 sfx_button = button(hud,"♪",Rect2(865,29,30,28),func():
  game.sound_on = not game.sound_on
  sfx_button.text = "♪" if game.sound_on else "×",false)
 button(hud,"Ⅱ",Rect2(899,29,27,28),func():
  if game.state == "playing":
   game.state = "paused"
   show_pause(),false)
 panel(hud,Rect2(20,489,920,35),Color("193a32"),Color("547761"))
 move_label = label(hud,"",Vector2(35,497),12,CREAM,555)
 hint_label = label(hud,"WASD 이동  ·  SPACE 회피  ·  ESC 멈춤",Vector2(595,498),11,MUTED,330)
 banner_label = label(hud,"",Vector2(180,98),17,CREAM,600)
 banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 boss_bar = bar(hud,Rect2(300,121,360,7),Color("b696d5"))
 boss_bar.visible = false

func panel(parent: Node, rect: Rect2, color: Color = INK, border: Color = Color("547761")) -> Panel:
 var node := Panel.new()
 node.position = rect.position
 node.size = rect.size
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var style := StyleBoxFlat.new()
 style.bg_color = color
 style.border_color = border
 style.set_border_width_all(1)
 style.set_corner_radius_all(10)
 node.add_theme_stylebox_override("panel",style)
 parent.add_child(node)
 return node

func label(parent: Node, text: String, pos: Vector2, size: int, color: Color = CREAM, width: float = 0) -> Label:
 var node := Label.new()
 node.text = text
 node.position = pos
 if width > 0: node.custom_minimum_size.x = width
 node.add_theme_font_size_override("font_size",size)
 node.add_theme_color_override("font_color",color)
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)
 return node

func paragraph(parent: Node, text: String, rect: Rect2, size: int = 14, color: Color = MUTED) -> Label:
 var node := label(parent,text,rect.position,size,color)
 node.size = rect.size
 node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 return node

func bar(parent: Node, rect: Rect2, color: Color) -> Control:
 var node = preload("res://scripts/meter.gd").new()
 node.position = rect.position
 node.size = rect.size
 node.tint = color
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)
 return node

func button(parent: Node, text: String, rect: Rect2, action: Callable, primary: bool = true) -> Button:
 var node := Button.new()
 node.text = text
 node.position = rect.position
 node.size = rect.size
 node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 node.add_theme_font_size_override("font_size",16 if primary else 13)
 for state_name in ["normal","hover","pressed","focus"]:
  var style := StyleBoxFlat.new()
  style.bg_color = GOLD if primary else Color("24473c")
  if state_name == "hover": style.bg_color = style.bg_color.lightened(0.12)
  if state_name == "pressed": style.bg_color = style.bg_color.darkened(0.1)
  style.set_corner_radius_all(7)
  style.border_color = Color("b8d89d") if state_name == "focus" else Color("63836c")
  style.set_border_width_all(2 if state_name == "focus" else 1)
  node.add_theme_stylebox_override(state_name,style)
 node.add_theme_color_override("font_color",INK if primary else CREAM)
 node.add_theme_color_override("font_hover_color",INK if primary else CREAM)
 node.add_theme_color_override("font_pressed_color",INK if primary else CREAM)
 node.pressed.connect(action)
 parent.add_child(node)
 return node

func sprite(parent: Node, number: int, rect: Rect2) -> void:
 if not game.textures.has(number): return
 var node := TextureRect.new()
 node.position = rect.position
 node.size = rect.size
 node.texture = game.textures[number]
 node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
 node.mouse_filter = Control.MOUSE_FILTER_IGNORE
 parent.add_child(node)

func close_modal() -> void:
 if is_instance_valid(modal):
  root.remove_child(modal)
  modal.queue_free()
 modal = null
 hud.visible = game.state != "menu"

func overlay() -> Control:
 close_modal()
 modal = Control.new()
 modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.add_child(modal)
 var shade := ColorRect.new()
 shade.color = Color(0.035,0.10,0.09,0.72)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 modal.add_child(shade)
 return modal

func show_menu() -> void:
 game.state = "menu"
 overlay()
 hud.visible = false
 panel(modal,Rect2(55,29,850,482),Color("173a31"),Color("708968"))
 label(modal,"POKÉMON / MEADOW",Vector2(87,49),12,GOLD)
 label(modal,"첫 모험을 함께할 포켓몬은?",Vector2(85,77),32,CREAM)
 label(modal,"파트너를 고르고 출발하세요. 경험치를 모으면 두 번 진화합니다.",Vector2(88,121),14,MUTED)
 for i in game.rules.STARTER_ORDER.size():
  var number: int = game.rules.STARTER_ORDER[i]
  var spec: Dictionary = game.rules.STARTERS[number]
  var selected: bool = game.selected_starter == number
  var x: float = 86+i*267
  var card := button(modal,"",Rect2(x,158,253,258),func():game.select_starter(number),false)
  card.name = "Starter_%d" % number
  card.tooltip_text = "%s 선택 · %s" % [spec.name,spec.badge]
  for state_name in ["normal","hover","pressed","focus"]:
   var style := StyleBoxFlat.new()
   style.bg_color = Color("2c5141") if selected else Color("1b3c33")
   if state_name=="hover": style.bg_color=style.bg_color.lightened(0.08)
   style.border_color = spec.color if selected or state_name=="focus" else Color("496b54")
   style.set_border_width_all(2 if selected or state_name=="focus" else 1)
   style.set_corner_radius_all(10)
   card.add_theme_stylebox_override(state_name,style)
  label(modal,"선택됨" if selected else "%d" % [i+1],Vector2(x+17,172),12,spec.color)
  label(modal,spec.badge,Vector2(x+151,172),12,spec.color,84).horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
  sprite(modal,number,Rect2(x+57,185,140,140))
  label(modal,spec.name,Vector2(x+18,314),25,CREAM,217).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  label(modal,game.rules.MOVES[spec.moves[0]].name+"로 시작",Vector2(x+18,349),13,spec.color,217).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  label(modal,spec.style,Vector2(x+18,377),12,MUTED,217).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 var chosen: Dictionary = game.rules.STARTERS[game.selected_starter]
 label(modal," → ".join(chosen.names),Vector2(88,430),15,chosen.color)
 label(modal,"Lv.5 / Lv.9 진화   ·   1 · 2 · 3 선택 / Enter 출발",Vector2(88,459),11,MUTED)
 button(modal,chosen.name+"와 출발   →",Rect2(613,431,259,47),func():game.start_run()).name="StartRun"
 button(modal,"출처 / 이용 안내",Rect2(89,482,123,22),func():show_credits(),false)

func update_hud() -> void:
 level_label.text = "%s  ·  Lv.%d" % [game.player_name(),game.level]
 clock_label.text = "%02d:%02d" % [int(game.elapsed)/60,int(game.elapsed)%60]
 hp_bar.value = game.hp
 xp_bar.value = 100.0*game.xp/game.rules.xp_needed(game.level)
 var slots: Array[String] = []
 for move in game.rules.STARTERS[game.selected_starter].moves:
  if game.ranks.has(move): slots.append("%s %d" % [game.rules.MOVES[move].name,game.ranks[move]])
  else: slots.append("—")
 move_label.text = "   /   ".join(slots)
 hint_label.text = "WASD 이동 · SPACE 회피 %s · ESC 멈춤" % ("준비" if game.dash_cooldown<=0 else "%.1fs" % game.dash_cooldown)
 banner_label.text = game.banner if game.banner_time > 0 else game.rules.STARTERS[game.selected_starter].tip
 boss_bar.visible = false
 for foe in game.enemies:
  if foe.boss and not foe.dead:
   boss_bar.visible = true
   boss_bar.value = 100*foe.hp/foe.max_hp

func show_upgrades(evolved: bool) -> void:
 overlay()
 label(modal,"EVOLUTION!" if evolved else "LEVEL UP",Vector2(365,94),30,GOLD,230).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var heading: String = "%s 진화! 기술을 골라 주세요" % game.player_name() if evolved else "어떤 기술과 함께할까요?"
 label(modal,heading,Vector2(210,144),23,CREAM,540).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 label(modal,"전투는 잠시 멈춰 있어요 · 클릭 또는 숫자 1 / 2 / 3",Vector2(230,181),13,MUTED,500).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 var count: int = game.offers.size()
 for i in count:
  var move: String = game.offers[i]
  var data: Dictionary = game.rules.MOVES[move]
  var x: float = 480-count*123+i*246+9
  panel(modal,Rect2(x,222,228,221),Color("1c4035"),Color("78906a"))
  var color: Color = {"fire":Color("f2b183"),"normal":CREAM,"dragon":Color("cdb6e6"),"heal":Color("bbd899"),"water":Color("93cce7"),"grass":Color("b8d98b"),"poison":Color("c897dd"),"dark":Color("c9b1d7")}[data.type]
  label(modal,"0%d   /   %s" % [i+1,{"fire":"불꽃","normal":"노말","dragon":"드래곤","heal":"회복","water":"물","grass":"풀","poison":"독","dark":"악"}[data.type]],Vector2(x+18,240),12,color)
  label(modal,data.name,Vector2(x+18,271),25,CREAM)
  paragraph(modal,data.hint+"\n"+data.detail,Rect2(x+18,315,192,62),13)
  var rank: int = game.ranks.get(move,0)
  var text: String = "새로 배우기" if rank==0 else "Lv.%d → Lv.%d" % [rank,rank+1]
  if move == "heal": text = "체력 회복"
  button(modal,text,Rect2(x+18,388,192,37),func():game.choose_upgrade(move))

func show_pause() -> void:
 overlay()
 panel(modal,Rect2(300,160,360,235))
 label(modal,"잠깐 쉬어가기",Vector2(354,189),29,CREAM)
 label(modal,"시간과 전투가 멈춰 있습니다",Vector2(376,239),13,MUTED)
 button(modal,"계속하기",Rect2(340,285,280,40),func():
  game.state="playing"
  close_modal())
 button(modal,"시작 화면으로",Rect2(340,341,280,30),func():show_menu(),false)

func show_result(won: bool) -> void:
 overlay()
 panel(modal,Rect2(263,100,434,355))
 label(modal,"MEADOW CLEARED" if won else "UNTIL NEXT TIME",Vector2(307,130),20,GOLD,345).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 label(modal,"멋진 모험이었어요" if won else "다시, 첫걸음부터",Vector2(294,171),28,CREAM,372).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 sprite(modal,game.player_number(),Rect2(435,215,90,90))
 label(modal,"%02d:%02d 생존    ·    Lv.%d    ·    %d마리" % [int(game.elapsed)/60,int(game.elapsed)%60,game.level,game.kills],Vector2(307,303),15,MUTED,345).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 button(modal,"다시 출발",Rect2(306,347,348,41),func():game.start_run())
 button(modal,"시작 화면",Rect2(306,402,348,28),func():show_menu(),false)

func show_credits() -> void:
 overlay()
 hud.visible=false
 panel(modal,Rect2(165,75,630,397))
 label(modal,"출처 / 이용 안내",Vector2(197,103),28,CREAM)
 paragraph(modal,"비공식 · 비영리 로컬 프로토타입\n\n포켓몬 이미지: PokéAPI / sprites 저장소\n이미지 저작권: The Pokémon Company (원본 고지 기준)\n저장소 CC0 표기는 포켓몬 이미지 권리 허가와 별개입니다.\n원작 IP 사용 허가는 해결되지 않았으며, 공개 배포하지 않습니다.\n\n코드: 이 프로젝트에서 작성 / 엔진: Godot (MIT)\n배경·효과음: 프로젝트 내 절차적 생성\n진화 레벨·기술 효과는 생존 게임용으로 조정했습니다.\n원본 URL·버전·해시는 assets/manifest.json에 기록했습니다.",Rect2(199,154,568,244),15,MUTED)
 button(modal,"돌아가기",Rect2(199,416,562,33),func():show_menu())
