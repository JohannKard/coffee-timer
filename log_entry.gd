class_name LogEntry
extends Control

signal on_view_data_pressed()

func set_details(roast_name: String, date: String) -> void:
	$Container/Details/NameOut.text = roast_name
	$Container/Details/DateOut.text = date


func _on_view_btn_pressed() -> void:
	on_view_data_pressed.emit()
