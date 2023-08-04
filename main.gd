extends Control

func _ready():
#	get_node("FilteredLineEdit").grab_focus()
#	get_node("FilteredTextEdit").grab_focus()
	get_node("FilteredLineEdit").clamp_text()
	for i in range(get_node("FilteredTextEdit").get_line_count()):
		get_node("FilteredTextEdit").clamp_line(i)


func _on_line_edit_text_changed(_new_text):
	print(get_node("LineEdit").caret_column)


func _on_line_edit_focus_exited():
	print(get_node("LineEdit").caret_column)
