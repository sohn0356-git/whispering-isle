extends CharacterBody2D

@export var move_speed: float = 110.0

@onready var visual: Polygon2D = $Visual


func _ready() -> void:
	add_to_group("player")


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	if input_vector != Vector2.ZERO:
		visual.rotation = input_vector.angle()
