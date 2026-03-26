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
	
	var wait_time = 1.0 / char_per_second
	var curr_wait_time = wait_time
	
	dialogue_text.text = text
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
			wait_time = curr_wait_time
		await get_tree().process_frame			
	is_text_playing = false
	
func show_dialogue_box() -> void:
	dialogue_box.show()
	
func hide_dialogue_box() -> void:
	dialogue_box.hide()
	
#endregion

#region utils

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
