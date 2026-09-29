extends Node2D
var region: int = 0

func _ready() -> void:
 queue_redraw()

func tree(p: Vector2, s: float = 1.0) -> void:
 var dark:Color=[Color("467a4d"),Color("9c6841"),Color("368576")][region]
 var mid:Color=[Color("69a162"),Color("c99453"),Color("54a98a")][region]
 var light:Color=[Color("9bc77f"),Color("ebbe72"),Color("8ac79c")][region]
 draw_rect(Rect2(p+Vector2(-5,5)*s,Vector2(10,18)*s),Color("8c8060"))
 draw_rect(Rect2(p+Vector2(0,7)*s,Vector2(3,13)*s),Color("b6a279"))
 # Stepped, scalloped canopy rather than soft shadows or smooth gradients.
 for rect in [Rect2(-18,-29,36,40),Rect2(-25,-19,50,24),Rect2(-10,-36,20,8)]:
  draw_rect(Rect2(p+rect.position*s,rect.size*s),dark)
 for rect in [Rect2(-18,-26,36,28),Rect2(-22,-17,45,12),Rect2(-9,-32,19,9)]:
  draw_rect(Rect2(p+rect.position*s,rect.size*s),mid)
 for rect in [Rect2(-11,-29,17,5),Rect2(-17,-21,13,5),Rect2(4,-20,12,4),Rect2(-8,-12,10,4)]:
  draw_rect(Rect2(p+rect.position*s,rect.size*s),light)
 draw_rect(Rect2(p+Vector2(10,-4)*s,Vector2(9,4)*s),dark)
 draw_rect(Rect2(p+Vector2(-17,0)*s,Vector2(9,4)*s),dark)

func _draw() -> void:
 draw_rect(Rect2(0,0,960,540),[Color("6b9a70"),Color("b2986b"),Color("68b4b0")][region])
 draw_rect(Rect2(36,75,888,410),[Color("99be82"),Color("c6b38c"),Color("c9cf9d")][region])
 draw_rect(Rect2(52,90,856,383),[Color("accd91"),Color("ddcc9c"),Color("e1dcaf")][region])
 var rng := RandomNumberGenerator.new()
 rng.seed = 3401
 for i in 420:
  var p := Vector2(rng.randi_range(54,903),rng.randi_range(92,470))
  var c: Color = [Color("96bc7f"),Color("c8b783"),Color("cdc799")][region] if i % 3 else [Color("bdd99f"),Color("e7d8ab"),Color("eee7c4")][region]
  draw_rect(Rect2(p,Vector2(3,2)),c)
  if i % 5 == 0:
   draw_line(p+Vector2(-3,0),p+Vector2(-4,-4),c,2)
   draw_line(p,p+Vector2(1,-5),c,2)
 # Winding light footpath; decorative, all field surfaces walkable.
 for x in range(90,870,8):
  var y := 285 + int(sin(float(x)*0.008)*33)
  draw_rect(Rect2(x,y,9,42),Color("cbd3a1"))
  draw_rect(Rect2(x,y+6,9,28),Color("e3dfb1"))
 draw_rect(Rect2(690,130,133,59),Color("567d67"))
 draw_rect(Rect2(700,122,114,59),Color("7fc8c5"))
 draw_rect(Rect2(714,116,84,73),Color("7fc8c5"))
 draw_rect(Rect2(718,132,72,3),Color("c2e5d7"))
 draw_rect(Rect2(745,162,52,3),Color("c2e5d7"))
 # Pixel ground accents echo a GBA field without obscuring combat.
 for gx in range(98,214,12):
  for gy in range(359,415,12):
   var grass:Color=[Color("83ad71"),Color("bea568"),Color("b9bd84")][region]
   draw_line(Vector2(gx,gy+4),Vector2(gx-2,gy),grass,2)
   draw_line(Vector2(gx+3,gy+4),Vector2(gx+5,gy-2),grass,2)
   draw_line(Vector2(gx+6,gy+5),Vector2(gx+8,gy+1),grass,2)
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

 # Different regional landmarks; decorative and fully walkable.
 if region==1:
  for j in 5:
   var at:=Vector2(710+j*16,364-j%2*4)
   draw_rect(Rect2(at,Vector2(15,26)),Color("b3ac97"))
   draw_rect(Rect2(at+Vector2(2,-4),Vector2(11,5)),Color("ece4c7"))
 if region==2:
  for j in 14:
   var at:=Vector2(730+j%7*18,371+j/7*18)
   draw_rect(Rect2(at,Vector2(16,14)),Color("7fc8c5"))
   draw_line(at+Vector2(2,3),at+Vector2(13,3),Color("d9f0df"),2)
