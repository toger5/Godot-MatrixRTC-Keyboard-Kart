extends PathFollow2D

var id: String

var text: String;
var car_position = 0
var line_edit: LineEdit
var is_own: bool = false
var name_label: String = "unkownUser"
signal car_position_update(car_postition: int, car_pos_text: int)
var current_progress_animated = 0.0 # this progress goes beyond 1 to track multiple rounds. It is the animated version of car_postion

func car_pos_text():
	return car_position % text.length()
func on_new_character(character):
	if text[car_pos_text()] == character:
		car_position += 1
		emit_signal("car_position_update", car_position, car_pos_text())
	else:
		print("wrong character:", character, "expected:", text[car_pos_text()])
	line_edit.text = ""
func on_focus_lost():
	line_edit.grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Name.text = name_label
	if(is_own):
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
