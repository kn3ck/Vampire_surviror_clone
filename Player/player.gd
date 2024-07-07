extends CharacterBody2D


var movement_speed = 200.0
var hp = 80
var last_movement = Vector2.UP

#Experiance
var experience = 0
var experience_level = 1
var collected_expercience = 0

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")

#AttackNodes
@onready var iceSpearTimer:Timer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer:Timer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer:Timer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer:Timer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")
#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 1 
var icespear_attackspeed = 1.5
var icespear_level = 0

#zornadao
var tornado_ammo = 0
var tornado_baseammo = 3 
var tornado_attackspeed = 3.0
var tornado_level = 0

#Javelin 
var javelin_ammo = 1
var javelin_level = 1

#Enemy Related
var enemy_close = []


@onready var sprite = $PlayerSprite
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = %ExperienceBar
@onready var lblLevel = %lbl_level

func _ready():
	attack()
	set_expbar(experience, calculate_expericencecap())

func _physics_process(delta):
	movement()

func movement():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * movement_speed
	if direction.x >= 0:
		sprite.flip_h = true
	elif direction.x < 0: 
		sprite.flip_h = false
	
	if velocity != Vector2.ZERO:
		last_movement = direction
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	#sprite.rotation = velocity.angle()
	move_and_slide()

func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed
		if tornadoTimer.is_stopped():
			tornadoTimer.start()
	if javelin_level > 0:
		spawn_javelin()

func spawn_javelin():
	#var get_javelin_total = javelinBase.get_child_count()
	#var calc_spawns = javelin_ammo - get_javelin_total
	#while calc_spawns > 0:
	while javelinBase.get_child_count() < javelin_ammo:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		#calc_spawns -= 1
		
		
	
func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= 1
	print(hp)

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo
	iceSpearAttackTimer.start()
	

func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		add_child(icespear_attack)
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()


func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()
	
	
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_expericence(gem_exp)
		
func calculate_expericence(gem_exp):
	var exp_required = calculate_expericencecap()
	collected_expercience += gem_exp
	if experience + collected_expercience >= exp_required: # levelup
		collected_expercience -= exp_required-experience
		experience_level += 1
		print("Level:", experience_level)
		lblLevel.text = str("Level: ", experience_level)
		experience = 0
		exp_required = calculate_expericencecap()
		calculate_expericence(0)
	else:
		experience += collected_expercience
		collected_expercience = 0
		
	set_expbar(experience, exp_required)
	
func calculate_expericencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level-19)*8
	else:
		exp_cap = 255 + (experience_level-39)*12
		
	return exp_cap
	
	
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value
	
	


