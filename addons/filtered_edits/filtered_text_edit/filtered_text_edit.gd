@tool
class_name FilteredTextEdit
extends TextEdit

## [code]TextEdit[/code] with filters. It [b]cannot[/b] clamp [param text] numeric value.

## Filter modes:
## [param none] (no filter),
## [param no-num] (no 0-9 characters),
## [param +0i] (positive or zero integer),
## [param i] (integer),
## [param +0f] (positive float) or
## [param f] (float).
## Note that "." and "-" count as characters in max length.
@export_enum("none", "no-num", "+0i", "i", "+0f", "f") var filter_mode: int = 0:
	set(filter_mode_):
		filter_mode = filter_mode_
		_update_filter_mode()
## Maximun numeric value of the [param text]. Only used in numeric [param filter_mode].
@export var max_value: float = INF
## Minimun numeric value of the [param text]. Only used in numeric [param filter_mode].
@export var min_value: float = -INF
## [code]RegEx[/code] to filter text.
var reg: RegEx = RegEx.new()
## Current caret line.
var current_caret_line: int = 0
## Text before inserting a new character.
var old_text: String
## Length of [param old_text].
var old_text_length: int = 0
## Previous number of lines before.
var old_line_count: int = 0
## Lenght of [param new_text] in [code]_on_text_changed[/code].
var new_text_length: int = 0
## Character to be added
var new_char: String = ""
## Index of [param new_char] in [param new_text] in [code]_on_text_changed[/code].
var new_char_index: int
## Function called for filtering.
var filter: Callable =  func filter_none(new_char_: String) -> String:
	return new_char_


func _ready():
	current_caret_line = get_caret_line()
	old_text = get_line(current_caret_line)
	old_text_length = old_text.length()
	old_line_count = get_line_count()
	text_changed.connect(_on_text_changed)


## Called when [param filter_mode] is set.
func _update_filter_mode() -> void:
	# none
	if filter_mode == 0:
		filter = func filter_none(new_char_: String) -> String:
			return new_char_
	# text
	elif filter_mode == 1:
		reg.compile("\\d")
		filter = func filter_no_num(new_char_: String) -> String:
			if reg.search(new_char_) == null:
				return new_char_
			return ""
	# +0i
	elif filter_mode == 2:
		reg.compile("\\d")
		filter = func filter_p0_i(new_char_: String) -> String:
			if reg.search(new_char_) == null:
				return ""
			elif old_text == "0" and get_caret_column() != 0:
				if new_char_ != "0":
					# delete_char_at_caret() cannot be placed here due to length checks
					set_line(current_caret_line, "")
				else:
					return ""
			return new_char_
	# i
	elif filter_mode == 3:
		reg.compile("[\\d-]")
		filter = func filter_i(new_char_: String) -> String:
			if reg.search(new_char_) == null:
				return ""
			elif new_char_ == "-":
				if old_text.contains("-"):
					set_line(current_caret_line, old_text.erase(0))
					old_text = get_line(current_caret_line)
					set_caret_column(old_text.length())
					# Do this change to avoid passing new_text_length < old_text_length
					new_text_length = old_text_length
					return ""
				elif old_text.length() == 0:
					insert_text_at_caret("-0")
					return ""
				else:
					set_caret_column(0)
					insert_text_at_caret("-")
					set_caret_column(old_text.length())
					return ""
			elif old_text == "0" and get_caret_column() != 0:
				if new_char_ != "0":
					# delete_char_at_caret() cannot be placed here due to length checks
					set_line(current_caret_line, "")
					old_text = get_line(current_caret_line)
				else:
					return ""
			elif old_text == "-0" and get_caret_column() != 0:
				if new_char_ != "0":
					set_line(current_caret_line, "-")
					old_text = get_line(current_caret_line)
					set_caret_column(old_text.length())
				else:
					return ""
			return new_char_
	# +0f
	elif filter_mode == 4:
		reg.compile("[\\d.]")
		filter = func filter_p0_f(new_char_: String) -> String:
			if reg.search(new_char_) == null:
				return ""
			elif new_char_ == ".":
				if old_text.contains("."):
					return ""
				elif old_text.length() == 0:
					insert_text_at_caret("0")
			elif old_text == "0" and get_caret_column() != 0:
				if new_char_ != "0":
					# delete_char_at_caret() cannot be placed here due to length checks
					set_line(current_caret_line, "")
					old_text = get_line(current_caret_line)
				else:
					return ""
			return new_char_
	# f
	elif filter_mode == 5:
		reg.compile("[\\d.-]")
		filter = func filter_f(new_char_: String) -> String:
			if reg.search(new_char_) == null:
				return ""
			elif new_char_ == ".":
				if old_text.contains("."):
					return ""
				elif old_text.length() == 0:
					insert_text_at_caret("0")
			elif new_char_ == "-":
				if old_text.contains("-"):
					set_line(current_caret_line, get_line(current_caret_line).erase(0))
					old_text = get_line(current_caret_line)
					set_caret_column(text.length())
					# Do this change to avoid passing new_text_length < old_text_length
					new_text_length = old_text_length
					return ""
				elif old_text.length() == 0:
					insert_text_at_caret("-0")
					return ""
				else:
					set_caret_column(0)
					insert_text_at_caret("-")
					set_caret_column(old_text.length())
					return ""
			elif old_text == "0" and get_caret_column() != 0:
				if new_char_ != "0":
					# delete_char_at_caret() cannot be placed here due to length checks
					set_line(current_caret_line, "")
					old_text = get_line(current_caret_line)
				else:
					return ""
			elif old_text == "-0" and get_caret_column() != 0:
				if new_char_ != "0":
					set_line(current_caret_line, "-")
					old_text = get_line(current_caret_line)
					set_caret_column(old_text.length())
				else:
					return ""
			return new_char_


## Manages text input and filtering.
func _on_text_changed() -> void:
	current_caret_line = get_caret_line()
	var new_text: String = get_line(current_caret_line)
	var new_line_count: int = get_line_count()
	# Update new length
	new_text_length = text.length()
	# If inserting/deleting new line, pass
	if new_line_count != old_line_count:
		old_line_count = new_line_count
		old_text_length = get_line(current_caret_line).length()
		return
	# If deleting text, pass
	if new_text_length < old_text_length:
		old_text_length = new_text_length
		return
	# Else, need to determine the new character and the old text
	# New character
	new_char_index = get_caret_column() - 1
	new_char = get_line(current_caret_line)[new_char_index]
	# Old text
	var left_text = new_text.substr(0, new_char_index)
	var right_text = new_text.substr(new_char_index+1, -1)
	old_text = left_text + right_text
	# Go back to the old text to decide insertion
	set_line(current_caret_line, old_text)
	# Set the caret at the right position for insertion
	set_caret_column(new_char_index)
	# Filtering
	new_char = filter.call(new_char)
	# Insert new text at the right position
	insert_text_at_caret(new_char)
	# Update old length
	old_text_length = new_text_length
	# Clamp values
	clamp_text_values()


## Clamps the numeric value of the lines if [param filter_mode] is a numeric mode.
func clamp_text_values() -> void:
	if filter_mode < 2:
		return
	var value: float
	for i in range(get_line_count()):
		value = float(get_line(i))
		value = clamp(value, min_value, max_value)
		set_line(i, str(value))
		set_caret_line(i)
