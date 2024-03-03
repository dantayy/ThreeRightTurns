extends CharacterBody2D

# custom node vars
var speed = 200
var direction = Vector2.UP
var turn = false # set to true when button pressed
var run = false # set to true when button pressed at start of game, do not unset afterwards

# perform frame update actions in here
func _physics_process(delta):
	if not run:
		return
	elif turn:
		direction = direction.rotated(PI / 2)
		#rotate(PI / 2)
		turn = not turn
	velocity = direction * speed
	move_and_slide()

# character moves over tiles at given speed
# when on a tile marked as a turn tile (placed at hallway intersections)
# check for turn flag asynchronosly set by button press
# if set, turn the char's velocity 90 degrees so it starts going down the path to its right
# then unset flag, and return to square one

# capture & process keyboard/mouse/gamepad events here
func _input(event):
	if event.is_action_pressed("ui_right"):
		if not run:
			run = true
		elif not turn:
			turn = true
