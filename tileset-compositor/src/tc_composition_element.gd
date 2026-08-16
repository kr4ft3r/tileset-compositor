@tool
class_name TCCompositionElement

extends Node2D

@export_group("Tileset Seamlessness Options")
@export_multiline var seamlessness_info:String = "Use Duplicate Seamless helper operation to make the object seamless by adding duplicates where required, according to Tileset Parent cell size and object's position.\nIf for some reason you wish to remove seamlessness data from this object the non-destructive way is to use the Clear Seamlessness Data button.\nIf you are working on the original object that had Duplicate Seamless operation applied and you wish to remove duplicates from the scene use the Clear and Delete Duplicates button."
@export_tool_button("Select Duplicates", "ToolSelect")
var select_duplicates_button = _on_select_duplicates_button_pressed
@export_tool_button("Duplicate Seamless", "AspectRatioContainer")
var duplicate_seamless_button = _on_duplicate_seamless_button_pressed
@export var is_duplicated_from:TCCompositionElement = null
## Will be true if Duplicate Seamless button was used and duplicate was made on horizontal axis.
@export var was_x_duplicated:bool = false
## Will be true if Duplicate Seamless button was used and duplicate was made on vertical axis.
@export var was_y_duplicated:bool = false
@export var horizontal_duplicate:TCCompositionElement = null
@export var vertical_duplicate:TCCompositionElement = null
@export var horizontal_2_duplicate:TCCompositionElement = null
## Clear all duplication data, use if data is not valid for whatever reason
@export_tool_button("Clear Seamlessness Data", "Clear")
var clear_seamlessness_data_button = _clear_seamlessness_data
@export_tool_button("Clear and Delete Duplicates - NO UNDO", "Remove")
var clear_and_delete_linked_objects_button = _on_clear_and_delete_linked_objects_button_pressed
@export_group("", "")

func _get_tileset_parent() -> TCTilesetParent:
	var current = get_parent()
	while current != null:
		if current.get_script() == TCTilesetParent:
			return current
		current = current.get_parent()
		
	push_error("""Tileset parent cannot be found. 
	Make sure this composition element has parent with TCTilesetParent script attached.
	""".dedent()
	)
	return null
	
func remove_from_scene() -> void:
	if get_parent():
		get_parent().remove_child(self)
	queue_free()
	
func select_duplicates() -> void:
	var selection = EditorInterface.get_selection()
	selection.add_node(self)
	if horizontal_duplicate: 
		selection.add_node(horizontal_duplicate)
	if horizontal_2_duplicate: 
		selection.add_node(horizontal_2_duplicate)
	if vertical_duplicate: 
		selection.add_node(vertical_duplicate)
	
func _clear_seamlessness_data(delete_linked_objects:bool = false) -> void:
	var had_data = false
	var unlinked:Array = []
	if was_x_duplicated:
		was_x_duplicated = false
		print(name + " is no longer X duplicated")
		had_data = true
	if was_y_duplicated:
		was_y_duplicated = false
		print(name + " is no longer Y duplicated")
		had_data = true
	if horizontal_duplicate:
		unlinked.append(horizontal_duplicate)
		print("Unlinked from horizontal duplicate 1 " + horizontal_duplicate.name)
		horizontal_duplicate = null
		had_data = true
	if horizontal_2_duplicate:
		unlinked.append(horizontal_2_duplicate)
		print("Unlinked from horizontal duplicate 2 " + horizontal_2_duplicate.name)
		horizontal_2_duplicate = null
		had_data = true
	if vertical_duplicate:
		unlinked.append(vertical_duplicate)
		print("Unlinked from vertical duplicate 1 " + vertical_duplicate.name)
		vertical_duplicate = null
		had_data = true
	if !had_data:
		print("There was no duplicate data to clear")
	if delete_linked_objects and unlinked.size() > 0:
		for u:TCCompositionElement in unlinked:
			u.remove_from_scene()
		print("Removed "+str(unlinked.size())+" duplicates from the scene")
		
func _on_select_duplicates_button_pressed() -> void:
	if !is_duplicated_from:
		select_duplicates()
	else:
		is_duplicated_from.select_duplicates()

func _on_duplicate_seamless_button_pressed() -> void:
	if was_x_duplicated or was_y_duplicated:
		print("Aborted, this object was already duplicated. To use this button again you must use one of the Clear buttons first")
		return
	
	var tileset_parent = _get_tileset_parent()
	if !tileset_parent: return
	
	var tile_size:float = float(tileset_parent.tileset_cell_size)
	var element_pos = global_position.abs()
	var element_tilespace_pos = element_pos - tileset_parent.top_left_corner
	if !is_equal_approx(element_pos.x, roundf(element_pos.x)) or !is_equal_approx(element_pos.y, roundf(element_pos.y)):
		push_error("""Aborted. The position X and Y must be whole numbers.
		Turn on Pixel Snapping and reposition the object.
		""".dedent())
		return
		
	if !$Sprite2D:
		push_error("""Aborted. Can't calculate bounding box rectangle.
		The TC Composition Element object {{name}} must have a Sprite2D as a direct child.
		""".dedent().format({"name": name}))
		
	var local_rect: Rect2 = $Sprite2D.get_rect()
	var rect: Rect2 = Rect2($Sprite2D.global_position + local_rect.position * $Sprite2D.global_scale, local_rect.size * $Sprite2D.global_scale)
	var top_left:Vector2 = rect.position
	var top_right:Vector2 = Vector2(rect.end.x, rect.position.y)
	var bottom_left:Vector2 = Vector2(rect.position.x, rect.end.y)
	var bottom_right:Vector2 = rect.end
	
	# The Composition Element's global position is autorative in deciding the tile's coordinates, 
	# so sprite must not be off by too much, it should be near the Composition Element's center
	# and not spill over into squares more than 1 tiles away in order for seamlessness to work.
	
	# 1-based tile coords
	var owning_tile_x:int = ceili(element_tilespace_pos.x / tile_size)
	var owning_tile_y:int = ceili(element_tilespace_pos.y / tile_size)
	
	var tile_tilespace_rect: Rect2 = Rect2(Vector2((owning_tile_x-1.0)*tile_size, (owning_tile_y-1.0)*tile_size), Vector2.ONE * tile_size)
	var tile_global_rect: Rect2 = Rect2(tile_tilespace_rect.position + tileset_parent.top_left_corner, Vector2.ONE * tile_size)
	print("Tile rect global is "+str(tile_global_rect))
	print("Tile rect tileset space is "+str(tile_tilespace_rect))
	if (tile_global_rect.encloses(rect)):
		print("No duplication needed for "+name+" - sprite is enclosed within the tile")
		return
		
	print("-- Adding duplicates --")
	if top_left.x < tile_global_rect.position.x:
		horizontal_duplicate = _duplicate(global_position + Vector2.RIGHT * tile_size)
		was_x_duplicated = true
	elif top_right.x > tile_global_rect.end.x:
		horizontal_duplicate = _duplicate(global_position + Vector2.LEFT * tile_size)
		was_x_duplicated = true
	if rect.end.y > tile_global_rect.end.y:
		vertical_duplicate = _duplicate(global_position + Vector2.UP * tile_size)
		was_y_duplicated = true
	elif rect.position.y < tile_global_rect.position.y:
		vertical_duplicate = _duplicate(global_position + Vector2.DOWN * tile_size)
		was_y_duplicated = true
	if was_x_duplicated and was_y_duplicated:
		var dir_horizontal_2_duplicate = Vector2.RIGHT
		if top_right.x > tile_global_rect.end.x:
			dir_horizontal_2_duplicate = Vector2.LEFT
		horizontal_2_duplicate = _duplicate(vertical_duplicate.global_position + dir_horizontal_2_duplicate * tile_size)
		
func _duplicate(pos:Vector2) -> TCCompositionElement:
	var d:Node2D = duplicate(DUPLICATE_SCRIPTS)
	d.global_position = pos
	get_parent().add_child(d)
	d.owner = get_tree().edited_scene_root
	var elem = d as TCCompositionElement
	
	elem.was_x_duplicated = false
	elem.was_y_duplicated = false
	elem.is_duplicated_from = null
	elem.horizontal_duplicate = null
	elem.horizontal_2_duplicate = null
	elem.vertical_duplicate = null
	
	elem.is_duplicated_from = self

	return elem

func _on_clear_and_delete_linked_objects_button_pressed() -> void:
	print("Clearing seamlessness data with deletion of linked objects")
	_clear_seamlessness_data(true)

func _validate_property(property: Dictionary) -> void:
	var readonly_fields:Array = ["seamlessness_info", 
	"is_duplicated_from", "was_x_duplicated", "was_y_duplicated",
	"horizontal_duplicate", "horizontal_2_duplicate", "vertical_duplicate"]
	if readonly_fields.count(property.name) > 0:
		property.usage |= PROPERTY_USAGE_READ_ONLY
