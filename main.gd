extends Control

var roast_logs: Array[RoastLog] = []


func _ready() -> void:
	DirAccess.make_dir_absolute("user://roasts")
	_load_roast_logs()


func _load_roast_logs() -> void:
	var access := DirAccess.open("user://roasts")
	var roast_files := access.get_files()
	for file in roast_files:
		var loaded_log := ResourceLoader.load("user://roasts/" + file)
		roast_logs.push_back(loaded_log)


func _save_log(log_res_ref: RoastLog) -> void:
	var file_path := "user://roasts/" + log_res_ref.roast_name + "_" + Time.get_date_string_from_system() + ".tres"
	var save_result := ResourceSaver.save(log_res_ref, file_path)
	if save_result != OK:
		printerr(save_result)
		save_result = ResourceSaver.save(log_res_ref, file_path + "(2)")


func _on_main_screen_on_save(log_res_ref: RoastLog) -> void:
	_save_log(log_res_ref)


func _on_main_screen_on_menu_click() -> void:
	$MainScreen.hide()
	$LogList.show()
	$LogList.load_logs(roast_logs)
