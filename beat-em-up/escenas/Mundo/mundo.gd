extends Node2D

@onready var camara := $Camara
@onready var jugador := $ObjetosJuego/Jugador

func _process(delta: float) -> void:
	if jugador.position.x > camara.position.x:
		camara.position.x = jugador.position.x
