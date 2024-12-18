class_name LogList
extends Control

signal on_view_entry(data: RoastLog)

var roast_logs: Array[RoastLog] = []

@onready var log_entry = preload('res://log_entry.tscn')
@onready var content = $Container/Content


func load_logs(logs: Array[RoastLog]) -> void:
	for i in range(logs.size()):
		if roast_logs.size() > i and logs[i].roast_name == roast_logs[i].roast_name and logs[i].roast_date == roast_logs[i].roast_date:
			continue
		var new_entry: LogEntry = log_entry.instantiate()
		new_entry.set_details(logs[i].roast_name, logs[i].roast_date)
		new_entry.on_view_data_pressed.connect(_on_entry_view_clicked.bind(logs[i]))
		content.add_child(new_entry)
		roast_logs.push_back(logs[i])


func _on_entry_view_clicked(data: RoastLog) -> void:
	on_view_entry.emit(data)
