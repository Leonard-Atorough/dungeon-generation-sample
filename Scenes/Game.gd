extends Node2D

var tilemap: TileMap
var root_node: Branch
var paths: Array = []


@export var max_w: int = 120
@export var max_h: int = 68
@export_range(1, 6) var splits: int = 4

func _ready():
	tilemap = get_node("TileMap")
	root_node = Branch.new(Vector2i(0,0), Vector2i(max_w, max_h))
	root_node.split(3, paths)
	queue_redraw()
	pass
	
func _draw():
	var rng = RandomNumberGenerator.new()
	for leaf in root_node.get_leaves():
		var padding = Vector4i(
			rng.randi_range(2,3),
			rng.randi_range(2,3),
			rng.randi_range(2,3),
			rng.randi_range(2,3)
		)

		for x in range(max_w):
			for y in range(max_h):
				tilemap.set_cell(0, Vector2i(x, y), 0, Vector2i(0,1))

		for x in range(leaf.size.x):
			for y in range(leaf.size.y):
				if not is_inside_padding(x, y, leaf, padding):
					tilemap.set_cell(1, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(2,1))
				if is_wall(x, y, leaf, padding):
					set_wall(x, y, leaf, padding)
			
	pass
	
	for leaf in root_node.get_leaves():
		for path in paths:
			if path['left'].y == path['right'].y:
				for i in range(path['right'].x - path['left'].x):
					tilemap.set_cell(3, Vector2i(path['left'].x+i, path['left'].y), 0, Vector2i(2,1))
					if is_cell_void(tilemap.get_neighbor_cell(Vector2i(path['left'].x+i, path['left'].y), 4)):
						tilemap.set_cell(3, tilemap.get_neighbor_cell(Vector2i(path['left'].x+i, path['left'].y), 4), 0, Vector2i(2,2))
						tilemap.set_cell(3, tilemap.get_neighbor_cell(Vector2i(path['left'].x+i, path['left'].y), 12), 0, Vector2i(2,0))
			else:
				for i in range(path['right'].y -path['left'].y):
					tilemap.set_cell(3, Vector2i(path['left'].x, path['left'].y+i), 0, Vector2i(2,1))
					if is_cell_void(tilemap.get_neighbor_cell(Vector2i(path['left'].x, path['left'].y+i), 8)):
						tilemap.set_cell(3, tilemap.get_neighbor_cell(Vector2i(path['left'].x, path['left'].y+i), 0), 0, Vector2i(3,1))
						tilemap.set_cell(3, tilemap.get_neighbor_cell(Vector2i(path['left'].x, path['left'].y+i), 8), 0, Vector2i(1,1))

func is_inside_padding(x, y, leaf, padding):
	return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

func is_wall(x, y, leaf, padding):
	return x == padding.x or y == padding.y or x == leaf.size.x - padding.z or y == leaf.size.y - padding.w
	
func is_cell_void(cell_coords):
	var floor_data = tilemap.get_cell_tile_data(1, cell_coords)
	var wall_data = tilemap.get_cell_tile_data(2, cell_coords)
	if (floor_data or wall_data):
		return false
	else:
		return true
	
func set_wall(x, y, leaf, padding):
	if y > padding.y and y < leaf.size.y - padding.w:
		if x == padding.x:
			tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(1,1))
		if x == leaf.size.x - padding.z:
			tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(3,1))
			
	if x > padding.x and x < leaf.size.x - padding.z:
		if y == padding.y:
			tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(2,0))
		if y == leaf.size.y - padding.w:
			tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(2,2))
			
	if x == padding.x and y == padding.y:
		tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(1,0))
	elif x == leaf.size.x - padding.z and y == padding.y:
		tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(3,0))
	elif x == padding.x and y == leaf.size.y - padding.w:
		tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(1,2))
	elif x == leaf.size.x - padding.z and y == leaf.size.y - padding.w:
		tilemap.set_cell(2, Vector2i(x + leaf.position.x, y + leaf.position.y), 0, Vector2i(3,2))
