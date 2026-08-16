class_name TCTilesetParent

extends Node

@export_category("Tileset Settings")
## Width and height of a tile in pixels, will be used by Composition Elements for seamlessness tools.
@export var tileset_cell_size:int = 128
## Change if the global position of the top-left corner of tileset is not at 0,0. This is used for seamlessness features.
@export var top_left_corner:Vector2 = Vector2.ZERO
