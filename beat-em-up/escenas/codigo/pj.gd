class_name pj
extends CharacterBody2D

@export var vida : int
@export var danio : int
@export var velocidad : int

@onready var animaciones = $Animaciones

var estaAtacando = false
var puedeAtacar = true
var estaRecibiendoDanio = false
var aim = Vector2.RIGHT

func _ready() -> void:
	animaciones.animation_finished.connect(_on_animacion_finished)

func _physics_process(delta: float) -> void:
	var direction := _obtenerDireccion()
	_mover(direction)
	if estaRecibiendoDanio:
		return
	_actualizarAim(direction)
	_actualizarAnimacion(direction)


func _obtenerDireccion() -> Vector2:
	return Vector2.ZERO

func _actualizarAnimacion(direction: Vector2) -> void:
	if not estaAtacando:
		animaciones.play("Walk" if direction != Vector2.ZERO else "Idle")


func _mover(direction: Vector2) -> void:
	velocity = direction * velocidad
	move_and_slide()

func _actualizarAim(direction: Vector2) -> void:
	if direction.x != 0 and not estaAtacando:
		aim = Vector2.RIGHT * sign(direction.x)
		animaciones.flip_h = direction.x < 0

func _validarAccion() -> bool:
	return puedeAtacar and not estaAtacando

func _resetearAtaque() -> void:
	estaAtacando = false
	puedeAtacar = true
	animaciones.play("Idle")

func _recibirDanio(cantidad: int) -> void:
	if estaRecibiendoDanio:
		return
	vida -= cantidad
	estaRecibiendoDanio = true
	animaciones.play("Danio")

func _on_animacion_finished(anim_name: StringName) -> void:
	match anim_name:
		"Danio":
			_procesarPostDanio()

func _procesarPostDanio() -> void:
	estaRecibiendoDanio = false
	animaciones.play("Idle" if vida > 0 else "Muerte")
