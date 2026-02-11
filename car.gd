extends PathFollow2D

var id: String

var text: String;
var car_position = 0
var line_edit: LineEdit
var is_own: bool = false
var name_label: String = "unkownUser"
var current_progress_animated = 0.0 # this progress goes beyond 1 to track multiple rounds. It is the animated version of car_postion
var turn = 0
var turn_start_ts = []
var previous_global_x: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var car_textures: Array[Texture2D] = [
	preload("res://assets/cars/blue-car.png"),
	preload("res://assets/cars/brown-datsun.png"),
	preload("res://assets/cars/camper-van.png"),
	preload("res://assets/cars/flatbed-with-house.png"),
	preload("res://assets/cars/ice-cream-van-a.png"),
	preload("res://assets/cars/ice-cream-van-b.png"),
	preload("res://assets/cars/luton-van.png"),
	preload("res://assets/cars/motor-cycle-a.png"),
	preload("res://assets/cars/motor-cycle-b.png"),
	preload("res://assets/cars/pink-jeep.png"),
	preload("res://assets/cars/red-corolla.png"),
	preload("res://assets/cars/white-plumbing-van.png"),
	preload("res://assets/cars/yellow-bus.png"),
	preload("res://assets/cars/yellow-sports-car.png")
]

signal car_position_update(car_postition: int, car_pos_text: int)
signal turn_completed(turn: int, time: int)

func car_pos_text():
	return car_position % text.length()

func update_turn():
	print("GODOT update turn")
	var current_turn = int(float(car_position) / float(text.length()))
	# update start ts array
	# +1 since we need one start ts when we are still in turn 0 (induction for all other turns)
	if(turn_start_ts.size() < current_turn+1):
		turn_start_ts.append(Time.get_ticks_msec())
	# emit turn complete event
	print("GODOT current_turn ", current_turn," turn ", turn)
	if(current_turn != turn and current_turn > 0):
		turn = current_turn
		print("GODOT Array to get index: ", turn," and ", (turn-1), " in ", JSON.stringify(turn_start_ts))
		emit_signal("turn_completed", turn, turn_start_ts[turn] - turn_start_ts[turn-1])

func on_new_character(character):
	if text[car_pos_text()] == character:
		car_position += 1
		emit_signal("car_position_update", car_position, car_pos_text())
	else:
		print("wrong character:", character, "expected:", text[car_pos_text()])
	update_turn()
	line_edit.text = ""

func get_best_turn():
	var turn_times = []
	var best_time = null
	if(turn_start_ts.size() < 2):
		return null
	print("GODOT", turn_start_ts)
	for i in range(turn_start_ts.size() - 1):
		var time = turn_start_ts[i+1] - turn_start_ts[i]
		turn_times.push_back(time)
		if(best_time == null or time < best_time):
			best_time = time
	var best_turn_index = turn_times.find(best_time)
	return [best_turn_index+1, best_time]

func on_focus_lost():
	line_edit.grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Name.text = name_label
	
	previous_global_x = global_position.x
	
	var random_texture: Texture2D = car_textures.pick_random()
	sprite.texture = random_texture
	
	if(is_own):
		modulate = Color.WHITE
		$Name.label_settings = $Name.label_settings.duplicate()
		$Name.label_settings.font_color = Color.BLANCHED_ALMOND
		line_edit = LineEdit.new()
		line_edit.connect("text_changed", on_new_character)
		line_edit.connect("focus_exited", on_focus_lost)
		line_edit.visible=false
		self.add_child(line_edit)
		line_edit.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(!(self.get_parent() is Path2D)):
		return
	
	var target_progress = float(car_position)/float(text.length())
	var speed = 0.01
	var boost = 0.0
	if( target_progress - current_progress_animated > 0.01):
		boost = (abs(target_progress - current_progress_animated)*100)**2/100
	var dir = sign(target_progress - current_progress_animated);
	var step = delta*(speed+boost)
	if(dir > 0):
		current_progress_animated += step
		self.progress_ratio = current_progress_animated
	
	var current_x = global_position.x
	var delta_x = current_x - previous_global_x

	if abs(delta_x) > 0.1:
		sprite.flip_h = delta_x > 0

	previous_global_x = current_x
