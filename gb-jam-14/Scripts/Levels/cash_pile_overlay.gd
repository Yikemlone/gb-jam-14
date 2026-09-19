class_name CashPileOverlay
extends DeskOverlay

# Emitted dynamically via emit_signal() from the CONTEXTS table, which the
# analyzer can't see through — these ignores are load-bearing, not cleanup.
@warning_ignore("unused_signal")
signal stolen(bill_value: int)
@warning_ignore("unused_signal")
signal taken_out(bill_value: int)
@warning_ignore("unused_signal")
signal put_in(bill_value: int)
@warning_ignore("unused_signal")
signal handed_over(bill_value: int)

enum PileContext { BANK_VAULT, BANK_TAKE, TABLE_OFFER, TABLE_HAND }

const BILL_TYPES_AVAILABLE: Array[int] = [50, 20, 10, 5]
const CONTEXTS := {
	PileContext.BANK_VAULT: {"title": "BOX", "hints": [], "primary": ""},
	PileContext.BANK_TAKE: {"title": "BOX", "hints": [], "primary": "taken_out"},
	PileContext.TABLE_OFFER: {"title": "TABLE", "hints": [], "primary": "put_in"},
	PileContext.TABLE_HAND: {"title": "HAND", "hints": [], "primary": "handed_over"},
}
const BOX_CONTEXTS := {
	NPCContext.Transaction.DEPOSIT: PileContext.BANK_VAULT,
	NPCContext.Transaction.WITHDRAW: PileContext.BANK_TAKE,
}

var pile_context: PileContext = PileContext.BANK_VAULT
var bills: Array[int] = []

var _dealt: bool = false
var _pile_buttons: Array[Button] = []
var _pile_stack: VBoxContainer = null
var _pile_header: Label = null


func open() -> void:
	rebuild_ui()
	super()


func focus_first() -> void:
	_focus_preferred(-1)


func ensure_dealt(amount: int) -> void:
	if _dealt:
		return
	_dealt = true
	bills = split_into_bills(maxi(0, amount))


func open_for_box(flow: NPCContext.Transaction, register_money: int) -> void:
	pile_context = BOX_CONTEXTS[flow]
	ensure_dealt(register_money)


func open_for_table(flow: NPCContext.Transaction, request_amount: int) -> void:
	if flow == NPCContext.Transaction.DEPOSIT:
		pile_context = PileContext.TABLE_OFFER
		ensure_dealt(request_amount)
	else:
		pile_context = PileContext.TABLE_HAND


func add_bill(bill_value: int) -> void:
	bills.append(bill_value)
	bills.sort()


func total() -> int:
	var sum: int = 0
	for bill in bills:
		sum += bill
	return sum


func is_empty() -> bool:
	return bills.is_empty()


func was_dealt() -> bool:
	return _dealt


static func split_into_bills(amount: int) -> Array[int]:
	var split: Array[int] = []
	var remaining: int = amount
	while remaining > 0:
		var options := affordable_bills(remaining)
		if options.is_empty():
			split.append(remaining)
			break
		var pick: int = options.pick_random()
		split.append(pick)
		remaining -= pick
	split.sort()
	return split


static func affordable_bills(remaining: int) -> Array[int]:
	var options: Array[int] = []
	for bill in BILL_TYPES_AVAILABLE:
		if bill <= remaining:
			options.append(bill)
	return options


func rebuild_ui() -> void:
	_clear_ui()
	var stack := _build_stack()
	_pile_header = _make_label(_header_text())
	stack.add_child(_pile_header)
	_build_hints(stack)
	_build_pile_row(stack)
	DeskOverlay.chain_vertical(_pile_buttons, back_button)


func _build_stack() -> VBoxContainer:
	var stack := VBoxContainer.new()
	stack.offset_left = 24.0
	stack.offset_top = 22.0
	stack.offset_right = 136.0
	stack.offset_bottom = 100.0
	add_child(stack)
	_pile_stack = stack
	return stack


func _build_hints(stack: VBoxContainer) -> void:
	var hints: Array = CONTEXTS[pile_context]["hints"]
	for hint_text in hints:
		stack.add_child(_make_label(hint_text))


func _build_pile_row(stack: VBoxContainer) -> void:
	var row := HBoxContainer.new()
	stack.add_child(row)
	for bill_value in BILL_TYPES_AVAILABLE:
		if bills.has(bill_value):
			row.add_child(_build_bill_button(bill_value))


func _build_bill_button(bill_value: int) -> Button:
	var bill_button := Button.new()
	bill_button.text = "$%d" % bill_value
	bill_button.custom_minimum_size = Vector2(26, 24)
	bill_button.add_theme_font_size_override("font_size", 8)
	bill_button.set_meta("bill_value", bill_value)
	bill_button.pressed.connect(_handle_bill_action.bind(bill_button, false))
	_pile_buttons.append(bill_button)
	track(bill_button)
	return bill_button


func _input(event: InputEvent) -> void:
	super(event)
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_X:
			steal_focused()
			get_viewport().set_input_as_handled()


func steal_focused() -> void:
	var target := _focused_pile_button()
	if target == null and not _pile_buttons.is_empty():
		target = _pile_buttons[0]
	if target != null:
		_handle_bill_action(target, true)


func _header_text() -> String:
	return "%s: $%d" % [CONTEXTS[pile_context]["title"], total()]


func _make_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 8)
	return label


func _clear_ui() -> void:
	for child in get_children():
		if child is VBoxContainer:
			child.queue_free()
	_pile_stack = null
	_pile_header = null
	_pile_buttons.clear()


func _handle_bill_action(bill_button: Button, steal: bool) -> void:
	if not is_instance_valid(bill_button):
		return
	var bill_value: int = int(bill_button.get_meta("bill_value"))
	if not bills.has(bill_value):
		return
	var signal_name := _signal_for_action(steal)
	if signal_name == "":
		print("Take-outs are for withdrawals")
		return
	var had_focus: bool = bill_button.has_focus()
	var focused_bill_value: int = _focused_bill_value()
	bills.erase(bill_value)
	emit_signal(signal_name, bill_value)
	_sync_after_bill_change(bill_button, bill_value, had_focus, focused_bill_value)


func _signal_for_action(steal: bool) -> String:
	if steal:
		return "stolen"
	return CONTEXTS[pile_context]["primary"]


func _sync_after_bill_change(bill_button: Button, bill_value: int, had_focus: bool, focused_bill_value: int) -> void:
	_sync_bill_button(bill_button, bill_value)
	_sync_header()
	DeskOverlay.chain_vertical(_pile_buttons, back_button)
	if had_focus:
		_focus_preferred(focused_bill_value)


func _sync_bill_button(bill_button: Button, bill_value: int) -> void:
	# Last of its kind gone: drop its button. Otherwise the pile button stays put.
	if bills.has(bill_value):
		return
	_pile_buttons.erase(bill_button)
	bill_button.queue_free()


func _sync_header() -> void:
	if is_instance_valid(_pile_header):
		_pile_header.text = _header_text()
		return
	# Stored header is dead but the arrays are source of truth — rebuild from them.
	push_warning("CashPileOverlay: header ref stale, rebuilding pile UI")
	rebuild_ui()


func _focused_pile_button() -> Button:
	for pile_button in _pile_buttons:
		if is_instance_valid(pile_button) and pile_button.has_focus():
			return pile_button
	return null


func _focused_bill_value() -> int:
	var target := _focused_pile_button()
	if target == null:
		return -1
	return int(target.get_meta("bill_value"))


func _focus_preferred(preferred_bill_value: int = -1) -> void:
	for pile_button in _pile_buttons:
		if int(pile_button.get_meta("bill_value")) == preferred_bill_value:
			pile_button.call_deferred("grab_focus")
			return
	if _pile_buttons.is_empty():
		back_button.call_deferred("grab_focus")
	else:
		_pile_buttons[0].call_deferred("grab_focus")
