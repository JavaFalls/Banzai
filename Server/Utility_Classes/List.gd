# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const ITEM = preload("res://Utility_Classes/List_Item.gd")

# Variables:
#-------------------------------------------------------------------------------
var first_item = null
var last_item = null

# Functions:
#-------------------------------------------------------------------------------
func append_front(value):
   var new_item = ITEM.new()
   new_item.list_item_init(value)
   if first_item != null:
      first_item.prev_item = new_item
      new_item.next_item = first_item
   else:
      last_item = new_item
   first_item = new_item

func append_back(value):
   var new_item = ITEM.new()
   new_item.list_item_init(value)
   if last_item != null:
      last_item.next_item = new_item
      new_item.prev_item = last_item
   else:
      first_item = new_item
   last_item = new_item

func remove_front():
   var item_to_remove = first_item
   if item_to_remove.next_item != null:
      item_to_remove.next_item.prev_item = null
      first_item = item_to_remove.next_item
   else:
      first_item = null
      last_item = null
   item_to_remove.destroy()

func remove_back():
   var item_to_remove = last_item
   if item_to_remove.prev_item != null:
      item_to_remove.prev_item.next_item = null
      last_item = item_to_remove.prev_item
   else:
      first_item = null
      last_item = null
   item_to_remove.destory()
