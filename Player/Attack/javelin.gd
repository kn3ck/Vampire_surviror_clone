extends Area2D

var level = 1
var hp = 9999
var speed = 200.0
var damage = 10
var attack_size = 1.0
var attack_speed = 4.0
var knockback_amount = 100
var paths = 1

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var spr_jav_req = preload("res://Textures/Items/Weapons/javelin_3_new.png")
var spr_jav_atk = preload("res://Textures/Items/Weapons/javelin_3_new_attack.png")

@onready var player:CharacterBody2D = get_tree().get_first_node_in_group("player")

@onready var sprite = $Sprite2D
@onready var collions = $CollisionShape2D
@onready var attackTimer:Timer = get_node("%AttackTimer")
@onready var changeDirectionTimer:Timer = get_node("%ChangeDirection")
@onready var resetPosTimer:Timer = get_node("%ResetPosTimer")
@onready var snd_attack = $snd_attack

signal remove_from_array(object)

func _ready():
	update_javelin()
	
func update_javelin():
	level = player.javelin_level
	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			attack_size = 1.0
			attack_speed = 4.0
			knockback_amount = 100
			paths = 3
			
	scale = Vector2(1.0,1.0) * attack_size
	attackTimer.wait_time = attack_speed
	
func _physics_process(delta):
	if not target_array.is_empty():
		position += angle*speed*delta
	else:
		var player_angle = global_position.direction_to(reset_pos)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.y) > 500 or abs(distance_dif.x) > 500:
			return_speed = 100  
		position += player_angle*return_speed*delta
		rotation = global_position.direction_to(player.global_position).angle() + deg_to_rad(135)
		
		

func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array", self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
	enable_attack()
	target = target_array[0]
	process_path()
		
func process_path():
	angle = global_position.direction_to(target)
	changeDirectionTimer.start()
	var tween = create_tween()
	var new_rotarion_degrees = angle.angle() + deg_to_rad(135)
	tween.tween_property(self, "rotation", new_rotarion_degrees,0.25).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play
	
func enable_attack(atk = true):
	if atk:
		collions.call_deferred("set", "disabled", false)
		sprite.texture = spr_jav_atk
	else:
		collions.call_deferred("set", "disabled", true)
		sprite.texture = spr_jav_req

func _on_attack_timer_timeout():
	add_paths()


func _on_change_direction_timeout():
	if not target_array.is_empty():
		target_array.remove_at(0)
		if not target_array.is_empty():
			target = target_array[0]
			process_path() 
			snd_attack.play()
			emit_signal("remove_from_array", self)
		else:
			enable_attack(false)
	else:
		changeDirectionTimer.stop()


func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1: 
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
