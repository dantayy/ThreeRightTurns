extends TileMap

# time it takes for A* to take a step
@export var step_time = 1.0
# position and dimensions of the grid the A* pathfinder will use
# should match what the developer paints
@export var level_rect = Rect2i(0,0,5,5)
# name of next level to load when load_next_level is called
@export var next_level_name = ""

# constant atlas markers for wall, spawn, goal, and pathfinder tiles
const wall_atlas = Vector2i(1,0)
const spawn_atlas = Vector2i(2,0)
const goal_atlas = Vector2i(2,1)
const pathfinder_atlas = Vector2i(2,2)

# constant layer markers
const main_layer = 0
const path_layer = -1

#constant tileset source marker
const main_source = 1

# signal to emit when the A* pathing completes
signal pathing_complete()
#signal to emit when this level loads
signal level_loaded(pathing_possible:bool)
# signal to emit when there is no level to load in this one's place, 
signal game_over()

# the A* pathing tool
var pathfinder = AStarGrid2D.new()

# start/end points for player/pathfinder
var start_point = Vector2i()
var end_point = Vector2i()
# path between start and end points
var path: = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	# set pathfinder's working area
	pathfinder.region = level_rect
	# set pathfinder's tile size equal to the tile set's tile size
	pathfinder.cell_size = tile_set.tile_size
	# force pathfinder to not take diagonals
	pathfinder.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	# update the pathfinder with all of the settings we just set up
	pathfinder.update()
	# iterate through all cells in this map
	for cell in get_used_cells(main_layer):
		# pathfinder starting point
		if(get_cell_atlas_coords(main_layer, cell) == spawn_atlas):
			start_point = cell
		# pathfinder ending point
		elif(get_cell_atlas_coords(main_layer, cell) == goal_atlas):
			end_point = cell
		# set walls for pathfinder to route around
		else:
			pathfinder.set_point_solid(cell, get_cell_atlas_coords(main_layer, cell) == wall_atlas)
			
	# check to make sure spawn and goal are unique, if not then complain and bail early
	if start_point == end_point:
		print("Spawn/goal are equal or nonexistant, no path to find!")
		level_loaded.emit(false)
		return
	# find the path from spawn to goal with the grid we've set up
	path = pathfinder.get_id_path(start_point, end_point)
	# if no path was found, complain and bail
	if path.is_empty():
		print("No path between spawn and goal could be made!")
		level_loaded.emit(false)
		return
		
	level_loaded.emit(true)

func walk_path():
	# draw the path over the map with the set ammount of time between steps
	for cell in path:
		await get_tree().create_timer(step_time).timeout
		set_cell(path_layer, cell, main_source, pathfinder_atlas)
		
	# send the pathing complete signal to alert a game manager to initiate the loss state
	print("Path walked by the pathfinder!")
	pathing_complete.emit()
	
func load_next_level():
	# attempt to load whatever is in the next level name by path string
	var error:Error = get_tree().change_scene_to_file(next_level_name)
	# force game to end if no next level could be loaded
	if(error != OK):
		print("Attempt to load another level failed, ending game!")
		game_over.emit()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_righty_start_race():
	walk_path()
