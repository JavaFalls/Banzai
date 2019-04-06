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
export(bool) var as_percentage = false

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
	if as_percentage:
		$value.text = "%" + str(int(value/(max_value-min_value)*100))
	else:
		$value.text = str(value)

# Get the value as a string
func get_value():
	return $slider.value

func set_value(number):
	$slider.value = number
	
