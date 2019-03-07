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
	W_PRI_ACID_BOW, # not yet implemented
	W_PRI_EXPLODING_SHURIKEN, # not yet implemented
	W_PRI_PRECISION_BOW, # not yet implemented
	W_PRI_SWORD, # not yet implemented
	W_PRI_SCATTER_BOW, # not yet implemented
	W_PRI_RUBBER_BOW, # not yet implemented
	W_PRI_ZORROS_GLARE, # not yet implemented
	W_SEC_MINE, # not yet implemented
	W_SEC_NUKE, # not yet implemented
	W_SEC_SCYTHE, # not yet implemented
	W_SEC_SNARE, # not yet implemented
	W_SEC_ZORROS_WIT, # not yet implemented
	W_ABI_CHARGE, # not yet implemented
	W_ABI_CLONE, # not yet implemented
	W_ABI_EVADE, # not yet implemented
	W_ABI_FREEZE, # not yet implemented
	W_ABI_REGENERATION, # not yet implemented
	W_ABI_SHIELD, # not yet implemented
	W_ABI_SUBSTITUTION, # not yet implemented
	W_ABI_TELEPORT, # not yet implemented
	W_ABI_ZORROS_HONOR # not yet implemented
}

# This is an dictionary array of all weapon stats.
# The structure of the dictionaries in the below 3 arrays must follow the same basic structure, however some weapon types have extra fields.
# All weapons have:
#  id           - Weapon ID, see W_ constants
#  implemented  - Has the weapon been coded yet? If false, you should avoid spawning this weapon
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
const W_PRI_STATS = [
	{"id": W_PRI_ACID_BOW          , "implemented": true , "name": "Acid Bow"          , "description": "Leaves a residue on contact, which causes latent damage for 2.5 seconds"                                , "info": "Deals an extra 5 damage over 2.5 seconds"          , "attack":   1, "speed":  0.25, "type": "Ranged", "icon": preload("res://assets/weapons/acid_bow.png")          , "sprite": preload("res://assets/weapons/acid_arrow.png")        , "scene": preload("res://scenes/weapons/projectile_launcher.tscn") , "projectile_speed": 400, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_EXPLODING_SHURIKEN, "implemented": true , "name": "Exploding Shuriken", "description": "Thrown projectile which detonates on contact with opponent or barrier"                                  , "info": "Explosion radius is roughly 2 times bot size"      , "attack":   5, "speed":  0.2 , "type": "Ranged", "icon": preload("res://assets/weapons/exploding_shuriken.png"), "sprite": preload("res://assets/weapons/exploding_shuriken.png"), "scene": preload("res://scenes/weapons/projectile_launcher.tscn") , "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_PRECISION_BOW     , "implemented": true , "name": "Precision Bow"     , "description": "Launches a single projectile which causes severe damage on contact"                                     , "info": "Very accurate"                                     , "attack":  15, "speed":  0.5 , "type": "Ranged", "icon": preload("res://assets/weapons/precision_bow.png")     , "sprite": preload("res://assets/weapons/precision_arrow.png")   , "scene": preload("res://scenes/weapons/projectile_launcher.tscn") , "projectile_speed": 700, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_SCATTER_BOW       , "implemented": true , "name": "Scatter Bow"       , "description": "Launches 3 projectiles which cause damage if contact is made with an opponent"                          , "info": "Projectile direction is random in a 90 degree cone", "attack":   2, "speed":  0.2 , "type": "Ranged", "icon": preload("res://assets/weapons/scatter_bow.png")       , "sprite": preload("res://assets/weapons/scatter_arrow.png")     , "scene": preload("res://scenes/weapons/projectile_launcher.tscn") , "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_SWORD             , "implemented": false, "name": "Sword"             , "description": "The hack-n-slash of the ages. Get personal with this blade"                                             , "info": "Stab, stab, stab"                                  , "attack":  20, "speed":  0.1 , "type": "Melee" , "icon": preload("res://assets/weapons/sword.png")             , "sprite": preload("res://assets/weapons/sword.png")             , "scene": preload("res://scenes/weapons/primary/sword.tscn")},
	{"id": W_PRI_RUBBER_BOW        , "implemented": true , "name": "Rubber Bow"        , "description": "Launches projectiles which bounce off walls for a 2.5 seconds, or until contact is made with a bot"     , "info": "Projectiles bounce off walls for 2.5 seconds"      , "attack":   2, "speed":  0.15, "type": "Ranged", "icon": preload("res://assets/weapons/bow_regular.png")       , "sprite": preload("res://assets/weapons/rubber_arrow.png")      , "scene": preload("res://scenes/weapons/projectile_launcher.tscn") , "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")},
	{"id": W_PRI_ZORROS_GLARE      , "implemented": false, "name": "Zorro's Glare"     , "description": "If looks could kill, this would kill you. Oh wait, it can kill you."                                    , "info": "Death Laser"                                       , "attack":  50, "speed":  0.0 , "type": "Ranged", "icon": preload("res://assets/weapons/bow_regular.png")       , "sprite": preload("res://assets/weapons/arrow_regular.png")     , "scene": preload("res://scenes/weapons/primary/zorros_glare.tscn"), "projectile_speed": 250, "projectile_scene": preload("res://Scenes/weapons/projectile.tscn")}
]
const W_SEC_STATS = [
	{"id": W_SEC_MINE              , "implemented": false, "name": "Mine"              , "description": "A trap set on the ground, explodes when triggered"                                                      , "info": "Explosion radius is roughly 2 times bot size"      , "attack":  10, "speed":  1.0, "type": "Trap"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/secondary/mine.tscn")},
	{"id": W_SEC_NUKE              , "implemented": false, "name": "Nuke"              , "description": "Really big boom"                                                                                        , "info": "Explosion radius is roughly 1/4th of the arena"    , "attack": 200, "speed": 15.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/secondary/nuke.tscn")},
	{"id": W_SEC_SCYTHE            , "implemented": false, "name": "Scythe"            , "description": "Ever wanted to be the grim reaper? Then use this"                                                       , "info": "Hebrews 9:27"                                      , "attack": 100, "speed":  1.5, "type": "Melee" , "icon": preload("res://assets/weapons/sword.png")      , "sprite": preload("res://assets/weapons/sword.png")        , "scene": preload("res://scenes/weapons/secondary/scythe.tscn")},
	{"id": W_SEC_SNARE             , "implemented": false, "name": "Snare"             , "description": "A trap set on the ground, disables motion of target for 0.75 seconds when triggered"                    , "info": "Disables movement"                                 , "attack":   0, "speed":  1.0, "type": "Trap"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/secondary/snare.tscn")},
	{"id": W_SEC_ZORROS_WIT        , "implemented": false, "name": "Zorro's Wit"       , "description": "Become invisible for a 2 seconds"                                                                       , "info": "This provides concealment, not cover"              , "attack":   0, "speed":  5.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/secondary/zorros_wit.tscn")}
]
const W_ABI_STATS = [
	{"id": W_ABI_CHARGE            , "implemented": false, "name": "Charge"            , "description": "Rush towards the opponent in a straight line dealing damage on contact"                                 , "info": "Rush speed is 3 times normal movement"             , "attack":  50, "speed":  1.5, "type": "Melee" , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/charge.tscn")},
	{"id": W_ABI_CLONE             , "implemented": false, "name": "Clone"             , "description": "Creates a dummy model alongside the bot that cannot do damage but reacts with a simple AI"              , "info": "Disrupt, Detect, Delay, Defeat"                    , "attack":   0, "speed":  5.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/clone.tscn")},
	{"id": W_ABI_EVADE             , "implemented": false, "name": "Evade"             , "description": "Gain a brief (0.1 seconds) boost of speed to sprint out of the way of an incoming projectile"           , "info": "Speed boost is 10 times normal movement"           , "attack":   0, "speed":  0.3, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/evade.tscn")},
	{"id": W_ABI_FREEZE            , "implemented": false, "name": "Freeze"            , "description": "Freeze the opponent for 0.25 seconds, completely immobilizing them (target cannot attack or move)"      , "info": "Freeze affects target for 0.25 seconds"            , "attack":   0, "speed":  1.0, "type": "Ranged", "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/freeze.tscn")},
	{"id": W_ABI_REGENERATION      , "implemented": false, "name": "Regeneration"      , "description": "Heals the bot 10 points over a period of 2 seconds"                                                     , "info": "Heal 10 damage over 2 seconds"                     , "attack":   0, "speed":  4.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/regeneration.tscn")},
	{"id": W_ABI_SHIELD            , "implemented": false, "name": "Shield"            , "description": "Creates a protective shield capable of absorbing any damage for 1 second"                               , "info": "Shield lasts for 1 second"                         , "attack":   0, "speed":  5.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/shield.tscn")},
	{"id": W_ABI_SUBSTITUTION      , "implemented": false, "name": "Substitution"      , "description": "Creates a static obstacle in front of the bot? What is this? I have no idea"                            , "info": "not implemented"                                   , "attack":   0, "speed":  0.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/substitution.tscn")},
	{"id": W_ABI_TELEPORT          , "implemented": false, "name": "Teleport"          , "description": "Teleports the bot to a random place on the map"                                                         , "info": "Warning: May place in or out of harm's way"        , "attack":   0, "speed":  1.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/teleport.tscn")},
	{"id": W_ABI_ZORROS_HONOR      , "implemented": false, "name": "Zorro's Honor"     , "description": "Temporarily increase all bot and weapon stats by times 200... yeah good luck not hitting a wall"        , "info": "Get good"                                          , "attack":   0, "speed":  0.0, "type": "Tech"  , "icon": preload("res://assets/weapons/bow_regular.png"), "sprite": preload("res://assets/weapons/arrow_regular.png"), "scene": preload("res://scenes/weapons/ability/zorros_honor.tscn")}
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
	match(w_stats["type"]):
		"Ranged":
			weapon.id = w_stats["id"]
			weapon.damage = w_stats["attack"]
			weapon.cooldown = w_stats["speed"]
			weapon.set_sprite(w_stats["icon"])
			weapon.projectile_sprite = w_stats["sprite"]
			weapon.projectile_speed = w_stats["projectile_speed"]
			weapon.projectile_scene = w_stats["projectile_scene"]
		"Melee":
			weapon.damage = w_stats["attack"]
			weapon.cooldown = w_stats["speed"]
		"Trap":
			weapon.damage = w_stats["attack"]
			weapon.cooldown = w_stats["speed"]
		"Tech":
			weapon.cooldown = w_stats["speed"]
	return weapon