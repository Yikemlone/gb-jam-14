extends Node2D

@onready var level_slot: Node2D = $Level
@onready var entities: Node2D = $Entities

const TOTAL_DAYS: int = 7
const DAY_SECONDS: float = 60.0
const FIRST_DAY_SHIFT_LENGTH_MINUTES: int = 8 * 60
const DAILY_SHIFT_REDUCTION_MINUTES: int = 60
const MIN_SHIFT_LENGTH_MINUTES: int = 2 * 60

signal time_updated(text: String)

var current_npc: Node2D
var current_level: String = ""
var current_day: int = 1
var register_money: int = 0
var steal_target: int = 0
var weekly_steal_target: int = 0
var stolen_total: int = 0
var stolen_today: int = 0
var customers_served: int = 0
var clock: ShiftClock
var last_verdict: String = ""
var game_over: bool = false
var game_won: bool = false
var shift_active: bool = false

var daily_targets: Array[int] = []

var level_scenes := {
	"day": preload("res://Scenes/Levels/day.tscn"),
	"desk": preload("res://Scenes/Levels/desk.tscn"),
	"game_over": preload("res://Scenes/Levels/game_over.tscn"),
}


func _ready() -> void:
	add_to_group("world")
	clock = ShiftClock.new()
	clock.duration = DAY_SECONDS
	clock.time_left = DAY_SECONDS
	add_child(clock)
	clock.time_updated.connect(_on_clock_time_updated)
	clock.finished.connect(end_day)


func _on_clock_time_updated(text: String) -> void:
	time_updated.emit(text)


func get_shift_minutes(seconds_left: float) -> int:
	return clock.get_shift_minutes(seconds_left)


func get_shift_text(seconds_left: float) -> String:
	return clock.get_shift_text(seconds_left)


func get_shift_end_text() -> String:
	return clock.get_shift_end_text()


# Update clock
func _process(delta: float) -> void:
	if not shift_active or game_over or current_level != "desk":
		return
	clock.tick(delta)


func start_game() -> void:
	entities.create_npcs()
	current_day = 1
	daily_targets.clear()
	# Create stealing targets for each day
	for day in range(1, TOTAL_DAYS + 1):
		var target: int = _steal_target_for_day(day)
		daily_targets.append(target)
		weekly_steal_target += target
	begin_new_day()
	shift_active = true
	load_level("day")


func _steal_target_for_day(day: int) -> int:
	return 25 * day + _rand_step(4)


func _register_money_for_day(day: int) -> int:
	return maxi(100, 800 - day * 60 + _rand_step(8))


func _shift_length_for_day(day: int) -> int:
	return maxi(MIN_SHIFT_LENGTH_MINUTES, FIRST_DAY_SHIFT_LENGTH_MINUTES - (day - 1) * DAILY_SHIFT_REDUCTION_MINUTES)


func _rand_step(steps: int) -> int:
	return randi() % steps * 5


func begin_new_day() -> void:
	# Both amount to steal and cash box are divisible by 5 so we can make the money logic easier for display
	# Ramping up the amount they need to steal
	steal_target = daily_targets[current_day - 1]
	# Reducing the amount in the cash box.
	register_money = _register_money_for_day(current_day)
	stolen_today = 0
	customers_served = 0
	# Ramping difficulty: one fewer hour each day (day 1 ends 5PM ... day 7 ends 11AM).
	clock.shift_length_minutes = _shift_length_for_day(current_day)
	clock.reset()
	current_npc = entities.get_random_npc()
	entities.hide_all_npcs()


func add_stolen(amount: int) -> void:
	stolen_today += amount
	stolen_total += amount


func next_customer() -> void:
	current_npc = entities.get_random_npc(current_npc)
	entities.set_active_npc(current_npc)


func load_level(level_name: String) -> void:
	if not level_scenes.has(level_name):
		push_error("Unknown level: %s" % level_name)
		return
	for child in level_slot.get_children():
		child.queue_free()

	current_level = level_name
	var new_level = level_scenes[level_name].instantiate()

	# Pass world directly so levels never hunt it via group lookup.
	new_level.world = self

	if new_level.has_method("setup"):
		new_level.setup(current_npc)

	new_level.finished.connect(_on_level_finished)
	level_slot.add_child(new_level)


func get_current_npc() -> Node2D:
	return current_npc

# Passed down to other levels so we can have world be the global state tracker
func get_day_state() -> Dictionary:
	return {
		"current_day": current_day,
		"register_money": register_money,
		"steal_target": steal_target,
		"weekly_steal_target": weekly_steal_target,
		"stolen_today": stolen_today,
		"stolen_total": stolen_total,
		"customers_served": customers_served,
		"day_timer": clock.time_left,
		"shift_text": clock.get_shift_text(clock.time_left),
		"shift_end_text": clock.get_shift_end_text(),
		"last_verdict": last_verdict,
		"game_over": game_over,
		"game_won": game_won,
	}


func end_day() -> void:
	entities.hide_all_npcs()
	var shortfall := maxi(0, steal_target - stolen_today)
	last_verdict = "OFF BY $%d" % shortfall

	if current_day >= TOTAL_DAYS:
		game_over = true
		shift_active = false
		game_won = stolen_total >= weekly_steal_target
		load_level("game_over")
	else:
		current_day += 1
		begin_new_day()
		load_level("day")


func _on_level_finished(next_level: String) -> void:
	match next_level:
		"desk":
			entities.set_active_npc(current_npc)
		"next_customer":
			next_customer()
			customers_served += 1
			next_level = "desk"

	load_level(next_level)
