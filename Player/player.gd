extends RigidBody3D
class_name Player

@export_range(750,2500) var thrust:=1000.0
@export var torque_thrust:=100.0
var transitioning :=false
@onready var sfx_death: AudioStreamPlayer = $SFXDeath
@onready var sfx_win: AudioStreamPlayer = $SFXWin
@onready var sfx_boost: AudioStreamPlayer3D = $SFXBoost
@onready var main_booster: GPUParticles3D = $MainBooster
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster



func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost"):
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
	sfx_boost.stop()
	main_booster.emitting=false
	right_booster.emitting=false
	await get_tree().create_timer(1).timeout
	print("KABOOM")
	get_tree().reload_current_scene.call_deferred()

func complete_level(next_lvl_file):
	transitioning=true
	sfx_win.play()
	sfx_boost.stop()
	main_booster.emitting=false
	right_booster.emitting=false
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file(next_lvl_file)
