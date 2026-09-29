extends RefCounted
var entries: Dictionary = {}
var evolved_ids: Dictionary = {}
const TYPE_NAMES = {"normal":"노말","fire":"불꽃","water":"물","grass":"풀","electric":"전기","ice":"얼음","fighting":"격투","poison":"독","ground":"땅","flying":"비행","psychic":"에스퍼","bug":"벌레","rock":"바위","ghost":"고스트","dragon":"드래곤","dark":"악","steel":"강철"}
const COLORS = {"normal":Color("a8a78d"),"fire":Color("e5784f"),"water":Color("568fc8"),"grass":Color("73a963"),"electric":Color("d4ad38"),"ice":Color("67bcb9"),"fighting":Color("bc655d"),"poison":Color("a274b8"),"ground":Color("b69762"),"flying":Color("9185bc"),"psychic":Color("d77b9d"),"bug":Color("93a844"),"rock":Color("a79662"),"ghost":Color("8274ae"),"dragon":Color("767cc5"),"dark":Color("7d7989"),"steel":Color("849ca5"),"heal":Color("73a963")}
const TYPE_MOVES = {"normal":"swift","fire":"ember","water":"watergun","grass":"vine","electric":"spark","ice":"ice","fighting":"punch","poison":"sludge","ground":"quake","flying":"gust","psychic":"psychic","bug":"sting","rock":"rock","ghost":"shadow","dragon":"dragon","dark":"bite","steel":"metal"}
func _init() -> void:
 var rows = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/roster.json"))
 if rows is Array:
  for row in rows: entries[int(row.id)] = row
  for row in rows:
   for child in row.children: evolved_ids[int(child)]=true
func can_start(number:int)->bool:
 return entries.has(number) and not evolved_ids.has(number)
func family(number: int) -> Array:
 var ids: Array = [number]
 while ids.size() < 3:
  var children: Array = entries[ids[-1]].children
  if children.is_empty(): break
  ids.append(int(children[0]))
 return ids
func profile(number: int) -> Dictionary:
 var row: Dictionary = entries[number]
 var ids: Array = family(number)
 var names: Array = []
 var types: Array = []
 for id in ids:
  names.append(entries[id].name)
  types.append(entries[id].types)
 var moves: Array = [TYPE_MOVES[row.types[0]]]
 for kind in row.types:
  if not TYPE_MOVES[kind] in moves: moves.append(TYPE_MOVES[kind])
 var extras: Array = {"fire":["scratch","flame","swift"],"water":["bubble","bite","tackle"],"grass":["razor","sludge","tackle"]}.get(row.types[0],["swift","tackle","bite"])
 for move in extras:
  if not move in moves and moves.size()<4: moves.append(move)
 for move in ["scratch","swift","tackle"]:
  if not move in moves and moves.size()<4: moves.append(move)
 # Preserve the original three partner loadouts.
 if number in [1,4,7]:
  moves = {1:["vine","tackle","razor","sludge"],4:["ember","scratch","dragon","flame"],7:["watergun","tackle","bite","bubble"]}[number]
 return {"name":row.name,"family":ids,"names":names,"types":types,"moves":moves,"badge":TYPE_NAMES[row.types[0]],"color":COLORS[row.types[0]],"style":"타입 기반 생존 기술","tip":"기술과 상성을 조합하며 세 지역을 탐험하세요"}
func search(query: String = "", generation: int = 0, kind: String = "") -> Array:
 var result: Array = []
 var needle := query.strip_edges().to_lower()
 for id in entries:
  if not can_start(id): continue
  var row: Dictionary = entries[id]
  if generation>0 and int(row.generation)!=generation: continue
  if not kind.is_empty() and not kind in row.types: continue
  if not needle.is_empty() and not needle in str(row.name).to_lower() and not needle in str(row.slug) and not str(id).pad_zeros(3).contains(needle): continue
  result.append(id)
 return result
