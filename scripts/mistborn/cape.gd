extends Line2D

@export var target_path: NodePath
@export var segment_count: int = 6
@export var segment_length: float = 4.0
@export var gravity: float = 80.0
@export var friction: float = 0.85
@export var smooth_subdivisions: int = 4

@export var rest_angle: float = 0
@export var rest_strength: float = 5

var points_pos: Array[Vector2] = []
var old_points_pos: Array[Vector2] = []

var _smoothed_buf: Array[Vector2] = []
var _local_buf: PackedVector2Array

var _rest_dir: Vector2 = Vector2.RIGHT
var _cached_rest_angle: float = INF 
var _time: float = 0.0

@onready var target := get_node(target_path) as Node2D
@onready var tip: Polygon2D = $Tip

func _ready() -> void:
	var start_pos := target.global_position if target else global_position
	tip.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(2, 0), Vector2(0, 6)])

	var smoothed_size := (segment_count - 1) * smooth_subdivisions + 1
	_smoothed_buf.resize(smoothed_size)
	_local_buf.resize(smoothed_size)

	points_pos.resize(segment_count)
	old_points_pos.resize(segment_count)
	for i in range(segment_count):
		var p := start_pos + Vector2(0, i * segment_length)
		points_pos[i] = p
		old_points_pos[i] = p

func _physics_process(delta: float) -> void:
	if !target:
		return

	_time += delta

	if rest_angle != _cached_rest_angle:
		_rest_dir = Vector2.from_angle(deg_to_rad(rest_angle))
		_cached_rest_angle = rest_angle

	var target_pos := target.global_position

	for i in range(1, segment_count):
		var cur := points_pos[i]
		var vel := (cur - old_points_pos[i]) * friction
		old_points_pos[i] = cur
		cur += vel
		cur.y += gravity * delta

		var weight := float(i) / segment_count
		var ideal := points_pos[i - 1] + _rest_dir * segment_length
		cur += (ideal - cur) * rest_strength * weight * delta

		var sway  := sin(_time * 2.0   + i * 0.6) * weight * 6.0
		var sway2 := sin(_time * 2.3   + i * 1.1) * weight * 15.0
		cur.x += (sway + sway2) * delta

		points_pos[i] = cur

	for _j in range(5):
		points_pos[0] = target_pos
		for i in range(segment_count - 1):
			var a := points_pos[i]
			var b := points_pos[i + 1]
			var diff := a - b
			var dist := diff.length()
			if dist == 0.0:
				continue
			var correction := diff * (0.5 * (dist - segment_length) / dist)
			points_pos[i]     = a - correction
			points_pos[i + 1] = b + correction
		points_pos[0] = target_pos

	var n := points_pos.size()
	var out_idx := 0
	for i in range(n - 1):
		var p0 := points_pos[i - 1] if i > 0       else points_pos[i]     * 2.0 - points_pos[i + 1]
		var p1 := points_pos[i]
		var p2 := points_pos[i + 1]
		var p3 := points_pos[i + 2] if i + 2 < n   else points_pos[i + 1] * 2.0 - points_pos[i]

		for s in range(smooth_subdivisions):
			var t  := float(s) / float(smooth_subdivisions)
			var t2 := t * t
			var t3 := t2 * t
			_smoothed_buf[out_idx] = 0.5 * (
				2.0 * p1 +
				(-p0 + p2) * t +
				(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
				(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
			)
			out_idx += 1
	_smoothed_buf[out_idx] = points_pos[-1]

	var xform := global_transform.affine_inverse()
	var total := out_idx + 1
	if _local_buf.size() != total:
		_local_buf.resize(total)
	for i in range(total):
		_local_buf[i] = xform * _smoothed_buf[i]

	points = _local_buf

	var last := _local_buf[total - 1]
	var prev := _local_buf[total - 2]
	tip.position = last
	tip.rotation  = (last - prev).angle() - PI * 0.5
