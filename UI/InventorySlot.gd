extends Control

#item currently held
@export var Item : InventoryItem
# Called when the node enters the scene tree for the first time.
func _ready():
	if Item != null:
		$Panel/TextureRect.texture = Item.ItemTexture
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# get the item we have
func GetItem():
	if Item != null:
		return Item
	else:
		return null
