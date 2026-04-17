extends Node2D

## A pair of gothic Imperial pillars with a gap for the Marine to fly through.

signal scored

const SPEED := 200.0

var _active := true


func _physics_process(delta: float) -> void:
	if not _active:
		return
	position.x -= SPEED * delta

	# Remove when off-screen
	if position.x < -100:
		queue_free()


func setup(gap_center_y: float, gap_size: float, _viewport_height: float) -> void:
	var pipe_tex: Texture2D = $TopWall/Sprite.texture
	var tex_h: float = pipe_tex.get_height()
	var tex_w: float = pipe_tex.get_width()

	# Top wall — flipped, positioned so bottom edge meets the gap
	$TopWall.position.y = gap_center_y - gap_size / 2.0
	$TopWall/Sprite.position.y = -tex_h / 2.0
	$TopWall/CollisionShape2D.shape = RectangleShape2D.new()
	$TopWall/CollisionShape2D.shape.size = Vector2(tex_w, tex_h)
	$TopWall/CollisionShape2D.position.y = -tex_h / 2.0

	# Bottom wall — normal, positioned so top edge meets the gap
	$BottomWall.position.y = gap_center_y + gap_size / 2.0
	$BottomWall/Sprite.position.y = tex_h / 2.0
	$BottomWall/CollisionShape2D.shape = RectangleShape2D.new()
	$BottomWall/CollisionShape2D.shape.size = Vector2(tex_w, tex_h)
	$BottomWall/CollisionShape2D.position.y = tex_h / 2.0

	# Score zone in the gap
	$ScoreZone.position.y = gap_center_y
	$ScoreZone/CollisionShape2D.shape = RectangleShape2D.new()
	$ScoreZone/CollisionShape2D.shape.size = Vector2(10, gap_size)


func stop() -> void:
	_active = false


func _on_score_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		scored.emit()
		$ScoreZone/CollisionShape2D.set_deferred("disabled", true)
