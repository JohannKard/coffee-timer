class_name RoastLog
extends Resource

@export var roast_name := ""
@export var roast_date := ""
@export var initial_roaster_heat := ""
@export var first_crack_time := 0.0
@export var final_roast_time := 0.0
@export var roast_wgt := 0.0
@export var green_wgt := 100.0
@export var wgt_loss := 0.0
@export var development_percentage := 0.0
@export var points: Array[Vector2] = []
@export var event_points: Array[GraphPointData] = [] #Type is GraphPoint (but can't export it)
@export var general_notes := ""
