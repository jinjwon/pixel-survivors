extends RefCounted
# Small transform-based acting on the original front sprite; not a walk sheet.
static func pose(time:float,walking:float=0.0,attack:float=0.0,dashing:bool=false,facing:float=1.0,flinch:float=0.0)->Dictionary:
 var stride:float=sin(time*13.0)
 var breath:float=sin(time*2.8)
 var squash:float=0.014*breath+absf(stride)*0.025*walking
 var hop:float=-absf(stride)*3.5*walking-breath*0.65*(1.0-walking)
 var lean:float=stride*0.045*walking
 var recoil:float=sin(clampf(attack/0.18,0.0,1.0)*PI)
 var offset:=Vector2(facing*recoil*4.0,hop)
 var scale:=Vector2(1.0+squash-recoil*0.025,1.0-squash+recoil*0.04)
 if dashing:
  offset.y-=2
  lean=facing*0.13
  scale=Vector2(1.08,0.94)
 if flinch>0:
  offset.x+=sin(flinch*90.0)*2.0
  lean-=facing*0.07
 return {"offset":offset,"scale":scale,"lean":lean}
