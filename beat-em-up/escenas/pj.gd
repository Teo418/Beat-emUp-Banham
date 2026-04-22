extends CharacterBody2D

# esta es la "clase padre" (mas bien la escena padre),
# aca van a estar los atributos que luego los van a heredar
# tanto los enemigos como los jugadores

@export var vida : int
@export var danio : int
@export var velocidad : int = 100

@onready var animaciones = $Animaciones
@onready var golpesEnemigos = $HitboxGolpesEnemigos
@onready var hitboxWalk = $HitboxGolpesEnemigos
@onready var hitboxRecoger = $HitboxItems

var estaAtacando = false
var puedeAtacar = true
var aim = Vector2.RIGHT

#enum Estado {IDLE, WALK}
#
#var estado = Estado.IDLE

func _ready() -> void:
	animaciones.animation_finished.connect(_on_animacion_finished)

#func _process(delta: float) -> void:
	#_input()

#func _movimiento() -> void:

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("Derecha") - Input.get_action_strength("Izquierda")
	direction.y = Input.get_action_strength("Abajo") - Input.get_action_strength("Arriba")
	direction = direction.normalized()
	velocity = direction * velocidad
	move_and_slide()
	if direction.x != 0 and not estaAtacando:
		aim = Vector2.RIGHT * sign(direction.x)
		animaciones.flip_h = direction.x < 0
	golpesEnemigos.position.x = abs(golpesEnemigos.position.x) * aim.x
	if Input.is_action_pressed("Combo") :
		if _validarAccion():
			estaAtacando = true
			puedeAtacar = false
		animaciones.play("Combo")
		var bodies: Array = golpesEnemigos.get_overlapping_bodies()
		if bodies.size() > 0:
			bodies.front().queue_free()
	if estaAtacando and not Input.is_action_pressed("Combo"):
		var acciones = ["Agarrar", "Idle", "Walk"]
		if animaciones.animation not in acciones:
			estaAtacando = false
			puedeAtacar = true
			animaciones.play("Idle")
	if estaAtacando and not animaciones.is_playing():
		estaAtacando = false
		puedeAtacar = true
		animaciones.play("Idle")
	if not estaAtacando:
		if direction != Vector2.ZERO:
			animaciones.play("Walk")
		else:
			animaciones.play("Idle")

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Combo") and _validarAccion():
		#_iniciarAtaque()
	#elif estaAtacando and not Input.is_action_pressed("Combo"):
		#_invertir()
		#animaciones.play("Idle")
	if event.is_action_pressed("Agarrar") and _validarAccion():
		_agarrar()

func _validarAccion() -> bool:
	return puedeAtacar and not estaAtacando

func _agarrar() -> void:
	estaAtacando = true
	puedeAtacar = false
	animaciones.play("Agarrar")
	var items: Array = hitboxRecoger.get_overlapping_areas()
	if items.size() > 0:
		vida += items.front().valor
		items.front().queue_free()

func _on_animacion_finished(anim_name: StringName) -> void:
	print("animacion terminada: ", anim_name)
	if anim_name == "Combo":
		estaAtacando = false
		puedeAtacar = true
		#mismo problema que con _agarrar() con _invertir() adentro
		animaciones.play("Idle")
	elif anim_name == "Agarrar":
		var items: Array = hitboxRecoger.get_overlapping_areas()
		if items.size() > 0:
			vida += items.front().valor
			items.front().queue_free()
		estaAtacando = false
		puedeAtacar = true
		animaciones.play("Idle")
