extends Control

onready var head = get_tree().get_root().get_node("/root/head")

var model_ID = 0# The ID of the model these options belong to

func _ready():
	$back_button.connect("pressed", self, "exit")

func exit():
	store_options_in_DB()
	self.visible = false


func load_options_from_DB():
	var rewards = JSON.parse(head.DB.get_model_rewards(model_ID)).result["data"][0]
	for option in $VBoxContainer.get_children():
		option.set_value(rewards[convert_name_to_column(option.option_name)])
func store_options_in_DB():
	var rewards = []
	rewards.resize(DBConnector.UPDATE_MODEL_REWARDS_ARGS_SIZE)
	for option in $VBoxContainer.get_children():
		rewards[convert_name_to_index(option.option_name)] = option.get_value()
	head.DB.update_model_rewards(model_ID, rewards)

# Converts option names (that are displayed to the user) to the corresponding column name in the DB
func convert_name_to_column(title):
	match title.to_lower():
		"accuracy":
			return "reward_accuracy"
		"avoidance":
			return "reward_avoidence"
		"approach":
			return "reward_approach"
		"flee":
			return "reward_flee"
		"deal damage":
			return "reward_damage_dealt"
		"receive damage":
			return "reward_damage_received"
		"receive health":
			return "reward_health_received"
		"melee damage":
			return "reward_melee_damage"
# Converts option names (that are displayed to the user) to the corresponding index used when calling DB.update_model_rewards()
func convert_name_to_index(title):
	match title.to_lower():
		"accuracy":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_ACCURACY
		"avoidance":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_AVOIDENCE
		"approach":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_APPROACH
		"flee":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_FLEE
		"deal damage":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_DAMAGE_DEALT
		"receive damage":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_DAMAGE_RECEIVED
		"receive health":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_HEALTH_RECEIVED
		"melee damage":
			return DBConnector.UPDATE_MODEL_REWARDS_ARGS_MELEE_DAMAGE