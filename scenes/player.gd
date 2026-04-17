extends CharacterBody2D

## The Emperor's finest — a Space Marine with a jump pack.
## Controls: tap/click/space to fire the jump pack.

signal died

const GRAVITY := 980.0
const JUMP_VELOCITY := -350.0
const MAX_FALL_SPEED := 600.0
const ROTATION_SMOOTH := 8.0

var _alive := true

@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not _alive:
		return

	# Gravity
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Jump input
	if Input.is_action_just_pressed("flap"):
		velocity.y = JUMP_VELOCITY
		sprite.play("flap")
		_flap_timer()

	move_and_slide()

	# Tilt the marine based on vertical velocity
	var target_rotation := clampf(velocity.y / MAX_FALL_SPEED, -1.0, 1.0) * deg_to_rad(25.0)
	rotation = lerp(rotation, target_rotation, ROTATION_SMOOTH * delta)

	# Die if off-screen (top or bottom)
	if global_position.y > get_viewport_rect().size.y + 50 or global_position.y < -100:
		die()


func _flap_timer() -> void:
	# Return to idle after a short burst
	await get_tree().create_timer(0.35).timeout
	if _alive and sprite:
		sprite.play("idle")


func die() -> void:
	if not _alive:
		return
	_alive = false
	velocity = Vector2.ZERO
	set_physics_process(false)
	died.emit()


func reset(start_position: Vector2) -> void:
	_alive = true
	global_position = start_position
	velocity = Vector2.ZERO
	rotation = 0.0
	set_physics_process(true)
	if sprite:
		sprite.play("idle")
