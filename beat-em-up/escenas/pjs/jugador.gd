class_name Jugador
extends pj

@onready var golpesEnemigos = $HitboxGolpesEnemigos
@onready var hitboxRecoger = $HitboxItems

func _ready() -> void:
	super()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Agarrar") and _validarAccion():
		_agarrar()

func _obtenerDireccion() -> Vector2:
	var direction := Vector2.ZERO
	direction.x = Input.get_action_strength("Derecha") - Input.get_action_strength("Izquierda")
	direction.y = Input.get_action_strength("Abajo") - Input.get_action_strength("Arriba")
	return direction.normalized()

func _physics_process(delta: float) -> void:
	super(delta)
	if estaRecibiendoDanio:
		return
	golpesEnemigos.position.x = abs(golpesEnemigos.position.x) * aim.x
	if Input.is_action_pressed("Combo"):
		_procesarCombo()
	elif estaAtacando:
		_verificarFinAtaque()

func _procesarCombo() -> void:
	if _validarAccion():
		estaAtacando = true
		puedeAtacar = false
		animaciones.play("Combo")
		# Solo busca el golpe al INICIO del combo, no cada frame
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

func _on_animacion_finished(anim_name: StringName) -> void:
	super(anim_name)
	match anim_name:
		"Combo":
			_resetearAtaque()
		"Agarrar":
			_recogerItem()
			_resetearAtaque()

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

func _procesarPostDanio() -> void:
	estaRecibiendoDanio = false
	if vida <= 0:
		animaciones.play("Muerte")
		await animaciones.animation_finished
		get_tree().change_scene_to_file("res://escenas/interfacesDeUsuario/game_over.tscn")
	else:
		animaciones.play("Idle")
