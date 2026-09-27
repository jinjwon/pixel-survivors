extends Control
var value: float = 100:
 set(v):
  value = clampf(v,0,100)
  queue_redraw()
var tint := Color.WHITE
func _draw() -> void:
 draw_rect(Rect2(Vector2.ZERO,size),Color("102b29"))
 draw_rect(Rect2(Vector2.ZERO,Vector2(size.x*value/100.0,size.y)),tint)
