extends Object

var texture
var primary = {}
var secondary = {}
var ability = {}

func _init(new_prim=null, new_sec=null, new_abil=null, new_texture=null):
	if (
		typeof(new_prim) == TYPE_DICTIONARY and
		typeof(new_sec) == TYPE_DICTIONARY and
		typeof(new_abil) == TYPE_DICTIONARY
	):
		primary = new_prim
		secondary = new_sec
		ability = new_abil
	if typeof(new_texture) != TYPE_NIL and new_texture is Texture:
		texture = new_texture

func compare(object):
	return (
		texture == object.texture and
		primary == object.primary and
		secondary == object.secondary and
		ability == object.ability
	)

func copy(object):
	texture = object.texture
	primary = object.primary
	secondary = object.secondary
	ability = object.ability