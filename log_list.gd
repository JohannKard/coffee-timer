class_name LogList
extends Control

signal on_view_entry(data: RoastLog)
signal on_compare_logs(data: RoastLog)
signal on_delete_log(data: RoastLog)
signal on_back_pressed()
signal on_new_pressed()


var roast_logs: Array[RoastLog] = []

@onready var log_entry = preload('res://log_entry.tscn')
@onready var content = $Container/Content


func load_logs(logs: Array[RoastLog]) -> void:
	_clear_logs()
	for i in range(logs.size()):
		var new_entry: LogEntry = log_entry.instantiate()
		new_entry.set_details(logs[i].roast_name, logs[i].roast_date)
		new_entry.on_view_data_pressed.connect(_on_entry_view_clicked.bind(logs[i]))
		new_entry.on_compare_logs_pressed.connect(_on_compare_logs_pressed.bind(logs[i]))
		new_entry.on_delete_pressed.connect(_on_delete_pressed.bind(logs[i]))
		content.add_child(new_entry)
		roast_logs.push_back(logs[i])


func _clear_logs() -> void:
	for roast_log in content.get_children():
		if roast_log is LogEntry:
			roast_log.queue_free()
	roast_logs.clear()


func _on_entry_view_clicked(data: RoastLog) -> void:
	on_view_entry.emit(data)


func _on_compare_logs_pressed(data: RoastLog) -> void:
	on_compare_logs.emit(data)


func _on_delete_pressed(data: RoastLog) -> void:
	on_delete_log.emit(data)


func _on_back_btn_pressed() -> void:
	on_back_pressed.emit()


func _on_new_btn_pressed() -> void:
	on_new_pressed.emit()
