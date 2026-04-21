extends CharacterBody2D

# esta es la "clase padre" (mas bien la escena padre),
# aca van a estar los atributos que luego los van a heredar
# tanto los enemigos como los jugadores

@export var vida : int
@export var danio : int
@export var velocidad : int


func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)

	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("Pegar")):
		var bodies :Array= $HitboxGolpesEnemigos.get_overlapping_bodies()
		if(bodies.size() == 0):
			return
		bodies.front().queue_free()
