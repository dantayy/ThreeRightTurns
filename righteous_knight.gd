extends Node3D

@export var run_speed = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_righty_speed_change(new_speed):
	if(new_speed == 0):
		get_node("AnimationPlayer").play("Idle")
	elif(new_speed >= run_speed):
		get_node("AnimationPlayer").play("Running_A")
	else:
		get_node("AnimationPlayer").play("Walking_A")
