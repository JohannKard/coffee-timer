extends MainScreen

func _set_node_accessors() -> void:
	graph = $Container/Content/SinglePlot/Graph2D
	start_btn = $Container/Content/HBoxContainer/RoastingTimes/StartBtn
	add_temp_btn = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/GraphControls/AddTempBtn
	first_crack_btn = $Container/Content/HBoxContainer/RoastingTimes/FirstCrackBtn
	name_in = $Container/Content/TopBar/AppDetails/NameIn
	roast_setting_in = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/HBoxContainer/RoastSettingIn
	grn_wgt_in = $Container/Content/HBoxContainer/VBoxContainer/WgtDetails/GreenWeightIn
	rst_wgt_in = $Container/Content/HBoxContainer/VBoxContainer/WgtDetails2/RoastWeightIn
	temp_in = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/GraphControls/TempIn
	note_in = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/GraphControls/NoteIn
	general_notes_in = $Container/Content/GenNoteIn
	date_out = $Container/Content/TopBar/AppDetails/DateOut
	wgt_loss_out = $Container/Content/HBoxContainer/VBoxContainer/RoastResults/WeightLossOut
	first_crack_out = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/HBoxContainer/FirstCrackOut
	timer_display = $Container/Content/HBoxContainer/RoastingTimes/TimerGroup/TimerDisplay
	fifteen_out = $Container/Content/HBoxContainer/VBoxContainer2/Calculations/HBoxContainer/FifteenOut
	seventeen_out = $Container/Content/HBoxContainer/VBoxContainer2/Calculations/HBoxContainer/SeventeenOut
	twenty_out = $Container/Content/HBoxContainer/VBoxContainer2/Calculations/HBoxContainer2/TwentyOut
	twenty_two_out = $Container/Content/HBoxContainer/VBoxContainer2/Calculations/HBoxContainer2/TwentyTwoOut
	development_out = $Container/Content/HBoxContainer/VBoxContainer2/Calculations/Development/DevelopmentOut
