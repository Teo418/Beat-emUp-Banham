extends StaticBody2D

@onready var receptor_danio := $ReceptorDanio
@onready var skin := $Sprite2D

@export var intensidad_knockback : float

enum Estados {IDLE, DESTRUIDO}

var altura := 0.0
var velocidad_altura := 0.0
var estado := Estados.IDLE
var velocity := Vector2.ZERO

func _ready() -> void:
	receptor_danio.danioRecibido.connect(en_danio_recibido)

func _process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.lerp(Vector2.ZERO, 0.1)

func en_danio_recibido(danio: int, direccion: Vector2) -> void:
	if estado == Estados.IDLE:
		skin.frame = 1
		
		estado = Estados.DESTRUIDO
		velocity = direccion * intensidad_knockback
