class_name GraphPoint
extends Control


@onready var label := $Label
@onready var color_rect := $ColorRect


func set_label(lbl: String, color: Color = Color.WHITE) -> void:
	label.text = lbl
	label.add_theme_color_override("font_color", color)

func set_color(color: Color) -> void:
	color_rect.color = color
