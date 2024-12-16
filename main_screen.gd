extends Control

var start_btn_status := false
var timer := 0.0

var plot: PlotItem = null

var _graph_point := preload("res://graph_point.tscn")
var log_res := preload("res://roast_log.gd")

@onready var log: RoastLog = log_res.new()
@onready var graph: Graph2D = $Container/Content/SinglePlot/Graph2D

@onready var start_btn: Button = $Container/Content/RoastingTimes/StartBtn
@onready var first_crack_btn: Button = $Container/Content/RoastingTimes/FirstCrackBtn

@onready var name_in: LineEdit = $Container/Content/RoastInfo/NameIn
@onready var roast_setting_in: LineEdit = $Container/Content/RoastInfo/RoastSettingIn
@onready var grn_wgt_in: LineEdit = $Container/Content/WgtDetails/GreenWeightIn
@onready var rst_wgt_in: LineEdit = $Container/Content/WgtDetails/RoastWeightIn
@onready var temp_in: LineEdit = $Container/Content/GraphControls/TempIn
@onready var note_in: LineEdit = $Container/Content/GraphControls/NoteIn

@onready var date_out: Label = $Container/Content/RoastInfo/DateOut
@onready var wgt_loss_out: Label = $Container/Content/RoastResults/WeightLossOut
@onready var first_crack_out: Label = $Container/Content/RoastResults/FirstCrackOut
@onready var timer_display: Label = $Container/Content/RoastingTimes/TimerGroup/TimerDisplay
@onready var fifteen_lbl: Label = $Container/Content/Calculations/FifteenLbl
@onready var seventeen_lbl: Label = $Container/Content/Calculations/SeventeenLbl
@onready var twenty_lbl: Label = $Container/Content/Calculations/TwentyLbl
@onready var twenty_two_lbl: Label = $Container/Content/Calculations/TwentyTwoLbl
@onready var development_out: Label = $Container/Content/Development/DevelopmentOut


func _process(delta: float) -> void:
	if start_btn_status:
		timer += delta
		timer_display.text = _get_time_text(timer)


func load_log(log_res: RoastLog) -> void:
	log = log_res
	# TODO: regenerate roast details on graph and screen


func _calculate_development() -> void:
	fifteen_lbl.text = "15.0%: " + _get_time_text(log.first_crack_time / 0.85)
	seventeen_lbl.text = "17.5%: " + _get_time_text(log.first_crack_time / 0.825)
	twenty_lbl.text = "20.0%: " + _get_time_text(log.first_crack_time / 0.80)
	twenty_two_lbl.text = "22.5%: " + _get_time_text(log.first_crack_time / 0.775)


func _calculate_final_development() -> void:
	log.development_percentage = (log.final_roast_time - log.first_crack_time) / log.final_roast_time * 100.0
	development_out.text = str(log.development_percentage).pad_decimals(2) + "%"


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
		date_out.text = Time.get_date_string_from_system()
	else:
		start_btn.text = "Start"
		start_btn_status = false
		log.final_roast_time = timer
		_calculate_final_development()


func _on_first_crack_btn_pressed() -> void:
	log.first_crack_time = timer
	first_crack_out.text = _get_time_text(log.first_crack_time)
	_calculate_development()
	#first_crack_btn.disabled = true
	if plot == null:
		plot = graph.add_plot_item("", Color.GREEN, 1.0)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading), "First Crack: " + _get_time_text(temp_time), Color.BURLYWOOD, Color.BURLYWOOD
	)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	log.event_points.push_back(new_pt)
	temp_in.text = ""


func _on_roast_weight_in_text_changed(new_text: String) -> void:
	log.green_wgt = float(grn_wgt_in.text)
	log.roast_wgt = float(rst_wgt_in.text)
	log.wgt_loss = abs(((log.roast_wgt - log.green_wgt) / log.green_wgt) * 100)
	wgt_loss_out.text = str(log.wgt_loss).pad_decimals(2) + "%"


func _on_add_temp_btn_pressed() -> void:
	var pt: Vector2
	if plot == null:
		plot = graph.add_plot_item("", Color.GREEN, 1.0)
		pt = Vector2(0, 70)
		plot.add_point(pt)
		log.points.push_back(pt)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	if temp_reading == 0.0:
		return # not a number!
	pt = Vector2(temp_time, temp_reading)
	plot.add_point(pt)
	log.points.push_back(pt)
	temp_in.text = ""


func _on_add_note_btn_pressed() -> void:
	if plot == null:
		plot = graph.add_plot_item("", Color.GREEN, 1.0)
	var temp_reading := float(temp_in.text)
	var temp_time := timer
	var note := note_in.text
	if note.is_empty():
		return
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading), note + " @ " + _get_time_text(temp_time), Color.PALE_GREEN, Color.PALE_GREEN
	)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	log.event_points.push_back(new_pt)
	temp_in.text = ""
	note_in.text = ""


func _on_reset_btn_pressed() -> void:
	_reset_all()


func _reset_all() -> void:
	start_btn_status = false
	start_btn.text = "Start"
	timer = 0.0
	log.roast_name = ""
	log.initial_roaster_heat = ""
	log.first_crack_time = 0.0
	log.final_roast_time = 0.0
	log.roast_wgt = 0.0
	log.green_wgt = 0.0
	log.wgt_loss = 0.0
	log.development_percentage = 0.0
	log.points.clear()
	for pt in log.event_points:
		pt.queue_free()
	log.event_points.clear()
	graph.remove_all()
	
	name_in.text = ""
	roast_setting_in.text = ""
	grn_wgt_in.text = ""
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
