extends Control


@onready var filtered_line_edit: FilteredLineEdit = $GridContainer/FilteredLineEdit
@onready var filtered_text_edit: FilteredTextEdit = $GridContainer/FilteredTextEdit


func _ready() -> void:
	filtered_line_edit.clamp_text()
	filtered_text_edit.clamp_lines()
