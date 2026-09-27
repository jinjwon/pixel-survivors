extends Node2D

func _ready() -> void:
 queue_redraw()

func tree(p: Vector2, s: float = 1.0) -> void:
 draw_rect(Rect2(p + Vector2(-17,14)*s, Vector2(42,13)*s), Color("243f38"))
 draw_rect(Rect2(p + Vector2(-4,0)*s, Vector2(8,23)*s), Color("6b6350"))
 draw_rect(Rect2(p + Vector2(-24,-26)*s, Vector2(48,37)*s), Color("244b42"))
 draw_rect(Rect2(p + Vector2(-18,-35)*s, Vector2(34,34)*s), Color("35644e"))
 draw_rect(Rect2(p + Vector2(-13,-35)*s, Vector2(22,9)*s), Color("4c7957"))
 draw_rect(Rect2(p + Vector2(-26,-15)*s, Vector2(10,17)*s), Color("2d5845"))
 draw_rect(Rect2(p + Vector2(13,-11)*s, Vector2(15,20)*s), Color("2d5845"))

func _draw() -> void:
 draw_rect(Rect2(0,0,960,540),Color("325b48"))
 draw_rect(Rect2(36,75,888,410),Color("749665"))
 draw_rect(Rect2(52,90,856,383),Color("7f9f6d"))
 var rng := RandomNumberGenerator.new()
 rng.seed = 3401
 for i in 420:
  var p := Vector2(rng.randi_range(54,903),rng.randi_range(92,470))
  var c := Color("6f905f") if i % 3 else Color("92ac78")
  draw_rect(Rect2(p,Vector2(3,2)),c)
  if i % 5 == 0:
   draw_line(p+Vector2(-3,0),p+Vector2(-4,-4),c,2)
   draw_line(p,p+Vector2(1,-5),c,2)
 # Winding light footpath; decorative, all field surfaces walkable.
 for x in range(90,870,8):
  var y := 285 + int(sin(float(x)*0.008)*33)
  draw_rect(Rect2(x,y,9,42),Color("aaa982"))
  draw_rect(Rect2(x,y+6,9,28),Color("b7b38d"))
 draw_rect(Rect2(690,130,133,59),Color("567d67"))
 draw_rect(Rect2(700,122,114,59),Color("75a6a0"))
 draw_rect(Rect2(714,116,84,73),Color("75a6a0"))
 draw_rect(Rect2(718,132,72,3),Color("a1c7b6"))
 draw_rect(Rect2(745,162,52,3),Color("a1c7b6"))
 # Small flowers, leaf litter and stones.
 for i in 32:
  var p := Vector2(rng.randi_range(90,866),rng.randi_range(120,450))
  draw_rect(Rect2(p+Vector2(0,3),Vector2(2,5)),Color("4f7e51"))
  var petal := Color("e8d9a0") if i%2 else Color("d9a6ac")
  draw_rect(Rect2(p+Vector2(-2,0),Vector2(6,3)),petal)
  draw_rect(Rect2(p+Vector2(0,-2),Vector2(2,7)),petal)
 for x in range(30,950,48):
  tree(Vector2(x,90),1.15)
  tree(Vector2(x+14,514),1.05)
 for y in range(140,490,54):
  tree(Vector2(23,y),1.1)
  tree(Vector2(940,y+15),1.1)
 # Signposts are decorative.
 draw_rect(Rect2(130,175,5,24),Color("77674e"))
 draw_rect(Rect2(113,165,40,18),Color("c0af7d"))
 draw_line(Vector2(120,174),Vector2(144,174),Color("77674e"),2)
