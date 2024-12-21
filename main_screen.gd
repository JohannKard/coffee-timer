class_name MainScreen
extends Control

signal on_save(log_res_ref: RoastLog)
signal on_menu_click()

var data: RoastLog

var start_btn_status := false
var timer := 0.0

var plot: PlotItem = null
var compare_plot: PlotItem = null
var event_point_nodes: Array[GraphPoint] = []

var _graph_point := preload("res://graph_point.tscn")

var graph: Graph2D

var start_btn: Button
var first_crack_btn: Button

var name_in: LineEdit
var roast_setting_in: LineEdit 
var grn_wgt_in: LineEdit
var rst_wgt_in: LineEdit
var temp_in: LineEdit
var note_in: LineEdit
var general_notes_in: TextEdit

var date_out: Label
var wgt_loss_out: Label
var first_crack_out: Label
var timer_display: Label
var fifteen_out: Label
var seventeen_out: Label
var twenty_out: Label
var twenty_two_out: Label
var development_out: Label


func _ready() -> void:
	_set_node_accessors()
	data = RoastLog.new()
	grn_wgt_in.text_changed.connect(_on_weight_text_changed)
	rst_wgt_in.text_changed.connect(_on_weight_text_changed)
	data.roast_date = Time.get_date_string_from_system()
	date_out.text = data.roast_date
	_reset_plot()


func _set_node_accessors() -> void:
	graph = $Container/Content/SinglePlot/Graph2D
	start_btn = $Container/Content/RoastingTimes/StartBtn
	first_crack_btn = $Container/Content/RoastingTimes/FirstCrackBtn
	name_in = $Container/Content/RoastInfo/NameIn
	roast_setting_in = $Container/Content/RoastInfo/RoastSettingIn
	grn_wgt_in = $Container/Content/WgtDetails/GreenWeightIn
	rst_wgt_in = $Container/Content/WgtDetails/RoastWeightIn
	temp_in = $Container/Content/GraphControls/TempIn
	note_in = $Container/Content/GraphControls/NoteIn
	general_notes_in = $Container/Content/GenNoteIn
	date_out = $Container/Content/TopBar/AppDetails/DateOut
	wgt_loss_out = $Container/Content/RoastResults/WeightLossOut
	first_crack_out = $Container/Content/RoastResults/FirstCrackOut
	timer_display = $Container/Content/RoastingTimes/TimerGroup/TimerDisplay
	fifteen_out = $Container/Content/Calculations/FifteenOut
	seventeen_out = $Container/Content/Calculations/SeventeenOut
	twenty_out = $Container/Content/Calculations/TwentyOut
	twenty_two_out = $Container/Content/Calculations/TwentyTwoOut
	development_out = $Container/Content/Development/DevelopmentOut


func _process(delta: float) -> void:
	if start_btn_status:
		timer += delta
		timer_display.text = _get_time_text(timer)


func _reset_plot() -> void:
	if plot != null:
		graph.remove_plot_item(plot)
	plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
	var pt = Vector2(0, 70)
	plot.add_point(pt)
	data.points.push_back(pt)


func load_log(log_in: RoastLog) -> void:
	reset_all()
	# Reset timer on load
	timer = data.final_roast_time
	start_btn_status = false
	start_btn.text = "Start"
	
	# Load log data
	data = log_in
	name_in.text = data.roast_name
	roast_setting_in.text = data.initial_roaster_heat
	grn_wgt_in.text = str(data.green_wgt)
	rst_wgt_in.text = str(data.roast_wgt)
	date_out.text = data.roast_date
	wgt_loss_out.text = str(data.wgt_loss)
	first_crack_out.text = _get_time_text(data.first_crack_time)
	timer_display.text = _get_time_text(data.final_roast_time)
	development_out.text = str(data.development_percentage)
	general_notes_in.text = data.general_notes
	_calculate_development()
	
	# Set plot points
	event_point_nodes.clear()
	if plot != null:
		graph.remove_all()
	plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
	for pt in data.points:
		plot.add_point(pt)
	for pt in data.event_points:
		plot.add_event_point(_crete_new_event_point_from_data(pt))


func load_compare_graph(log_in: RoastLog) -> void:
	if compare_plot != null:
		graph.remove_plot_item(compare_plot)
	compare_plot = graph.add_plot_item(log_in.roast_name, Color.FIREBRICK, 1.0)
	for pt in log_in.points:
		compare_plot.add_point(pt)
	for pt in log_in.event_points:
		pt.color = Color.FIREBRICK
		pt.label_color = Color.FIREBRICK
		compare_plot.add_event_point(_crete_new_event_point_from_data(pt))


func _calculate_development() -> void:
	fifteen_out.text =  _get_time_text(data.first_crack_time / 0.85)
	seventeen_out.text = _get_time_text(data.first_crack_time / 0.825)
	twenty_out.text = _get_time_text(data.first_crack_time / 0.80)
	twenty_two_out.text = _get_time_text(data.first_crack_time / 0.775)


func _calculate_final_development() -> void:
	data.development_percentage = (data.final_roast_time - data.first_crack_time) / data.final_roast_time * 100.0
	development_out.text = str(data.development_percentage).pad_decimals(2) + "%"


func _crete_new_event_point(pos: Vector2, lbl: String, color: Color, font_color: Color = Color.WHITE) -> GraphPoint:
	var pt_data := GraphPointData.new()
	pt_data.color = color
	pt_data.label = lbl
	pt_data.label_color = font_color
	pt_data.pos = pos
	data.event_points.push_back(pt_data)
	var pt_scn = _crete_new_event_point_from_data(pt_data)
	return pt_scn


func _crete_new_event_point_from_data(pt_data: GraphPointData) -> GraphPoint:
	var pt_scn := _graph_point.instantiate()
	if pt_data.pos.y == 0:
		pt_data.pos.y = 500.0
	pt_scn.position = pt_data.pos
	pt_scn.set_label.call_deferred(pt_data.label, pt_data.label_color)
	pt_scn.set_color.call_deferred(pt_data.color)
	event_point_nodes.push_back(pt_scn)
	return pt_scn


func _get_time_text(time: float) -> String:
	var time_int := roundi(time)
	var minutes := time_int / 60
	var seconds := time_int % 60
	return str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)


func _on_start_btn_pressed() -> void:
	if not start_btn_status: # Timer isn't running yet
		start_btn.text = "Stop"
		start_btn_status = true
	else:
		start_btn.text = "Start"
		start_btn_status = false
		data.final_roast_time = timer
		_calculate_final_development()


func _on_first_crack_btn_pressed() -> void:
	data.first_crack_time = timer
	first_crack_out.text = _get_time_text(data.first_crack_time)
	_calculate_development()
	#first_crack_btn.disabled = true
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading),
		"First Crack: " + _get_time_text(temp_time),
		Color.BURLYWOOD,
		Color.BURLYWOOD
	)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	temp_in.text = ""


func _on_weight_text_changed(_new_text: String) -> void:
	data.green_wgt = float(grn_wgt_in.text)
	data.roast_wgt = float(rst_wgt_in.text)
	if data.green_wgt == 0.0 or data.roast_wgt == 0.0:
		return
	data.wgt_loss = abs(((data.roast_wgt - data.green_wgt) / data.green_wgt) * 100)
	wgt_loss_out.text = str(data.wgt_loss).pad_decimals(2) + "%"


func _on_add_temp_btn_pressed(_text: String) -> void:
	var pt: Vector2
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	if temp_reading == 0.0:
		return # not a number!
	pt = Vector2(temp_time, temp_reading)
	plot.add_point(pt)
	data.points.push_back(pt)
	temp_in.text = ""


func _on_add_note_btn_pressed() -> void:
	var temp_reading := float(temp_in.text)
	var temp_time := timer
	var note := note_in.text
	if note.is_empty():
		return
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading),
		note + " @ " + _get_time_text(temp_time),
		Color.PALE_GREEN,
		Color.PALE_GREEN
	)
	if temp_reading != 0.0:
		data.points.push_back(new_pt.position)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	temp_in.text = ""
	note_in.text = ""


func _on_save_btn_pressed() -> void:
	data.initial_roaster_heat = roast_setting_in.text
	data.roast_name = name_in.text
	data.general_notes = general_notes_in.text
	on_save.emit(data)


func _on_reset_btn_pressed() -> void:
	reset_all()


func _on_menu_btn_pressed() -> void:
	on_menu_click.emit()


func reset_all() -> void:
	start_btn_status = false
	start_btn.text = "Start"
	timer = 0.0
	for pt in event_point_nodes:
		pt.queue_free()
	data = RoastLog.new()
	graph.remove_all()
	_reset_plot()

	name_in.text = ""
	roast_setting_in.text = ""
	grn_wgt_in.text = "100.0"
	rst_wgt_in.text = ""
	temp_in.text = ""
	general_notes_in.text = ""
	
	date_out.text = Time.get_date_string_from_system()
	wgt_loss_out.text = "00.00"
	first_crack_out.text = "00:00"
	timer_display.text = "00:00"
	fifteen_out.text = "00:00"
	seventeen_out.text = "00:00"
	twenty_out.text = "00:00"
	twenty_two_out.text = "00:00"
	development_out.text = "00.00%"
