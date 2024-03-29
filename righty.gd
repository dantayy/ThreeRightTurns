class_name Righty extends CharacterBody2D

# custom node vars
@export var base_speed = 200
@export var min_speed = 150
@export var max_speed = 750
var speed = base_speed
var direction = Vector2.UP
var turnKeyed = false # set to true when button pressed
var turnCapable = false
var run = false # set to true when button pressed at start of game, do not unset afterwards

# signals to start/end races against pathfinder
signal start_race()
signal end_race()
signal speed_change(new_speed:int)

# perform frame update actions in here
func _physics_process(_delta):
	# always update the knight sprite to the viewport of the 3d knight model
	var texture = get_node("KnightViewport").get_texture()
	get_node("KnightSprite").texture = texture
	# race not started, do nothing
	if not run:
		return
	# process turns
	elif turnKeyed and turnCapable:
		direction = direction.rotated(PI / 2)
		rotate(PI / 2)
		turnKeyed = not turnKeyed
		turnCapable = not turnCapable
	# apply motion
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
			speed_change.emit(speed)
		elif not turnKeyed:
			turnKeyed = true

func reset():
	run = false
	turnKeyed = false
	turnCapable = false
	direction = Vector2.UP
	rotation = 0
	speed = base_speed
	speed_change.emit(0)	

func rotate_arrow(radians):
	get_node("ArrowSprite").rotation = radians - rotation

func _on_wall_collision_detector_body_entered(_body):
	# wall detected to the right, turn not possible
	turnCapable = false

func _on_wall_collision_detector_body_exited(_body):
	# wall no longer detected to the right, turn possible
	turnCapable = true

func _on_boost_collision_detector_body_entered(_body):
	# increase righty's speed
	speed = min(speed + 50, max_speed)
	speed_change.emit(speed)

func _on_slow_collision_detector_body_entered(_body):
	speed = max(speed - 50, min_speed)
	speed_change.emit(speed)

func _on_goal_collision_detector_body_entered(_body):
	print("Player reached goal!")
	reset()
	end_race.emit()
	speed_change.emit(0)
