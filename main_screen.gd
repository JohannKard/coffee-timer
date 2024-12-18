class_name MainScreen
extends Control

signal on_save(log_res_ref: RoastLog)
signal on_menu_click()

var data: RoastLog

var start_btn_status := false
var timer := 0.0

var plot: PlotItem = null

var _graph_point := preload("res://graph_point.tscn")

@onready var graph: Graph2D = $Container/Content/SinglePlot/Graph2D

@onready var start_btn: Button = $Container/Content/RoastingTimes/StartBtn
@onready var first_crack_btn: Button = $Container/Content/RoastingTimes/FirstCrackBtn

@onready var name_in: LineEdit = $Container/Content/RoastInfo/NameIn
@onready var roast_setting_in: LineEdit = $Container/Content/RoastInfo/RoastSettingIn
@onready var grn_wgt_in: LineEdit = $Container/Content/WgtDetails/GreenWeightIn
@onready var rst_wgt_in: LineEdit = $Container/Content/WgtDetails/RoastWeightIn
@onready var temp_in: LineEdit = $Container/Content/GraphControls/TempIn
@onready var note_in: LineEdit = $Container/Content/GraphControls/NoteIn
@onready var general_notes_in: TextEdit = $Container/Content/GenNoteIn

@onready var date_out: Label = $Container/Content/RoastInfo/DateOut
@onready var wgt_loss_out: Label = $Container/Content/RoastResults/WeightLossOut
@onready var first_crack_out: Label = $Container/Content/RoastResults/FirstCrackOut
@onready var timer_display: Label = $Container/Content/RoastingTimes/TimerGroup/TimerDisplay
@onready var fifteen_lbl: Label = $Container/Content/Calculations/FifteenLbl
@onready var seventeen_lbl: Label = $Container/Content/Calculations/SeventeenLbl
@onready var twenty_lbl: Label = $Container/Content/Calculations/TwentyLbl
@onready var twenty_two_lbl: Label = $Container/Content/Calculations/TwentyTwoLbl
@onready var development_out: Label = $Container/Content/Development/DevelopmentOut


func _ready() -> void:
	data = RoastLog.new()
	grn_wgt_in.text_changed.connect(_on_weight_text_changed)
	rst_wgt_in.text_changed.connect(_on_weight_text_changed)


func _process(delta: float) -> void:
	if start_btn_status:
		timer += delta
		timer_display.text = _get_time_text(timer)


func load_log(log_in: RoastLog) -> void:
	data = log_in
	name_in.text = data.roast_name
	roast_setting_in.text = data.initial_roaster_heat
	grn_wgt_in.text = str(data.green_wgt)
	rst_wgt_in.text = str(data.roast_wgt)
	date_out.text = data.roast_date
	wgt_loss_out.text = str(data.wgt_loss)
	first_crack_out.text = str(data.first_crack_time)
	timer_display.text = str(data.final_roast_time)
	development_out.text = str(data.development_percentage)
	general_notes_in.text = data.general_notes
	_calculate_development()
	if plot == null:
		plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
	for pt in data.points:
		plot.add_point(pt)
	for pt in data.event_points:
		plot.add_event_point(pt)
		# TODO: fix this since it can't save node info, needs to be raw data to reinit


func _calculate_development() -> void:
	fifteen_lbl.text = "15.0%: " + _get_time_text(data.first_crack_time / 0.85)
	seventeen_lbl.text = "17.5%: " + _get_time_text(data.first_crack_time / 0.825)
	twenty_lbl.text = "20.0%: " + _get_time_text(data.first_crack_time / 0.80)
	twenty_two_lbl.text = "22.5%: " + _get_time_text(data.first_crack_time / 0.775)


func _calculate_final_development() -> void:
	data.development_percentage = (data.final_roast_time - data.first_crack_time) / data.final_roast_time * 100.0
	development_out.text = str(data.development_percentage).pad_decimals(2) + "%"


func _crete_new_event_point(pos: Vector2, lbl: String, color: Color, font_color: Color = Color.WHITE) -> GraphPoint:
	var pt_scn := _graph_point.instantiate()
	if pos.y == 0:
		pos.y = 500.0
	pt_scn.position = pos
	pt_scn.set_label.call_deferred(lbl, font_color)
	pt_scn.set_color.call_deferred(color)
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
		data.roast_date = Time.get_date_string_from_system()
		date_out.text = data.roast_date
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
	if plot == null:
		plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading),
		"First Crack: " + _get_time_text(temp_time),
		Color.BURLYWOOD,
		Color.BURLYWOOD
	)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	data.event_points.push_back(new_pt)
	temp_in.text = ""


func _on_weight_text_changed(_new_text: String) -> void:
	data.green_wgt = float(grn_wgt_in.text)
	data.roast_wgt = float(rst_wgt_in.text)
	if data.green_wgt == 0.0 or data.roast_wgt == 0.0:
		return
	data.wgt_loss = abs(((data.roast_wgt - data.green_wgt) / data.green_wgt) * 100)
	wgt_loss_out.text = str(data.wgt_loss).pad_decimals(2) + "%"


func _on_add_temp_btn_pressed() -> void:
	var pt: Vector2
	if plot == null:
		plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
		pt = Vector2(0, 70)
		plot.add_point(pt)
		data.points.push_back(pt)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	if temp_reading == 0.0:
		return # not a number!
	pt = Vector2(temp_time, temp_reading)
	plot.add_point(pt)
	data.points.push_back(pt)
	temp_in.text = ""


func _on_add_note_btn_pressed() -> void:
	if plot == null:
		plot = graph.add_plot_item("Roast 1", Color.GREEN, 1.0)
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
	data.event_points.push_back(new_pt)
	temp_in.text = ""
	note_in.text = ""


func _on_save_btn_pressed() -> void:
	data.roast_name = name_in.text
	data.general_notes = general_notes_in.text
	on_save.emit(data)


func _on_reset_btn_pressed() -> void:
	_reset_all()


func _on_menu_btn_pressed() -> void:
	on_menu_click.emit()


func _reset_all() -> void:
	start_btn_status = false
	start_btn.text = "Start"
	timer = 0.0
	for pt in data.event_points:
		pt.queue_free()
	data = RoastLog.new()
	graph.remove_all()

	name_in.text = ""
	roast_setting_in.text = ""
	grn_wgt_in.text = "100.0"
	rst_wgt_in.text = ""
	temp_in.text = ""

	date_out.text = "2001-01-01"
	wgt_loss_out.text = "00.00"
	first_crack_out.text = "00:00"
	timer_display.text = "00.00"
	fifteen_lbl.text = "00.00"
	seventeen_lbl.text = "00.00"
	twenty_lbl.text = "00.00"
	twenty_two_lbl.text = "00.00"
	development_out.text = "00.00"
