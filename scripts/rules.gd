extends RefCounted

const STARTER_ORDER = [4,7,1]
const Catalog = preload("res://scripts/catalog.gd")
var catalog = Catalog.new()
var STARTERS: Dictionary = {}
func _init() -> void:
 for id in catalog.entries: STARTERS[id]=catalog.profile(id)

const MOVES = {
 "ember": {"name":"불꽃세례", "type":"fire", "hint":"가까운 적에게 불씨 발사", "detail":"불씨 수와 위력이 늘어납니다.", "cooldown":0.72},
 "scratch": {"name":"할퀴기", "type":"normal", "hint":"주변의 적을 넓게 베기", "detail":"포위됐을 때 공간을 확보합니다.", "cooldown":1.7},
 "dragon": {"name":"용의분노", "type":"dragon", "hint":"기본 40 피해의 관통 탄환", "detail":"강화할수록 더 자주 발사합니다.", "cooldown":2.1},
 "flame": {"name":"화염방사", "type":"fire", "hint":"가까운 적 방향으로 불꽃 부채꼴", "detail":"사거리와 위력이 늘어납니다.", "cooldown":1.4},
 "watergun": {"name":"물대포","type":"water","hint":"가까운 적에게 물줄기 발사","detail":"강화하면 위력과 발사 수가 늘어납니다.","cooldown":0.68},
 "tackle": {"name":"몸통박치기","type":"normal","hint":"주변의 적을 밀쳐내기","detail":"가까이 붙은 적에게 공간을 만듭니다.","cooldown":1.7},
 "bite": {"name":"물기","type":"dark","hint":"주변의 적을 강하게 물기","detail":"고스트 타입에게도 효과적입니다.","cooldown":1.5},
 "bubble": {"name":"거품","type":"water","hint":"세 갈래로 퍼지는 거품","detail":"강화하면 더 넓게 퍼집니다.","cooldown":1.25},
 "vine": {"name":"덩굴채찍","type":"grass","hint":"주변을 덩굴로 휘감아 공격","detail":"강화하면 범위와 위력이 늘어납니다.","cooldown":0.85},
 "razor": {"name":"잎날가르기","type":"grass","hint":"적을 관통하는 잎사귀","detail":"멀리 있는 적까지 꿰뚫습니다.","cooldown":0.9},
 "sludge": {"name":"오물폭탄","type":"poison","hint":"전방에 독 공격을 펼치기","detail":"풀 공격과 다른 상성을 활용하세요.","cooldown":1.4},
 "swift":{"name":"스피드스타","type":"normal","hint":"별 모양의 관통 탄환","detail":"강화하면 별빛의 피해가 증가합니다.","cooldown":0.8},
 "spark":{"name":"전기쇼크","type":"electric","hint":"지그재그 전기 탄환","detail":"물·비행 타입에게 강합니다.","cooldown":0.7},
 "ice":{"name":"냉동빔","type":"ice","hint":"얼음 결정의 관통 사격","detail":"풀·비행·드래곤에게 강합니다.","cooldown":1.0},
 "punch":{"name":"마하펀치","type":"fighting","hint":"가까운 적을 빠르게 타격","detail":"바위·강철·악 타입에게 강합니다.","cooldown":0.85},
 "quake":{"name":"지진","type":"ground","hint":"주변에 퍼지는 지면 충격파","detail":"비행 타입에게는 통하지 않습니다.","cooldown":1.8},
 "gust":{"name":"바람일으키기","type":"flying","hint":"회전하며 날아가는 바람","detail":"풀·벌레·격투에게 강합니다.","cooldown":0.85},
 "psychic":{"name":"염동력","type":"psychic","hint":"전방에 에스퍼 파동","detail":"격투·독에게 강하고 악에게 무효입니다.","cooldown":1.3},
 "sting":{"name":"바늘미사일","type":"bug","hint":"날카로운 바늘 사격","detail":"풀·에스퍼·악에게 강합니다.","cooldown":0.6},
 "rock":{"name":"돌떨구기","type":"rock","hint":"각진 돌 조각을 발사","detail":"불꽃·비행·벌레에게 강합니다.","cooldown":1.0},
 "shadow":{"name":"섀도볼","type":"ghost","hint":"고스트 에너지 탄환","detail":"노말 타입에게는 통하지 않습니다.","cooldown":0.95},
 "metal":{"name":"메탈클로","type":"steel","hint":"짧고 날카로운 강철 베기","detail":"바위·얼음에게 강합니다.","cooldown":1.0},
 "heal": {"name":"나무열매", "type":"heal", "hint":"체력 35 회복", "detail":"기술이 모두 완성되면 회복합니다.", "cooldown":0.0}
}
# Only attacking types used in this prototype; dual defender types multiply.
const CHART = {
 "ice":{"grass":2.0,"ground":2.0,"flying":2.0,"dragon":2.0,"fire":0.5,"water":0.5,"ice":0.5,"steel":0.5},
 "fighting":{"normal":2.0,"ice":2.0,"rock":2.0,"dark":2.0,"steel":2.0,"poison":0.5,"flying":0.5,"psychic":0.5,"bug":0.5,"ghost":0.0},
 "ground":{"fire":2.0,"electric":2.0,"poison":2.0,"rock":2.0,"steel":2.0,"grass":0.5,"bug":0.5,"flying":0.0},
 "flying":{"grass":2.0,"fighting":2.0,"bug":2.0,"electric":0.5,"rock":0.5,"steel":0.5},
 "psychic":{"fighting":2.0,"poison":2.0,"psychic":0.5,"steel":0.5,"dark":0.0},
 "bug":{"grass":2.0,"psychic":2.0,"dark":2.0,"fire":0.5,"fighting":0.5,"poison":0.5,"flying":0.5,"ghost":0.5,"steel":0.5},
 "rock":{"fire":2.0,"ice":2.0,"flying":2.0,"bug":2.0,"fighting":0.5,"ground":0.5,"steel":0.5},
 "ghost":{"psychic":2.0,"ghost":2.0,"dark":0.5,"steel":0.5,"normal":0.0},
 "steel":{"ice":2.0,"rock":2.0,"fire":0.5,"water":0.5,"electric":0.5,"steel":0.5},
 "dark":{"psychic":2.0,"ghost":2.0,"fighting":0.5,"dark":0.5,"fairy":0.5,"steel":0.5},
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
 var base: float = {"ember":15.0,"scratch":22.0,"flame":19.0,"watergun":17.0,"tackle":22.0,"bite":23.0,"bubble":17.0,"vine":25.0,"razor":24.0,"sludge":28.0}.get(move, 23.0)
 return (base + (rank - 1) * 7.0) * factor
func choices(ranks: Dictionary, starter: int = 4) -> Array:
 var available: Array = []
 for move in STARTERS[starter].moves:
  if int(ranks.get(move, 0)) < 5:
   available.append(move)
 available.shuffle()
 return available.slice(0,3) if not available.is_empty() else ["heal"]
