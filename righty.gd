extends CharacterBody2D

# custom node vars
var speed = 200
var direction = Vector2.UP
var turnKeyed = false # set to true when button pressed
var turnCapable = false
var run = false # set to true when button pressed at start of game, do not unset afterwards

# signals to start/end races against pathfinder
signal start_race()
signal end_race()

# perform frame update actions in here
func _physics_process(_delta):
	if not run:
		return
	elif turnKeyed and turnCapable:
		direction = direction.rotated(PI / 2)
		rotate(PI / 2)
		turnKeyed = not turnKeyed
		turnCapable = not turnCapable
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
			start_race.emit()
		elif not turnKeyed:
			turnKeyed = true


func _on_wall_collision_detector_body_entered(body):
	# wall detected to the right, turn not possible
	turnCapable = false


func _on_wall_collision_detector_body_exited(body):
	# wall no longer detected to the right, turn possible
	turnCapable = true


func _on_boost_collision_detector_body_entered(body):
	# increase righty's speed
	speed += 50


func _on_goal_collision_detector_body_entered(body):
	print("Player reached goal!")
	run = false
	turnKeyed = false
	turnCapable = false
	end_race.emit()
	#get_tree().quit()
