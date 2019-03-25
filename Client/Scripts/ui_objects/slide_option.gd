extends HBoxContainer

"""
If the values are strings, make sure that there are exactly as many slider values
as there are strings, starting at zero. String values are retrieved by index.
"""

export(String) var option_name = ""
export(int) var min_value = 0
export(int) var max_value = 10
export(int, 0, 100) var step = 1
export(int) var inital_value = 0
export(PoolStringArray) var values

func _ready():
	$slider.connect("value_changed", self, "display_value")
	
	if min_value > max_value:
		var temp = min_value
		min_value = max_value
		max_value = temp
	$option_name.text = option_name
	$slider.min_value = min_value
	$slider.max_value = max_value
	$slider.step = step
	$slider.value = inital_value
	display_value($slider.value)

func display_value(value):
	$value.text = str(value)

# Get the value as a string
func get_value():
	return $slider.value
