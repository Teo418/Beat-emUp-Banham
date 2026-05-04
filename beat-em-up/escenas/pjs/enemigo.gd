class_name Enemigo
extends pj

@export var jugador : Jugador

func _obtenerDireccion() -> Vector2:
	if jugador == null:
		return Vector2.ZERO
	return (jugador.global_position - global_position).normalized()

func _procesarPostDanio() -> void:
	estaRecibiendoDanio = false
	if vida <= 0:
		queue_free()
	else:
		animaciones.play("Idle")
