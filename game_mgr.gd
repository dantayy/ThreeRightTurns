extends Node2D

@export var level_names:Array[String]
var current_level
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
	player_character = get_node("Righty")
	hud = get_node("HUD")
	overlay_text = get_node("HUD/StatusText")
	if(level_names.is_empty()):
		print("No levels passed to the array! Make some levels to play and try again!")
		get_tree().quit()
	# disable player pre-game	
	player_character.visible = false
	player_character.set_process_input(false)
	
	# set prompt text to "ready?"
	overlay_text.visible = true
	overlay_text.text = "[center]Ready?[/center]"
	#overlay_text.set_anchors_preset(Control.PRESET_FULL_RECT)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#overlay_text.set_anchors_preset(Control.PRESET_FULL_RECT)
	pass
