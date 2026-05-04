extends StaticBody2D

@onready var receptor_danio := $ReceptorDanio
@onready var hitbox_barril := $HitboxBarril
@export var intensidad_knockback : float
@export var velocidad_minima_danio : float = 150.0
@export var danio_barril : int = 10

var velocity := Vector2.ZERO

func _ready() -> void:
	receptor_danio.danioRecibido.connect(en_danio_recibido)
	hitbox_barril.body_entered.connect(_on_hitbox_barril_body_entered)

func _process(delta: float) -> void:
	position += velocity * delta
	velocity = velocity.lerp(Vector2.ZERO, 0.1)

func en_danio_recibido(danio: int, direccion: Vector2) -> void:
	velocity = direccion * intensidad_knockback

func _on_hitbox_barril_body_entered(body: Node) -> void:
	# Solo daña si va suficientemente rápido
	if velocity.length() < velocidad_minima_danio:
		return
	# Cuando tengas enemigos, chequeás si el body tiene _recibirDanio
	if body.has_method("_recibirDanio"):
		body._recibirDanio(danio_barril)
