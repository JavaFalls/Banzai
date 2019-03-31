# weapon_creator.gd
# This script is intended to be used to create and initalize all basic weapon types.
# You should use this script when you need to create a new weapon and attach it to a robot.
# This script is also intended for use by the bot customization scene, to be able to get basic information about all weapons.
extends Node

# Constants:
#-----------------------------------------------------------------------
enum weapon_types {
	# W stands for WEAPON
	# PRI stands for primary
	# SEC stands for secondary
	# ABI stands for ability
	W_PRI_ACID_BOW,
	W_PRI_EXPLODING_SHURIKEN,
	W_PRI_PRECISION_BOW,
	W_PRI_SWORD,
	W_PRI_SCATTER_BOW,
	W_PRI_RUBBER_BOW,
	W_PRI_ZORROS_GLARE,
	W_SEC_MINE,
	W_SEC_NUKE,
	W_SEC_SCYTHE,
	W_SEC_SNARE,
	W_SEC_ZORROS_WIT,
	W_ABI_CHARGE,
	W_ABI_CLONE,
	W_ABI_EVADE,
	W_ABI_FREEZE,
	W_ABI_REGENERATION,
	W_ABI_SHIELD,
	W_ABI_SUBSTITUTION,
	W_ABI_TELEPORT,
	W_ABI_ZORROS_HONOR,
	W_ABI_DEFLECTOR
}

# This is an dictionary array of all weapon stats.
# The structure of the dictionaries in the below 3 arrays must follow the same basic structure, however some weapon types have extra fields.
# All weapons have:
#  id           - Weapon ID, see W_ constants
#  implemented  - Used to determine whether or not a player has access to the weapon. Also used to determine whether or not the weapon has been coded yet.
#  name         - Name of weapon
#  description  - Detailed description of the weapon, as seen in the detail panel on the customization screen
#  info         - Brief information about the weapon, as seen in the stats panel on the customization screen
#  attack       - How much damage this weapon does
#  speed        - As referred to as "cooldown" in some spots, this is how often the weapon can be used, in seconds
#  type         - What kind of weapon this is, displayed on the customization screen and used by this script to determine how to spawn the weapon
#  icon         - The graphic that represents this weapon, as seen on the customization screen
#  sprite       - The graphic used by any effects created by the weapon, such as projectile or shield animations
#  scene        - The scene that controls how this weapon behaves, note that some weapons share the same scene
# Type "ranged" weapons also have:
#  projectile_speed - given in pixels per second
#  projectile_scene - The preloaded scene that controls how a projectile behaves, this is the scene that is the projectile
# Type "melee" weapons also have:
#  swing_scene - The scene to instance that represents the sword swing
# Type "trap" weapons also have:
#  lifetime   - How long a trap will remain on the screen before self destructing
#  trap_scene - A scene that controls how an individual trap behaves once planted.
const W_PRI_STATS = [
	{"id": W_PRI_ACID_BOW          , "implemented": true , "name": "Acid Bow"          , "description": "Leaves a residue on contact, which causes latent damage for 2.5 seconds."                               , "info": "Deals an extra 5 damage over 2.5 seconds."                      , "attack":     2, "speed":  0.25, "type": "Ranged", "icon": preload("res://assets/weapons/acid_bow.png")          , "sprite": preload("res://assets/weapons/acid_arrow.png")         , "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 400, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_EXPLODING_SHURIKEN, "implemented": true , "name": "Exploding Shuriken", "description": "Thrown projectile which detonates on contact with opponent or barrier."                                 , "info": "Explosion radius is roughly 1 times bot size."                  , "attack":     8, "speed":  0.3 , "type": "Ranged", "icon": preload("res://assets/weapons/exploding_shuriken.png"), "sprite": preload("res://assets/weapons/exploding_shuriken.png") , "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 325, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_PRECISION_BOW     , "implemented": true , "name": "Precision Bow"     , "description": "Launches a single projectile which causes severe damage on contact."                                    , "info": "Very accurate."                                                 , "attack":    15, "speed":  0.5 , "type": "Ranged", "icon": preload("res://assets/weapons/precision_bow.png")     , "sprite": preload("res://assets/weapons/precision_arrow.png")    , "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 700, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_SCATTER_BOW       , "implemented": true , "name": "Scatter Bow"       , "description": "Launches 3 projectiles which cause damage if contact is made with an opponent."                         , "info": "Projectiles fired in a 90 degree cone randomly."                , "attack":     3, "speed":  0.2 , "type": "Ranged", "icon": preload("res://assets/weapons/scatter_bow.png")       , "sprite": preload("res://assets/weapons/scatter_arrow.png")      , "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_SWORD             , "implemented": true , "name": "Sword"             , "description": "The hack-n-slash of the ages. Get personal with this blade."                                            , "info": "Stab, stab, stab."                                              , "attack":     7, "speed":  0.2 , "type": "Melee" , "icon": preload("res://assets/weapons/sword.png")             , "sprite": preload("res://assets/weapons/sword.png")              , "scene": preload("res://scenes/weapons/melee.tscn")              , "swing_scene": preload("res://scenes/weapons/melee_animations/sword.tscn"), "scale" : 1.5},
	{"id": W_PRI_RUBBER_BOW        , "implemented": true , "name": "Rubber Bow"        , "description": "Launches projectiles which bounce off walls for 5 seconds, or until contact is made with a bot."        , "info": "Projectiles bounce off walls for 5 seconds."                    , "attack":     4, "speed":  0.15, "type": "Ranged", "icon": preload("res://assets/weapons/bow_regular.png")       , "sprite": preload("res://assets/weapons/rubber_arrow.png")       , "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_ZORROS_GLARE      , "implemented": false, "name": "Zorro's Glare"     , "description": "If looks could kill, this would kill you. Oh wait, it can kill you."                                    , "info": "Death Laser."                                                   , "attack":    10, "speed":  2.0 , "type": "Ranged", "icon": preload("res://assets/weapons/icon_zorros_glare.png") , "sprite": preload("res://assets/weapons/laser_beam_of_death.png"), "scene": preload("res://scenes/weapons/zorros_glare.tscn")       , "projectile_speed": 500, "projectile_scene": preload("res://Scenes/weapons/zorros_glare_projectile.tscn")}
]
const W_SEC_STATS = [
	{"id": W_SEC_MINE              , "implemented": true , "name": "Mine"              , "description": "A trap set on the ground, explodes when triggered."                                                     , "info": "Explosion radius is roughly 2 times bot size."                  , "attack":    20, "speed":  1.0 , "type": "Trap"  , "icon": preload("res://assets/weapons/mine.png")           , "sprite": preload("res://assets/weapons/mine.png")           , "scene": preload("res://scenes/weapons/trap.tscn"), "lifetime": 5.0, "trap_scene": preload("res://scenes/weapons/traps/mine.tscn")},
	{"id": W_SEC_NUKE              , "implemented": true , "name": "Nuke"              , "description": "Really big boom."                                                                                       , "info": "Explosion radius is roughly 1/4th of the arena."                , "attack":   250, "speed": 10.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_nuke.png")      , "sprite": preload("res://assets/weapons/nuke.png")           , "scene": preload("res://scenes/weapons/tech/nuke.tscn")},
	{"id": W_SEC_SCYTHE            , "implemented": true , "name": "Scythe"            , "description": "Ever wanted to be the grim reaper? Then use this."                                                      , "info": "Hebrews 9:27"                                                   , "attack":    50, "speed":  1.5 , "type": "Melee" , "icon": preload("res://assets/weapons/scythe.png")         , "sprite": preload("res://assets/weapons/scythe.png")         , "scene": preload("res://scenes/weapons/melee.tscn"), "swing_scene": preload("res://scenes/weapons/melee_animations/scythe.tscn"), "scale" : 3.0},
	{"id": W_SEC_SNARE             , "implemented": true , "name": "Snare"             , "description": "A trap set on the ground, disables motion of target for 1.0 second when triggered."                     , "info": "Disables movement."                                             , "attack":     0, "speed":  1.0 , "type": "Trap"  , "icon": preload("res://assets/weapons/snare.png")          , "sprite": preload("res://assets/weapons/snare.png")          , "scene": preload("res://scenes/weapons/trap.tscn"), "lifetime": 5.0, "trap_scene": preload("res://scenes/weapons/traps/snare.tscn")},
	{"id": W_SEC_ZORROS_WIT        , "implemented": false, "name": "Zorro's Wit"       , "description": "The bot becomes invisible for 3 seconds."                                                               , "info": "Can't outsmart this, can you?"                                  , "attack":     0, "speed":  5.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_zorros_wit.png"), "sprite": preload("res://assets/weapons/icon_zorros_wit.png"), "scene": preload("res://scenes/weapons/tech/zorros_wit.tscn")}
]
const W_ABI_STATS = [
	{"id": W_ABI_CHARGE            , "implemented": true , "name": "Charge"            , "description": "Charge towards the opponent in a straight line dealing damage on contact."                              , "info": "Charge speed is 3 times normal movement."                       , "attack":    25, "speed":  1.5 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_charge.png")      , "sprite": preload("res://assets/weapons/icon_charge.png")      , "scene": preload("res://scenes/weapons/tech/charge.tscn")},
	{"id": W_ABI_CLONE             , "implemented": true , "name": "Clone"             , "description": "Creates a dummy model alongside the bot that cannot do damage but reacts with a simple AI."             , "info": "Disrupt, Detect, Delay, Defeat."                                , "attack":     0, "speed":  5.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_clone.png")       , "sprite": preload("res://assets/weapons/icon_clone.png")       , "scene": preload("res://scenes/weapons/tech/clone.tscn")},
	{"id": W_ABI_DEFLECTOR         , "implemented": true , "name": "Deflector"         , "description": "Reduces damage from projectiles in half and reflects the projectile. Lasts for 4 seconds."              , "info": "Reduces damage by half. Reflected projectiles deal half damage.", "attack": 0, "speed": 6.5, "type": "Tech", "icon": preload("res://assets/weapons/icon_deflector.png"), "sprite": preload("res://assets/weapons/icon_deflector.png") , "scene": preload("res://scenes/weapons/tech/deflector.tscn")},
	{"id": W_ABI_EVADE             , "implemented": true , "name": "Evade"             , "description": "Gain a brief (0.1 seconds) boost of speed to sprint out of the way of an incoming projectile."          , "info": "Move 5 times faster for 0.1 seconds."                           , "attack":     0, "speed":  0.3 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_evade.png")       , "sprite": preload("res://assets/weapons/arrow_regular.png")    , "scene": preload("res://scenes/weapons/tech/evade.tscn")},
	{"id": W_ABI_FREEZE            , "implemented": true , "name": "Freeze"            , "description": "Freeze the opponent for 0.5 seconds, completely immobilizing them (target cannot attack or move)."      , "info": "Freezes target for 0.5 seconds."                                , "attack":     0, "speed":  1.0 , "type": "Ranged", "icon": preload("res://assets/weapons/icon_freeze.png")      , "sprite": preload("res://assets/weapons/freeze_projectile.png"), "scene": preload("res://scenes/weapons/projectile_launcher.tscn"), "projectile_speed": 325, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_ABI_REGENERATION      , "implemented": true , "name": "Regeneration"      , "description": "Heals the bot 10 points over a period of 2 seconds."                                                    , "info": "Heal 10 damage over 2 seconds."                                 , "attack":     0, "speed":  4.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_heal.png")        , "sprite": preload("res://assets/weapons/icon_heal.png")        , "scene": preload("res://scenes/weapons/tech/regeneration.tscn")},
	{"id": W_ABI_SHIELD            , "implemented": true , "name": "Shield"            , "description": "Creates a protective shield capable of absorbing any damage for 2 seconds."                             , "info": "Shield lasts for 2 seconds."                                    , "attack":     0, "speed":  5.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_shield.png")      , "sprite": preload("res://assets/weapons/arrow_regular.png")    , "scene": preload("res://scenes/weapons/tech/shield.tscn")},
	{"id": W_ABI_SUBSTITUTION      , "implemented": true , "name": "Substitution"      , "description": "Switches the bots locations with its opponents location."                                               , "info": "Switch locations with opponent."                                , "attack":     0, "speed":  0.5 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_substitution.png"), "sprite": preload("res://assets/weapons/substitute.png")       , "scene": preload("res://scenes/weapons/tech/substitution.tscn")},
	{"id": W_ABI_TELEPORT          , "implemented": true , "name": "Teleport"          , "description": "Teleports the bot to a random place in the arena."                                                      , "info": "Warning: May teleport into or out of harm's way."               , "attack":     0, "speed":  1.0 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_teleport.png")    , "sprite": preload("res://assets/weapons/icon_teleport.png")    , "scene": preload("res://scenes/weapons/tech/teleport.tscn")},
	{"id": W_ABI_ZORROS_HONOR      , "implemented": false, "name": "Zorro's Honor"     , "description": "Temporarily increase all bot and weapon stats by 2 times for 10 seconds."                               , "info": "Get good."                                                      , "attack":     0, "speed":  7.5 , "type": "Tech"  , "icon": preload("res://assets/weapons/icon_zorros_honor.png"), "sprite": preload("res://assets/weapons/icon_zorros_honor.png"), "scene": preload("res://scenes/weapons/tech/zorros_honor.tscn")}
]

# Functions to get weapon stats:
#-----------------------------------------------------------------------
func get_weapon_stats(w_ID):
	for w_stats in W_PRI_STATS:
		if w_stats["id"] == w_ID:
			return w_stats
	for w_stats in W_SEC_STATS:
		if w_stats["id"] == w_ID:
			return w_stats
	for w_stats in W_ABI_STATS:
		if w_stats["id"] == w_ID:
			return w_stats

# The following 3 functions return dictionary arrays containing only the weapons that have been implemented in game
func get_w_pri_stats():
	return get_w_stats_implemented_only(W_PRI_STATS)
func get_w_sec_stats():
	return get_w_stats_implemented_only(W_SEC_STATS)
func get_w_abi_stats():
	return get_w_stats_implemented_only(W_ABI_STATS)

func get_w_stats_implemented_only(weapon_array):
	var w_stats_array = Array()
	for w_stats in weapon_array:
		if w_stats["implemented"]:
			w_stats_array.append(w_stats)
	return w_stats_array

# Functions to create weapon objects for use by bots:
#-----------------------------------------------------------------------
func create_weapon(w_ID):
	var w_stats = get_weapon_stats(w_ID)
	var weapon = w_stats["scene"].instance()
	weapon.id = w_stats["id"]
	weapon.damage = w_stats["attack"]
	weapon.cooldown = w_stats["speed"]
	match(w_stats["type"]):
		"Ranged":
			if w_stats["id"] == W_ABI_FREEZE:# or w_stats["id"] == W_PRI_ZORROS_GLARE:
				# Freeze and Zorro's Glare do not get a visible graphic
				weapon.set_sprite(null)
			else:
				weapon.set_sprite(w_stats["icon"])
			weapon.projectile_sprite = w_stats["sprite"]
			weapon.projectile_speed = w_stats["projectile_speed"]
			weapon.projectile_scene = w_stats["projectile_scene"]
		"Melee":
			weapon.swing_scene = w_stats["swing_scene"]
			weapon.set_sheathed_sprite(w_stats["icon"])
			weapon.scale = Vector2(w_stats["scale"], w_stats["scale"])
		"Trap":
			weapon.lifetime = w_stats["lifetime"]
			weapon.trap_scene = w_stats["trap_scene"]
			weapon.trap_sprite = w_stats["icon"]
		#"Tech": Currently tech doesn't have any special attributes that we have to set (other then id, damage, and cooldown which all weapons have)
	return weapon
