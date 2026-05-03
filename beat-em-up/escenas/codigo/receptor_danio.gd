
extends Area2D

signal danioRecibido(danio: int, direccion: Vector2)

func emitir_danio(posicion_atacante: Vector2, cantidad: int) -> void:
	var direccion := Vector2.LEFT if get_parent().global_position.x < posicion_atacante.x else Vector2.RIGHT
	danioRecibido.emit(cantidad, direccion)
