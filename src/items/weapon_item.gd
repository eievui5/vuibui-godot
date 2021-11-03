class_name WeaponItem
extends InvItem

# Local load path; relative to the root of this module.
export(String, FILE, "*scn") var weapon_path: String

func instance_weapon() -> Weapon:
	var weapon: Weapon = load(weapon_path).instance()
	return weapon
