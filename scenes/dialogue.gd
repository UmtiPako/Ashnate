class_name Dialogue extends CanvasLayer

@onready var dialogue_actions: DialogueActions = $DialogueActions
@onready var dialogue_repo: DialogueSettingsRepo = %DialogueSettingsRepo

@onready var dialogue_box: NinePatchRect = %DialogueBox
@onready var dialogue_text: RichTextLabel = %DialogueText

var is_dialogue_playing: bool = false
var is_text_playing: bool = false

var is_advance_requested: bool = false

func _ready() -> void:
	dialogue_actions.advance_requested.connect(on_advance_requested)

#region dialogue box actions

func show_dialogue_text(text: String, text_settings: String = "default") -> void:
	dialogue_text.text = text
	show_dialogue_box()

func play_dialogue(dialogue: Array[String]) -> void:
	var k := 0
	
	show_dialogue_box()	
	
	is_dialogue_playing = true
	
	while k < len(dialogue):		
		await play_dialogue_text(dialogue[k])
		
		await dialogue_actions.advance_requested
		
		k += 1
		is_advance_requested = false

	hide_dialogue_box()
	is_dialogue_playing = false		

func play_dialogue_text(text: String, char_per_second: float = 16, gibberish: String = "default", text_settings: String = "default") -> void:
	is_text_playing = true
	
	var default_wait_time = 1.0 / char_per_second
	var wait_time = default_wait_time
	var curr_wait_time = wait_time
	
	var speed_changes := parse_speeds_and_get_map(text, char_per_second)				
	
	dialogue_text.visible_characters = 0
	var total_visible = dialogue_text.get_total_character_count()		

	while dialogue_text.visible_characters < total_visible:
		if is_advance_requested:
			dialogue_text.visible_characters = total_visible
			break			
		
		var delta = get_process_delta_time()
		wait_time -= delta
		
		if wait_time <= 0:
			dialogue_text.visible_characters += 1
			if speed_changes.has(dialogue_text.visible_characters - 1):				
				wait_time = 1.0 / speed_changes[dialogue_text.visible_characters - 1]
				curr_wait_time = wait_time
			else:
				wait_time = curr_wait_time	

		await get_tree().process_frame			

	is_text_playing = false

func show_dialogue_box() -> void:
	dialogue_box.show()

func hide_dialogue_box() -> void:
	dialogue_box.hide()

#endregion

#region utils

func parse_speeds_and_get_map(raw_text: String, default_speed: float) -> Dictionary:
	var speed_changes: Dictionary = {0: default_speed}
	var regex = RegEx.new()
	regex.compile("\\[speed=(?P<val>\\d+)\\]|\\[/speed\\]")
	
	var matches = regex.search_all(raw_text)
	var helper = RichTextLabel.new()
	helper.bbcode_enabled = true
	
	var current_offset = 0
	
	for m in matches:
		var raw_start = m.get_start()
		var tag_text = m.get_string()
		
		var text_before_tag = raw_text.left(raw_start)
		var cleaned_text_before = regex.sub(text_before_tag, "", true)
		
		helper.text = cleaned_text_before
		var clean_index = helper.get_parsed_text().length()
		
		if tag_text.begins_with("[speed="):
			speed_changes[clean_index] = m.get_string("val").to_float()
		else:
			speed_changes[clean_index] = default_speed
			
	helper.free()
	
	dialogue_text.text = regex.sub(raw_text, "", true)
	return speed_changes
	
func set_advance_action(val: bool) -> void:
	dialogue_repo.is_advance_active = val

func apply_style(style_resource: Resource):
	dialogue_text.add_theme_font_override("normal_font", style_resource.font)
	dialogue_text.add_theme_font_size_override("normal_font_size", style_resource.font_size)
	dialogue_text.add_theme_color_override("default_color", style_resource.font_color)

func reset() -> void:
	dialogue_text.visible_characters = -1
	dialogue_text.max_lines_visible = -1
	dialogue_text.text	= ""
	is_dialogue_playing = false
	is_text_playing = false
	is_advance_requested = false	

#endregion

#region signal handling

func on_advance_requested() -> void:
	is_advance_requested = true if is_dialogue_playing or is_text_playing else false

#endregion
