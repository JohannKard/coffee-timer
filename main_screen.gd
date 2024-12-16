extends Control

var start_btn_status := false
var timer := 0.0
var first_crack_time := 0.0
var final_roast_time := 0.0
var roast_wgt := 0.0
var green_wgt := 0.0
var wgt_loss := 0.0
var development_percentage := 0.0
var points: Array[Vector2] = []
var event_points: Array[GraphPoint] = []

var plot: PlotItem = null

var _graph_point := preload("res://graph_point.tscn")

@onready var graph := $Container/Content/SinglePlot/Graph2D

@onready var start_btn := $Container/Content/RoastingTimes/StartBtn
@onready var first_crack_btn := $Container/Content/RoastingTimes/FirstCrackBtn

@onready var name_in := $Container/Content/RoastInfo/NameIn
@onready var grn_wgt_in := $Container/Content/WgtDetails/GreenWeightIn
@onready var rst_wgt_in := $Container/Content/WgtDetails/RoastWeightIn
@onready var temp_in := $Container/Content/RoastingTimes/TimerGroup/TempControls/TempIn

@onready var date_out := $Container/Content/RoastInfo/DateOut
@onready var wgt_loss_out := $Container/Content/RoastResults/WeightLossOut
@onready var first_crack_out := $Container/Content/RoastResults/FirstCrackOut
@onready var timer_display := $Container/Content/RoastingTimes/TimerGroup/TimerDisplay
@onready var fifteen_lbl := $Container/Content/Calculations/FifteenLbl
@onready var seventeen_lbl := $Container/Content/Calculations/SeventeenLbl
@onready var twenty_lbl := $Container/Content/Calculations/TwentyLbl
@onready var twenty_two_lbl := $Container/Content/Calculations/TwentyTwoLbl
@onready var development_out := $Container/Content/Development/DevelopmentOut


func _process(delta: float) -> void:
	if start_btn_status:
		timer += delta
		timer_display.text = _get_time_text(timer)


func _calculate_development() -> void:
	fifteen_lbl.text = "15.0%: " + _get_time_text(first_crack_time + 0.15 * first_crack_time)
	seventeen_lbl.text = "17.5%: " + _get_time_text(first_crack_time + 0.175 * first_crack_time)
	twenty_lbl.text = "20.0%: " + _get_time_text(first_crack_time + 0.20 * first_crack_time)
	twenty_two_lbl.text = "22.5%: " + _get_time_text(first_crack_time + 0.225 * first_crack_time)
	# TODO: These are wrong


func _calculate_final_development() -> void:
	development_percentage = (first_crack_time - final_roast_time) / first_crack_time
	development_out.text = str(development_percentage).pad_decimals(2)
	# crack + x * crack = timer
	# x * crack = timer - crack
	# TODO: this is wrong


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
		final_roast_time = timer
		_calculate_final_development()


func _on_first_crack_btn_pressed() -> void:
	first_crack_time = timer
	_calculate_development()
	#first_crack_btn.disabled = true
	if plot == null:
		plot = graph.add_plot_item("", Color.GREEN, 1.0)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	var new_pt := _crete_new_event_point(
		Vector2(temp_time, temp_reading), "First Crack", Color.BURLYWOOD, Color.BURLYWOOD
	)
	plot.add_event_point(new_pt, temp_reading != 0.0)
	event_points.push_back(new_pt)


func _on_roast_weight_in_text_changed(new_text: String) -> void:
	green_wgt = float(grn_wgt_in.text)
	roast_wgt = float(rst_wgt_in.text)
	wgt_loss = abs(((roast_wgt - green_wgt) / green_wgt) * 100)
	wgt_loss_out.text = str(wgt_loss).pad_decimals(2) + "%"


func _on_add_temp_btn_pressed() -> void:
	var pt: Vector2
	if plot == null:
		plot = graph.add_plot_item("", Color.GREEN, 1.0)
		pt = Vector2(0, 70)
		plot.add_point(pt)
		points.push_back(pt)
	var temp_time := timer
	var temp_reading := float(temp_in.text)
	if temp_reading == 0.0:
		return # not a number!
	pt = Vector2(temp_time, temp_reading)
	plot.add_point(pt)
	points.push_back(pt)
	


func _on_reset_btn_pressed() -> void:
	_reset_all()


func _reset_all() -> void:
	start_btn_status = false
	start_btn.text = "Start"
	timer = 0.0
	first_crack_time = 0.0
	final_roast_time = 0.0
	roast_wgt = 0.0
	green_wgt = 0.0
	wgt_loss = 0.0
	development_percentage = 0.0
	points.clear()
	for pt in event_points:
		pt.queue_free()
	event_points.clear()
	graph.remove_all()
	
	name_in.text = ""
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