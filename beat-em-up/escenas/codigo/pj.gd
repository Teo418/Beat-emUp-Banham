extends CharacterBody2D

# esta es la "clase padre" (mas bien la escena padre),
# aca van a estar los atributos que luego los van a heredar
# tanto los enemigos como los jugadores

@export var vida : int
@export var danio : int
@export var velocidad : int = 100

@onready var animaciones = $Animaciones
@onready var golpesEnemigos = $HitboxGolpesEnemigos
@onready var hitboxRecoger = $HitboxItems

var estaAtacando = false
var puedeAtacar = true
var estaRecibiendoDanio = false
var aim = Vector2.RIGHT

#enum Estado {IDLE, WALK}
#
#var estado = Estado.IDLE
func _ready() -> void:
	animaciones.animation_finished.connect(_on_animacion_finished)

func _physics_process(delta: float) -> void:
	var direction := _obtenerDireccion()
	_mover(direction)
	if estaRecibiendoDanio:
		return
	_actualizarAim(direction)
	_procesarInput(direction)
	_actualizarAnimacion(direction)

func _obtenerDireccion() -> Vector2:
	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("Derecha") - Input.get_action_strength("Izquierda")
	direction.y = Input.get_action_strength("Abajo") - Input.get_action_strength("Arriba")
	return direction.normalized()

func _mover(direction: Vector2) -> void:
	velocity = direction * velocidad
	move_and_slide()

func _actualizarAim(direction: Vector2) -> void:
	if direction.x != 0 and not estaAtacando:
		aim = Vector2.RIGHT * sign(direction.x)
		animaciones.flip_h = direction.x < 0
	golpesEnemigos.position.x = abs(golpesEnemigos.position.x) * aim.x

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Agarrar") and _validarAccion():
		_agarrar()

func _procesarInput(direction: Vector2) -> void:
	if Input.is_action_pressed("Combo"):
		_procesarCombo()
	elif estaAtacando:
		_verificarFinAtaque()

func _procesarCombo() -> void:
	if _validarAccion():
		estaAtacando = true
		puedeAtacar = false
	animaciones.play("Combo")
	var bodies: Array = golpesEnemigos.get_overlapping_areas()
	if bodies.size() > 0:
		var area = bodies.front()
		if area.has_method("emitir_danio"):
			area.emitir_danio(global_position, danio)

func _verificarFinAtaque() -> void:
	var accionesQueCortanAtaque = ["Agarrar", "Idle", "Walk"]
	if not Input.is_action_pressed("Combo"):
		if animaciones.animation not in accionesQueCortanAtaque:
			_resetearAtaque()
	if not animaciones.is_playing():
		_resetearAtaque()

func _resetearAtaque() -> void:
	estaAtacando = false
	puedeAtacar = true
	animaciones.play("Idle")

func _actualizarAnimacion(direction: Vector2) -> void:
	if not estaAtacando:
		if direction != Vector2.ZERO:
			animaciones.play("Walk")
		else:
			animaciones.play("Idle")

func _validarAccion() -> bool:
	return puedeAtacar and not estaAtacando

func _recibirDanio(cantidad: int) -> void:
	if estaRecibiendoDanio:
		return
	vida -= cantidad
	estaRecibiendoDanio = true
	animaciones.play("Danio")

func _agarrar() -> void:
	estaAtacando = true
	puedeAtacar = false
	animaciones.play("Agarrar")
	_recogerItem()

func _recogerItem() -> void:
	var items: Array = hitboxRecoger.get_overlapping_areas()
	if items.size() > 0:
		vida += items.front().valor
		items.front().queue_free()

func _procesarPostDanio() -> void:
	estaRecibiendoDanio = false
	if vida <= 0:
		animaciones.play("Muerte")
		get_tree().change_scene_to_file("res://escenas/interfacesDeUsuario/game_over.tscn")
	else:
		animaciones.play("Idle")

func _on_animacion_finished(anim_name: StringName) -> void:
	match anim_name:
		"Combo":
			_resetearAtaque()
		"Agarrar":
			_recogerItem()
			_resetearAtaque()
		"Danio":
			_procesarPostDanio()
