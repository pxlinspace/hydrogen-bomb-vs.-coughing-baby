extends Node2D

const POINT_COUNT: int = 8

@export var delay: float = 0.0
@export var tween_duration: float = 0.4
@export var final_radius: float = 100.0
@export var starting_line_width: float = 32.0
@export var color: Color = Color.WHITE

var base_rotation: float = 0.0
var radius: float = 0.0
var line_width: float = 0.0


func _process(_delta: float) -> void:
	if visible:
		position = Vector2((randf()-0.5) * line_width*0.35, (randf()-0.5) * line_width*0.35)
		rotation = base_rotation + randf() * line_width * 0.02
		queue_redraw()


func _draw() -> void:
	var points: PackedVector2Array = []
	for i in POINT_COUNT+2:
		points.push_back(Vector2.RIGHT.rotated(float(i)/POINT_COUNT * TAU) * radius) 
	draw_polyline(points, color, line_width)


func play() -> void:
	await get_tree().create_timer(delay).timeout
	
	base_rotation = randf() * TAU
	rotation = base_rotation
	
	var radius_tween := create_tween()
	radius_tween.tween_property(self, "radius", final_radius, tween_duration) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	line_width = starting_line_width
	var line_width_tween := create_tween()
	line_width_tween.tween_property(self, "line_width", 0.0, tween_duration)
	line_width_tween.tween_callback(_cleanup)
	
	show()

func _cleanup() -> void:
	radius = 0
	hide()
