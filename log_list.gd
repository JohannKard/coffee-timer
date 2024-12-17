class_name LogList
extends Control

signal on_view_entry(data: RoastLog)

@onready var log_entry = preload('res://log_entry.tscn')
@onready var content = $Container/Content

func load_logs(logs: Array[RoastLog]) -> void:
	for item in logs:
		var new_entry: LogEntry = log_entry.instantiate()
		new_entry.set_details(item.roast_name, item.roast_date)
		new_entry.on_view_data_pressed.connect(_on_entry_view_clicked.bind(item))
		content.add_child(new_entry)


func _on_entry_view_clicked(data: RoastLog) -> void:
	on_view_entry.emit(data)
