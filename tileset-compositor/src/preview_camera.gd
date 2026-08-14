extends Camera2D

@export var base_speed:float
var speed_multiplier:float = 50.0
var target_dir:Vector2 = Vector2.ZERO

#func _ready() -> void:
#	make_current()

func _process(delta: float) -> void:
	if !is_current() : 
		print("!")
		enabled = true
		make_current()
	target_dir = Vector2.ZERO
	if Input.is_action_pressed("Run"):
		speed_multiplier = 3.0
	else:
		speed_multiplier = 1.0
	if Input.is_action_pressed("Up"):
		target_dir.y += 1.0
	elif Input.is_action_pressed("Down"):
		target_dir.y -= 1.0
	if Input.is_action_pressed("Left"):
		target_dir.x -= 1.0
	elif Input.is_action_pressed("Right"):
		target_dir.x += 1.0
		
	if target_dir != Vector2.ZERO:
		print(str(target_dir))
	else:
		return
		
	offset += target_dir * base_speed * speed_multiplier * delta
	print(" ~ "+str(offset))
	
