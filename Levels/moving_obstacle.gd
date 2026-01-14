extends AnimatableBody3D

@export var destination: Vector3
@export var duration:= 1.0
@export var size_x:float
@export var size_y:float
@export var size_z:float

func _ready() -> void:
	
	var tween=create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,'global_position',global_position+destination,duration)
	tween.tween_property(self,'global_position',global_position,duration)
