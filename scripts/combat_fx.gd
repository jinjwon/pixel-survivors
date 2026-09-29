extends RefCounted
const Catalog=preload("res://scripts/catalog.gd")
const Rules=preload("res://scripts/rules.gd")
static func color(move:String)->Color:
 return Catalog.COLORS[Rules.MOVES[move].type]
static func polygon(canvas:Node2D,points:Array,tint:Color)->void:
 canvas.draw_colored_polygon(PackedVector2Array(points),tint)
static func projectile(c:Node2D,s:Dictionary,t:float)->void:
 var p:Vector2=s.pos
 var v:Vector2=s.vel.normalized()
 var n:=v.orthogonal()
 var ink:Color=color(s.move)
 var light:Color=ink.lightened(0.62)
 match s.move:
  "ember":
   polygon(c,[p-v*20+n*3,p+v*5,p-v*7-n*5],ink)
   polygon(c,[p-v*10+n*2,p+v*3,p-v*4-n*2],Color("ffe9a0"))
   c.draw_rect(Rect2(p-v*24+n*sin(t*25)*3,Vector2(3,3)),ink)
  "watergun":
   c.draw_line(p-v*25,p,ink,6)
   c.draw_line(p-v*18,p+v*3,light,2)
   c.draw_circle(p+v*2,4,light)
  "bubble":
   c.draw_circle(p,8,Color(0.55,0.8,0.95,0.24))
   c.draw_arc(p,8,0,TAU,20,light,2)
   c.draw_arc(p,5,3.5,4.8,7,Color.WHITE,2)
  "razor":
   var r:Vector2=v.rotated(t*12)
   polygon(c,[p+r*11,p+r.orthogonal()*5,p-r*10,p-r.orthogonal()*3],ink)
   c.draw_line(p-r*7,p+r*8,light,1)
  "dragon","shadow":
   c.draw_line(p-v*19,p,ink,5)
   c.draw_circle(p,7,ink)
   c.draw_arc(p,9,t*5,t*5+4.5,15,light,2)
   c.draw_circle(p,3,light)
  "spark":
   var pts:=PackedVector2Array([p-v*22,p-v*12+n*5,p-v*9-n*4,p])
   c.draw_polyline(pts,ink,4)
   c.draw_polyline(pts,Color("fff4b0"),1)
  "ice":
   polygon(c,[p+v*11,p+n*5,p-v*10,p-n*5],ink)
   c.draw_line(p-v*7,p+v*8,Color.WHITE,2)
   c.draw_line(p-n*4,p+n*4,light,1)
  "swift":
   var pts:Array=[]
   for i in 10:pts.append(p+Vector2.RIGHT.rotated(t*5+i*TAU/10.0)*(9 if i%2==0 else 4))
   polygon(c,pts,Color("e9c355"))
   c.draw_circle(p,2,Color("fff3bb"))
  "gust":
   for i in 3:c.draw_arc(p-v*i*6,4+i*3,t*9+i,t*9+i+4,14,light,2)
  "sting":
   polygon(c,[p+v*12,p-v*7+n*3,p-v*7-n*3],ink)
   c.draw_line(p-v*4,p+v*9,light,1)
  "rock":
   polygon(c,[p+Vector2(-6,-4),p+Vector2(2,-8),p+Vector2(8,-1),p+Vector2(4,7),p+Vector2(-5,6)],ink)
   c.draw_line(p+Vector2(-4,-3),p+Vector2(2,-6),light,2)
static func effect(c:Node2D,e:Dictionary)->void:
 var progress:float=1.0-e.life/e.total
 var ink:Color=color(e.move)
 ink.a=(1.0-progress)*0.9
 var p:Vector2=e.pos
 var aim:Vector2=e.aim
 var angle:float=aim.angle()
 var radius:float=e.radius
 if e.kind=="impact":
  impact(c,e,progress,ink)
  return
 match e.move:
  "scratch","metal":
   for i in 3:
    var off:Vector2=aim.orthogonal()*(i-1)*12
    c.draw_arc(p+off,radius*(0.65+progress*0.25),angle-0.65+progress,angle+0.15+progress,12,ink,3 if e.move=="scratch" else 5)
  "tackle","quake":
   var r:float=radius*(0.25+progress*0.75)
   c.draw_arc(p,r,0,TAU,36,ink,3)
   for i in 8:
    var v:=Vector2.RIGHT.rotated(i*TAU/8)
    c.draw_line(p+v*r,p+v*(r+9),ink,2)
  "bite":
   var r:float=radius*(0.55-progress*0.2)
   for signum in [-1,1]:
    for i in 5:
     var off:=Vector2((i-2)*12,signum*r*0.35)
     polygon(c,[p+off+Vector2(-4,signum*9),p+off+Vector2(4,signum*9),p+off-Vector2(0,signum*5)],ink)
  "vine":
   for side in [-1,1]:
    var pts:=PackedVector2Array()
    for i in 17:
     var u:float=i/16.0
     pts.append(p+aim*u*radius+aim.orthogonal()*sin(u*PI)*side*radius*0.6*sin(progress*PI))
    c.draw_polyline(pts,ink,3)
    c.draw_circle(pts[-1],4,ink)
  "flame":
   for i in 11:
    var v:=aim.rotated((i-5)*0.12)
    var r:float=radius*(0.25+progress*0.6)
    polygon(c,[p+v*r,p+v*r*0.36+v.orthogonal()*9,p+v*r*0.22-v.orthogonal()*7],ink)
    c.draw_line(p+v*r*0.35,p+v*r*0.72,Color(1,0.85,0.43,ink.a),3)
  "sludge":
   for i in 9:
    var v:=aim.rotated((i-4)*0.16)
    c.draw_circle(p+v*radius*(0.2+progress*0.65),5+i%3*2,ink)
  "psychic":
   for i in 3:c.draw_arc(p+aim*(i+1)*radius*0.25,(12+i*7)*(0.5+progress),angle-1.8,angle+1.8,22,ink,3)
  "punch":
   for i in 5:
    var v:=aim.rotated((i-2)*0.26)
    c.draw_line(p+v*radius*0.3,p+v*radius*(0.6+progress*0.3),ink,4)

static func impact(c:Node2D,e:Dictionary,t:float,ink:Color)->void:
 var p:Vector2=e.pos
 var r:float=4.0+t*18.0
 match e.move:
  "scratch","metal":
   for i in 3:
    var at:Vector2=p+Vector2((i-1)*6,0)
    c.draw_line(at+Vector2(-4,7)*(1-t),at+Vector2(6,-8),ink,2 if e.move=="scratch" else 3)
   if e.move=="metal":c.draw_arc(p,r,0,PI,12,ink,1)
  "tackle":
   c.draw_arc(p,r,0,TAU,20,ink,3)
   c.draw_line(p-Vector2(r+5,0),p-Vector2(r,0),ink,2)
   c.draw_line(p+Vector2(r,0),p+Vector2(r+5,0),ink,2)
  "bite":
   for side in [-1,1]:
    for i in 3:
     var at:Vector2=p+Vector2((i-1)*7,side*(8-t*5))
     polygon(c,[at+Vector2(-3,side*4),at+Vector2(3,side*4),at-Vector2(0,side*4)],ink)
  "bubble":
   c.draw_arc(p,r,0,TAU,20,ink,1)
   for i in 4:c.draw_circle(p+Vector2.RIGHT.rotated(i*PI/2)*r,2,ink)
  "watergun":
   for i in 7:
    var v:=Vector2.RIGHT.rotated(i*TAU/7)
    c.draw_line(p+v*r*0.5,p+v*r,ink,2)
    c.draw_circle(p+v*r,2,ink)
  "ember":
   for i in 5:
    var v:=Vector2.RIGHT.rotated(i*TAU/5)
    c.draw_rect(Rect2(p+v*r-Vector2(2,2),Vector2(4,4)),ink)
  "flame":
   for i in 5:
    var at:Vector2=p+Vector2((i-2)*5,-t*24+i%2*5)
    polygon(c,[at-Vector2(0,6),at+Vector2(3,4),at+Vector2(-3,4)],ink)
  "vine":
   for i in 3:
    var at:Vector2=p+Vector2.RIGHT.rotated(i*TAU/3+t)*r
    polygon(c,[at-Vector2(5,0),at-Vector2(0,3),at+Vector2(5,0),at+Vector2(0,3)],ink)
  "razor":
   c.draw_line(p-Vector2(r,r)*0.6,p+Vector2(r,r)*0.6,ink,3)
   c.draw_line(p-Vector2(-r,r)*0.4,p+Vector2(-r,r)*0.4,ink,2)
  "sludge":
   c.draw_circle(p,7*(1-t),ink)
   for i in 5:c.draw_circle(p+Vector2.RIGHT.rotated(i*TAU/5)*r,3,ink)
  "dragon":
   c.draw_arc(p,r,0,TAU,20,ink,2)
   c.draw_arc(p,r*0.6,0,TAU,20,ink,2)
  "shadow":
   for i in 4:c.draw_circle(p+Vector2.RIGHT.rotated(i*PI/2+t)*r*0.55,6*(1-t),ink)
  "spark":
   for i in 4:
    var v:=Vector2.RIGHT.rotated(i*PI/2)
    c.draw_polyline(PackedVector2Array([p+v*3,p+v*r*0.6+v.orthogonal()*4,p+v*r]),ink,2)
  "ice":
   for i in 4:
    var at:Vector2=p+Vector2.RIGHT.rotated(i*PI/2)*r
    polygon(c,[at-Vector2(0,5),at+Vector2(3,0),at+Vector2(0,5),at-Vector2(3,0)],ink)
  "swift":
   for i in 5:
    var v:=Vector2.RIGHT.rotated(i*TAU/5)
    c.draw_line(p+v*3,p+v*r,ink,3)
  "gust":
   for i in 3:c.draw_arc(p,r+i*3,t*5+i,t*5+i+2,9,ink,1)
  "sting":
   for i in 3:c.draw_line(p+Vector2(i*4-4,-r),p+Vector2(i*4-4,r*0.4),ink,2)
  "rock":
   for i in 4:
    var at:Vector2=p+Vector2.RIGHT.rotated(i*PI/2)*r
    c.draw_rect(Rect2(at,Vector2(4,3)),ink)
  "quake":
   for i in 5:
    var v:=Vector2.RIGHT.rotated(i*TAU/5)
    c.draw_polyline(PackedVector2Array([p,p+v*r*0.5,p+v*r+Vector2(3,2)]),ink,2)
  "psychic":
   c.draw_arc(p,r,0,TAU,24,ink,2)
   c.draw_arc(p,r*0.45+t*2,0,TAU,24,ink,1)
   c.draw_circle(p,2,ink)
  "punch":
   polygon(c,[p+Vector2(0,-r),p+Vector2(4,-4),p+Vector2(r,0),p+Vector2(4,4),p+Vector2(0,r),p+Vector2(-4,4),p+Vector2(-r,0),p+Vector2(-4,-4)],ink)
