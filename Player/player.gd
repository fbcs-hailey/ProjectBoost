extends RigidBody3D
class_name Player

@export_range(750,2500) var thrust:=1000.0
@export var torque_thrust:=100.0
@export var starting_fuel=100


var transitioning :=false

@onready var sfx_death: AudioStreamPlayer = $SFXDeath
@onready var sfx_win: AudioStreamPlayer = $SFXWin
@onready var sfx_boost: AudioStreamPlayer3D = $SFXBoost
@onready var main_booster: GPUParticles3D = $MainBooster
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var ui:CanvasLayer

var fuel:int :
	set(new_fuel):
		fuel=new_fuel
		ui.update_fuel(new_fuel)
		

func _ready() -> void:
	ui=get_tree().get_first_node_in_group('ui')
	fuel=starting_fuel

func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost") and fuel>0:
			fuel-=.005
			apply_central_force(basis.y*delta*thrust)
			main_booster.emitting=true
			if  not sfx_boost.is_playing():
				sfx_boost.play()
		else:
			sfx_boost.stop()
			main_booster.emitting=false
		
		if Input.is_action_pressed("rotate_left"):
			apply_torque(Vector3(0,0,delta*torque_thrust))
			right_booster.emitting=true
		else:
			right_booster.emitting=false
		
		if Input.is_action_pressed("rotate_right"):
			apply_torque(Vector3(0,0,-delta*torque_thrust))
			left_booster.emitting=true
		else:
			left_booster.emitting=false

func _on_body_entered(body: Node) -> void:
	if not transitioning:
		if "Goal" in body.get_groups():
			print("you win")
			if body.file_path:
				complete_level.call_deferred(body.file_path)
			else:
				print('no next lvl found!')
		if "Not Goal" in body.get_groups():
			print("you lose")
			crash_sequence()

func crash_sequence():
	transitioning=true
	sfx_death.play()
	explosion_particles.emitting=true
	sfx_boost.stop()
	main_booster.emitting=false
	right_booster.emitting=false
	left_booster.emitting=false
	
	await get_tree().create_timer(1).timeout
	print("KABOOM")
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_lvl_file):
	transitioning=true
	sfx_win.play()
	success_particles.emitting=true
	sfx_boost.stop()
	main_booster.emitting=false
	right_booster.emitting=false
	left_booster.emitting=false
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(next_lvl_file)
