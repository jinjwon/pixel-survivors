extends RefCounted

const STARTER_ORDER = [4,7,1]
const STARTERS = {
 4:{"name":"파이리","family":[4,5,6],"names":["파이리","리자드","리자몽"],"types":[["fire"],["fire"],["fire","flying"]],"moves":["ember","scratch","dragon","flame"],"badge":"불꽃","color":Color("f2b183"),"style":"불씨와 부채꼴 공격","tip":"불꽃 → 풀·벌레 2배 / 물 ½배 · 노말 → 고스트 무효"},
 7:{"name":"꼬부기","family":[7,8,9],"names":["꼬부기","어니부기","거북왕"],"types":[["water"],["water"],["water"]],"moves":["watergun","tackle","bite","bubble"],"badge":"물","color":Color("93cce7"),"style":"물줄기와 퍼지는 거품","tip":"물 → 불꽃 2배 / 풀·물 ½배 · 물기 → 고스트 2배"},
 1:{"name":"이상해씨","family":[1,2,3],"names":["이상해씨","이상해풀","이상해꽃"],"types":[["grass","poison"],["grass","poison"],["grass","poison"]],"moves":["vine","tackle","razor","sludge"],"badge":"풀 · 독","color":Color("b8d98b"),"style":"덩굴과 관통하는 잎사귀","tip":"풀 → 물 2배 / 풀·독·비행·벌레 각각 ½배"}
}
const MOVES = {
 "ember": {"name":"불꽃세례", "type":"fire", "hint":"가까운 적에게 불씨 발사", "detail":"불씨 수와 위력이 늘어납니다.", "cooldown":0.72},
 "scratch": {"name":"할퀴기", "type":"normal", "hint":"주변의 적을 넓게 베기", "detail":"포위됐을 때 공간을 확보합니다.", "cooldown":1.7},
 "dragon": {"name":"용의분노", "type":"dragon", "hint":"고정 40 피해의 관통 탄환", "detail":"강화할수록 더 자주 발사합니다.", "cooldown":2.1},
 "flame": {"name":"화염방사", "type":"fire", "hint":"가까운 적 방향으로 불꽃 부채꼴", "detail":"사거리와 위력이 늘어납니다.", "cooldown":1.4},
 "watergun": {"name":"물대포","type":"water","hint":"가까운 적에게 물줄기 발사","detail":"강화하면 위력과 발사 수가 늘어납니다.","cooldown":0.68},
 "tackle": {"name":"몸통박치기","type":"normal","hint":"주변의 적을 밀쳐내기","detail":"가까이 붙은 적에게 공간을 만듭니다.","cooldown":1.7},
 "bite": {"name":"물기","type":"dark","hint":"주변의 적을 강하게 물기","detail":"고스트 타입에게도 효과적입니다.","cooldown":1.5},
 "bubble": {"name":"거품","type":"water","hint":"세 갈래로 퍼지는 거품","detail":"강화하면 더 넓게 퍼집니다.","cooldown":1.25},
 "vine": {"name":"덩굴채찍","type":"grass","hint":"주변을 덩굴로 휘감아 공격","detail":"강화하면 범위와 위력이 늘어납니다.","cooldown":0.85},
 "razor": {"name":"잎날가르기","type":"grass","hint":"적을 관통하는 잎사귀","detail":"멀리 있는 적까지 꿰뚫습니다.","cooldown":0.9},
 "sludge": {"name":"오물폭탄","type":"poison","hint":"전방에 독 공격을 펼치기","detail":"풀 공격과 다른 상성을 활용하세요.","cooldown":1.4},
 "heal": {"name":"나무열매", "type":"heal", "hint":"체력 35 회복", "detail":"기술이 모두 완성되면 회복합니다.", "cooldown":0.0}
}
# Only attacking types used in this prototype; dual defender types multiply.
const CHART = {
 "dark":{"psychic":2.0,"ghost":2.0,"fighting":0.5,"dark":0.5,"fairy":0.5},
 "poison":{"grass":2.0,"fairy":2.0,"poison":0.5,"ground":0.5,"rock":0.5,"ghost":0.5,"steel":0.0},
 "fire":{"fire":0.5,"water":0.5,"rock":0.5,"dragon":0.5,"grass":2.0,"ice":2.0,"bug":2.0,"steel":2.0},
 "normal":{"rock":0.5,"steel":0.5,"ghost":0.0},
 "dragon":{"dragon":2.0,"steel":0.5,"fairy":0.0},
 "electric":{"water":2.0,"flying":2.0,"electric":0.5,"grass":0.5,"dragon":0.5,"ground":0.0},
 "water":{"fire":2.0,"ground":2.0,"rock":2.0,"water":0.5,"grass":0.5,"dragon":0.5},
 "grass":{"water":2.0,"ground":2.0,"rock":2.0,"fire":0.5,"grass":0.5,"poison":0.5,"flying":0.5,"bug":0.5,"dragon":0.5,"steel":0.5}
}
func multiplier(attack: String, defenders: Array) -> float:
 var factor: float = 1.0
 for kind in defenders:
  factor *= float(CHART.get(attack, {}).get(kind, 1.0))
 return factor
func evolution(level: int) -> int:
 return 2 if level >= 9 else (1 if level >= 5 else 0)
func xp_needed(level: int) -> int:
 return 7 + level * 3
func add_xp(level: int, xp: int, amount: int) -> Dictionary:
 xp += amount
 var gained: int = 0
 while xp >= xp_needed(level):
  xp -= xp_needed(level)
  level += 1
  gained += 1
 return {"level":level,"xp":xp,"gained":gained}
func move_damage(move: String, rank: int, defenders: Array) -> float:
 var kind: String = MOVES[move].type
 var factor: float = multiplier(kind, defenders)
 if move == "dragon":
  return 0.0 if factor == 0.0 else 40.0
 var base: float = {"ember":15.0,"scratch":22.0,"flame":19.0,"watergun":17.0,"tackle":22.0,"bite":23.0,"bubble":17.0,"vine":25.0,"razor":24.0,"sludge":28.0}.get(move, 0.0)
 return (base + (rank - 1) * 7.0) * factor
func choices(ranks: Dictionary, starter: int = 4) -> Array:
 var available: Array = []
 for move in STARTERS[starter].moves:
  if int(ranks.get(move, 0)) < 5:
   available.append(move)
 available.shuffle()
 return available.slice(0,3) if not available.is_empty() else ["heal"]
