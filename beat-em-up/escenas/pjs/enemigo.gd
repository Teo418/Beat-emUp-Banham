class_name Enemigo
extends pj
signal danioRecibido(danio: int, direccion: Vector2)

@export var jugador : Jugador
@onready var hitboxEnemigo = $ReceptorDanio

func _ready() -> void:
	super()
	hitboxEnemigo.danioRecibido.connect(_on_danio_recibido)

func _obtenerDireccion() -> Vector2:
	if jugador == null:
		return Vector2.ZERO
	return (jugador.global_position - global_position).normalized()

func _procesarPostDanio() -> void:
	estaRecibiendoDanio = false
	if vida <= 0:
		animaciones.play("Muerte")
		await animaciones.animation_finished
		queue_free()
	else:
		animaciones.play("Idle")


func _recibirDanio(cantidad: int) -> void:
	if estaRecibiendoDanio:
		return
	estaRecibiendoDanio = true
	vida -= cantidad
	animaciones.play("Danio")
	if vida <= 0:
		queue_free()
		return
	animaciones.play("Danio")
	await animaciones.animation_finished
	estaRecibiendoDanio = false

func emitir_danio(posicion_atacante: Vector2, cantidad: int) -> void:
	var direccion := Vector2.LEFT if get_parent().global_position.x < posicion_atacante.x else Vector2.RIGHT
	danioRecibido.emit(cantidad, direccion)

func _on_danio_recibido(cantidad: int, direccion: Vector2) -> void:
	if estaRecibiendoDanio:
		return
	_recibirDanio(cantidad)
