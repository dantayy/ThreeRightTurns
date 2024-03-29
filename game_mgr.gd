extends Node2D

# path to the first level resource we'll load to start the game
# if not a resource that extends the custom class Level, game will abort
const start_level_path:String = "res://level_1.tscn"
# level path
var level_path:String = start_level_path
# level resource
var level_resource
# persistent Level node that will be filled by level resource
# after beating the first level it shall swap itself with the next specified Level via load_next_level
var current_level:Level
# persistant player-controlled character
var player_character:Righty
# main screen UI
var hud:CanvasLayer
# text applied on the UI
var overlay_text:RichTextLabel
# general use timer node
var game_timer:Timer

# flag set before the start of a level, after it's been loaded
var pregame = false
# flag set after the end of a level, before loading the next one
var postgame = false
# flag set at the end of the game to handle looping back to the beginning
var restart = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# get persistent nodes
	player_character = get_node("Righty")
	hud = get_node("HUD")
	overlay_text = get_node("HUD/StatusText")
	game_timer = get_node("Timer")
	# set up the first level
	level_setup(level_path, "[center]Ready?[/center]")
	# initiate level setup for first level
	#level_setup("[center]Ready![/center]")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# set goal arrow on player to point towards goal every frame
	var arrow_rotation = atan2(current_level.end_point.y *
	current_level.tile_set.tile_size.y +
	current_level.tile_set.tile_size.y / 2 -
	player_character.position.y,
	current_level.end_point.x *
	current_level.tile_set.tile_size.x +
	current_level.tile_set.tile_size.x / 2 -
	player_character.position.x) + PI / 2
	player_character.rotate_arrow(arrow_rotation)

# capture & process keyboard/mouse/gamepad events here
func _input(event):
	# handle button presses when not controlling the player
	if event.is_action_pressed("ui_right"):
		# if the reset flag is set, start the end game timer
		if restart:
			restart = false
			game_timer.stop()
			level_setup(start_level_path, "[center]Ready?[/center]")
		# if the pregame flag is set, pass control back to the player character
		elif pregame:
			pregame = false
			hud.visible = false
			player_character.visible = true
			player_character.set_process_input(true)
		# if the postgame flag is set, load the next level
		elif postgame:
			postgame = false
			level_setup(current_level.next_level_name, "[center]Ready?[/center]")

func level_setup(new_level_path:String, overlay:String):
	# load next level based on passed path string
	level_path = new_level_path
	level_resource = load(level_path)
	if(not level_resource):
		print("Attempt to load another level failed, ending game!")
		_on_current_level_game_over()
		return
	# free current level data
	if(current_level):
		current_level.queue_free()
	# instance the next level
	# will crash if next level is not a Level resource
	var next_level:Level = level_resource.instantiate()
	# connect level signals to manager receiver functions
	next_level.level_loaded.connect(_on_current_level_level_loaded)
	next_level.pathing_complete.connect(_on_current_level_pathing_complete)
	next_level.game_over.connect(_on_current_level_game_over)
	# set current level to next level
	current_level = next_level
	# add level back to main scene
	add_child(current_level)
	# move new level to back of scene
	move_child(current_level, 0)	
	# update overlay text
	overlay_text.text = overlay
	# enable overlay
	hud.visible = true
	# reset player
	player_character.reset()	
	# disable player
	player_character.visible = false
	player_character.set_process_input(false)	
	# move player to starting position in the loaded level
	player_character.position.x = (current_level.start_point.x * 
	current_level.tile_set.tile_size.x + 
	current_level.tile_set.tile_size.x / 2)
	player_character.position.y = (current_level.start_point.y * 
	current_level.tile_set.tile_size.y + 
	current_level.tile_set.tile_size.y / 2)
	# set pregame flag
	pregame = true	

# triggered when player starts running
func _on_righty_start_race():
	current_level.walk_path()

# triggered when player lands in the goal tile
func _on_righty_end_race():
	print("Player won race.")
	# set overlay text
	overlay_text.text = "[center]Next?[/center]"
	# enable overlay
	hud.visible = true
	# disable player
	#player_character.visible = false
	#player_character.set_process_input(false)
	# disable level
	#current_level.set_process(false)
	# set post-game flag
	postgame = true

func _on_current_level_pathing_complete():
	if not postgame:
		print("A* won race.")
		level_setup(level_path, "[center]Retry?[/center]")

func _on_current_level_level_loaded(pathing_possible:bool):
	# verify pathing was possible for the A* path walker before enabling player control
	if(not pathing_possible):
		print("Level loaded without a valid path to walk, quiting!")
		get_tree().quit()

func _on_current_level_game_over():
	overlay_text.text = "[center]End!\nPress to restart, otherwise game will close itself.[/center]"
	restart = true
	game_timer.start(10)

func _on_timer_timeout():
	if(restart):
		print("Game over!")
		get_tree().quit()
