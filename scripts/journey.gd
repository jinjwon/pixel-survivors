extends RefCounted
const STAGES = [
 {"name":"관동", "place":"상록의 숲", "tag":"KANTO / VIRIDIAN TRAIL", "boss":94,"pool":[10,13,16,19,25,43],"color":Color("559a69")},
 {"name":"성도", "place":"단풍의 산책로", "tag":"JOHTO / AMBER GROVE", "boss":248,"pool":[161,163,165,167,177,179],"color":Color("d69b53")},
 {"name":"호연", "place":"에메랄드 해안", "tag":"HOENN / EMERALD COAST", "boss":376,"pool":[261,263,270,273,278,285],"color":Color("4baeb0")}
]
const WAVE_TIME = 90.0
const DEADLINE = 150.0
const RELICS = {
 "charcoal":{"name":"목탄","hint":"모든 기술 피해 +18%","stat":"damage","value":0.18,"color":Color("e67751")},
 "quick":{"name":"선제공격손톱","hint":"기술 재사용 시간 −12%","stat":"haste","value":0.12,"color":Color("d6ad45")},
 "boots":{"name":"가벼운 신발","hint":"이동 속도 +12%","stat":"speed","value":0.12,"color":Color("5ba59b")},
 "shell":{"name":"조개껍질 부적","hint":"받는 피해 −18%","stat":"guard","value":0.18,"color":Color("7b9ed0")},
 "magnet":{"name":"경험치 자석","hint":"경험치 획득 범위 +45","stat":"magnet","value":45.0,"color":Color("bb7fba")},
 "heart":{"name":"생명의 씨앗","hint":"최대 체력 +25","stat":"health","value":25.0,"color":Color("7cac64")}
}
const CONDITIONS = [
 {"name":"산들바람","hint":"적 이동 속도 +12% · 경험치 +1","speed":1.12,"spawn":1.0,"xp":1},
 {"name":"풍성한 풀숲","hint":"적 등장 +18% · 경험치 +1","speed":1.0,"spawn":0.82,"xp":1},
 {"name":"평온한 날","hint":"기본 웨이브 · 천천히 준비하세요","speed":1.0,"spawn":1.0,"xp":0}
]
