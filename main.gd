extends Control

var roast_logs: Array[RoastLog] = []


func _ready() -> void:
	if OS.get_name() == "Android":
		get_window().set_size(Vector2(1080, 2400))
		get_window().mode = Window.MODE_FULLSCREEN
		get_window().unresizable = true
		get_window().borderless = true
	DirAccess.make_dir_absolute("user://roasts")
	_load_roast_logs()


func _load_roast_logs() -> void:
	var access := DirAccess.open("user://roasts")
	var roast_files := access.get_files()
	for file in roast_files:
		var loaded_log := ResourceLoader.load("user://roasts/" + file)
		roast_logs.push_back(loaded_log)


func _save_log(log_res_ref: RoastLog) -> void:
	var file_path := "user://roasts/" + log_res_ref.roast_name + "_" + log_res_ref.roast_date + ".tres"
	var save_result := ResourceSaver.save(log_res_ref, file_path)
	if save_result != OK:
		printerr(save_result)
	else:
		roast_logs.push_back(log_res_ref)
		_on_main_screen_on_menu_click()


func _on_main_screen_on_save(log_res_ref: RoastLog) -> void:
	_save_log(log_res_ref)
	roast_logs.push_front(log_res_ref)
	$MainScreen.reset_all()


func _on_main_screen_on_menu_click() -> void:
	$MainScreen.hide()
	$LogList.show()
	$LogList.load_logs(roast_logs)


func _on_log_list_on_view_entry(data: RoastLog) -> void:
	$MainScreen.show()
	$LogList.hide()
	$MainScreen.load_log(data)


func _on_log_list_on_back_pressed() -> void:
	$MainScreen.show()
	$LogList.hide()


func _on_log_list_on_new_pressed() -> void:
	$MainScreen.show()
	$LogList.hide()
	$MainScreen.reset_all()


func _on_log_list_on_compare_logs(data: RoastLog) -> void:
	$MainScreen.show()
	$LogList.hide()
	$MainScreen.load_compare_graph(data)


func _on_log_list_on_delete_log(data: RoastLog) -> void:
	var file_path := "user://roasts/" + data.roast_name + "_" + data.roast_date + ".tres"
	var success := DirAccess.remove_absolute(file_path)
	if success != OK:
		printerr("Could not delete log: " + file_path)
	else:
		var idx := roast_logs.find(data)
		if idx != -1:
			roast_logs.remove_at(idx)
