extends Node2D

@export var level_names:Array[String]
const start_level_name:String = "res://righty.tscn"
var start_level = preload(start_level_name)
var current_level:Level
var player_character
var hud:CanvasLayer
var overlay_text:RichTextLabel

# preempt game with start text
# when button pressed, load first level
# verify a good level has been loaded
# if level is good, move righty to position of spawn tile
# change text to "ready?" and await another button press
# at the same time, enable righty to accept inputs
# button press will hide text and start the race between righty and pathfinder
# start a timer when righty starts running
# end that timer when righty reaches their goal
# if righty reaches goal, disable them and reenable label w/ victory text
# include time in victory text
# next press will swap levels and reset righty to new spawn
# repeat steps from level verification onwards
# elif pathfinder reaches goal before righty, disable them and reenable label w/ loss text
# next press will reset righty to spawn position of current level and wipe pathfinder

# Called when the node enters the scene tree for the first time.
func _ready():
	# get persistent nodes
	player_character = get_node("Righty")
	hud = get_node("HUD")
	overlay_text = get_node("HUD/StatusText")
	# fail out if loaded asset is not a level
	if(not start_level is Level):
		print("Bad starting level passed, quiting!")
		get_tree().quit()
		return
	
	# instantiate starting level and set to current level var
	current_level = start_level.instantiate()
	# add level to main scene
	add_child(current_level)
	# move it to the bottom of the scene tree so it sits behind the player character
	move_child(current_level, 0)
	# move player to starting position in the loaded level
	print("Current level start point == %v" % current_level.start_point)
	player_character.position.x = current_level.start_point.x * current_level.tile_set.tile_size.x + current_level.tile_set.tile_size.x / 2
	player_character.position.y = current_level.start_point.y * current_level.tile_set.tile_size.y + current_level.tile_set.tile_size.y / 2
	# disable player pre-game	
	player_character.visible = false
	player_character.set_process_input(false)
	
	# set prompt text to "ready?"
	overlay_text.visible = true
	overlay_text.text = "[center]Ready?[/center]"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#overlay_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	pass
