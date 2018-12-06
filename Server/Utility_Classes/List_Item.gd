extends Reference # Because it extends reference documentation says that the item will be removed from memory automatically once no references to the item exist

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------

# Variables:
#-------------------------------------------------------------------------------
var item
var next_item
var prev_item

# Constructor:
#-------------------------------------------------------------------------------
func list_item_init(value):
   item = value
   next_item = null
   prev_item = null

# Destructor:
#-------------------------------------------------------------------------------
func destroy():
   if item is Node:
      item.queue_free()
