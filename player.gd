extends CharacterBody2D

signal hit

@export var speed = 150
var screen_size
var alive = true

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(_delta):
	if not alive:
		return

	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1

	if direction.length() > 0:
		velocity = direction.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.stop()

	move_and_slide()

	#checks for mob collisions, if not mob then block the player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("mobs"):
			die()
			return

	position = position.clamp(Vector2.ZERO, screen_size)

	if direction.x != 0:
		$AnimatedSprite2D.animation = "right"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = direction.x < 0
	elif direction.y < 0:
		$AnimatedSprite2D.animation = "up"
	elif direction.y > 0:
		$AnimatedSprite2D.animation = "down"

func die():
	if not alive:
		return
	alive = false
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	alive = true
	position = pos
	show()
	$CollisionShape2D.disabled = false
