extends Control

func _ready():
#	get_node("FilteredLineEdit").grab_focus()
#	get_node("FilteredTextEdit").grab_focus()
#	get_node("FilteredLineEdit").clamp_text()
	get_node("FilteredTextEdit").clamp_lines()
