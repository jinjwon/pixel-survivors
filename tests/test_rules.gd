extends SceneTree
var failures: int = 0
func check(ok: bool, message: String) -> void:
 if not ok:
  failures += 1
  printerr("FAIL: " + message)
func _init() -> void:
 var source = load("res://scripts/rules.gd")
 if source == null:
  printerr("FAIL: combat rules resource is not implemented")
  quit(1)
  return
 var rules = source.new()
 check(rules.multiplier("fire", ["grass", "poison"]) == 2.0, "Fire must exploit Oddish grass typing")
 check(rules.multiplier("fire", ["water"]) == 0.5, "Water resists Fire")
 check(rules.multiplier("normal", ["ghost", "poison"]) == 0.0, "Ghost immunity must survive dual typing")
 check(rules.multiplier("electric", ["fire", "flying"]) == 2.0, "Charizard gains an Electric weakness")
 check(rules.multiplier("fire", ["grass", "bug"]) == 4.0, "Dual weaknesses multiply")
 check(rules.evolution(4) == 0 and rules.evolution(5) == 1 and rules.evolution(9) == 2, "Both evolution boundaries")
 check(rules.move_damage("dragon", 5, ["fairy"]) == 0, "Dragon Rage respects Fairy immunity")
 check(rules.move_damage("dragon", 5, ["dragon"]) == 40, "Dragon Rage is fixed damage, not scaled by effectiveness")
 var ranks = {"ember":5,"scratch":5,"dragon":5,"flame":5}
 var choices = rules.choices(ranks)
 check(choices == ["heal"], "Capped moves must not reappear")
 var xp = rules.add_xp(1, 0, 100)
 check(xp.level > 2 and xp.xp < rules.xp_needed(xp.level), "XP overflow supports several level-ups")
 print("RULES: " + str(failures) + " failures")
 quit(1 if failures else 0)
