
extends TileMap

var map_unwalkable = {}

func _ready():
	print("overlay")
	# load map_unwalkable from the base tilemap
	map_unwalkable = get_node("../base").map_unwalkable
	
	#for pos in map_unwalkable.size():
	#	x = Vector2(map_unwalkable.keys()[pos]).x
	#	y = Vector2(map_unwalkable.keys()[pos]).y - 1
	#	tile_switch = map_unwalkable.values()[pos]
	#	set_cell(x,y,tile_switch,false,false)
	
	for pos in map_unwalkable: # iterate through every key
		var x = pos.x - 0 # get the x coordinate
		var y = pos.y - 1 # get the y coordinate and move it one up
		var tile_switch = map_unwalkable[pos] - 6 # get tile identifier and modify it
		set_cell(x,y,tile_switch,false,false)
#		set_cell(x,y,0)
	pass
