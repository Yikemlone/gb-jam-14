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

const BILL_TYPES_AVAILABLE: Array[int] = [100, 50, 20, 10, 5]
const BILL_TEXTURES := {
	100: preload("res://Assets/Concept art/hundred.png"),
	50: preload("res://Assets/Concept art/fiddy.png"),
	20: preload("res://Assets/Concept art/twenty.png"),
	10: preload("res://Assets/Concept art/tenner.png"),
	5: preload("res://Assets/Concept art/fiver.png"),
}
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
const SLOT_SIZE := Vector2(32, 32)
const STACK_OFFSET := Vector2(1.0, 0.0)
const LAYOUT_LEFT := 18.0
const LAYOUT_TOP := 22.0
const LAYOUT_RIGHT := 142.0
const LAYOUT_BOTTOM := 104.0
const LAYOUT_SEPARATION := 2
const ROW_SEPARATION := 4
const FIRST_ROW_COUNT := 3
const LABEL_FONT_SIZE := 8
const NO_BILL := -1

var pile_context: PileContext = PileContext.BANK_VAULT
var bills: Array[int] = []

var _dealt: bool = false
var _pile_buttons: Array[TextureButton] = []
var _slot_buttons := {}
var _pile_layout: VBoxContainer = null
var _pile_rows: Array[HBoxContainer] = []
var _pile_header: Label = null


func open() -> void:
	rebuild_ui()
	super()


func focus_first() -> void:
	_focus_preferred(NO_BILL)


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
	_reenable_slot(bill_value)


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
	var clamped: int = maxi(0, amount)
	var step: int = BILL_TYPES_AVAILABLE.back()
	var remaining: int = clamped - posmod(clamped, step)
	while remaining > 0:
		var pick: int = affordable_bills(remaining).pick_random()
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
	var layout := _build_layout()
	_pile_header = _make_label(_header_text())
	layout.add_child(_pile_header)
	_build_pile_rows(layout)
	DeskOverlay.chain_vertical(_pile_buttons, back_button)


func _build_layout() -> VBoxContainer:
	var layout := VBoxContainer.new()
	layout.offset_left = LAYOUT_LEFT
	layout.offset_top = LAYOUT_TOP
	layout.offset_right = LAYOUT_RIGHT
	layout.offset_bottom = LAYOUT_BOTTOM
	add_child(layout)
	_pile_layout = layout
	return layout


func _build_pile_rows(layout: VBoxContainer) -> void:
	layout.add_theme_constant_override("separation", LAYOUT_SEPARATION)
	_pile_rows.append(_make_pile_row(layout, BILL_TYPES_AVAILABLE.slice(0, FIRST_ROW_COUNT)))
	_pile_rows.append(_make_pile_row(layout, BILL_TYPES_AVAILABLE.slice(FIRST_ROW_COUNT)))


func _make_pile_row(layout: VBoxContainer, values: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", ROW_SEPARATION)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(row)
	for bill_value in values:
		row.add_child(_build_bill_slot(bill_value))
	return row


func _build_bill_slot(bill_value: int) -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = SLOT_SIZE
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.set_meta("bill_value", bill_value)
	var bill_button := _make_bill_button(bill_value)
	slot.add_child(bill_button)
	_slot_buttons[bill_value] = bill_button
	track(bill_button)
	var active := bills.has(bill_value)
	_set_slot_active(bill_button, active)
	if active:
		_insert_active_button(bill_button)
	_refresh_stack_depth(bill_button, bill_value)
	return slot


func _make_bill_button(bill_value: int) -> TextureButton:
	var bill_button := TextureButton.new()
	bill_button.texture_normal = BILL_TEXTURES[bill_value]
	bill_button.ignore_texture_size = true
	bill_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	bill_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	bill_button.set_meta("bill_value", bill_value)
	bill_button.pressed.connect(_handle_bill_action.bind(bill_button, false))
	return bill_button


func _refresh_stack_depth(bill_button: TextureButton, bill_value: int) -> void:
	var slot := bill_button.get_parent()
	if slot == null:
		return
	var layers := _slot_layers(slot)
	var want: int = maxi(0, bills.count(bill_value) - 1)
	while layers.size() < want:
		var under := _make_under_layer(bill_value)
		slot.add_child(under)
		slot.move_child(under, layers.size())
		layers.append(under)
	while layers.size() > want:
		var extra: TextureRect = layers.pop_back()
		slot.remove_child(extra)
		extra.queue_free()
	for i in layers.size():
		layers[i].position = STACK_OFFSET * float(i + 1)


func _slot_layers(slot: Node) -> Array[TextureRect]:
	var layers: Array[TextureRect] = []
	for child in slot.get_children():
		if child is TextureRect and child.has_meta("under_layer"):
			layers.append(child as TextureRect)
	return layers


func _make_under_layer(bill_value: int) -> TextureRect:
	var under := TextureRect.new()
	under.texture = BILL_TEXTURES[bill_value]
	under.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	under.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	under.mouse_filter = Control.MOUSE_FILTER_IGNORE
	under.size = SLOT_SIZE
	under.set_meta("under_layer", true)
	return under


func _set_slot_active(bill_button: TextureButton, active: bool) -> void:
	bill_button.disabled = not active
	bill_button.focus_mode = Control.FOCUS_ALL if active else Control.FOCUS_NONE
	bill_button.mouse_filter = Control.MOUSE_FILTER_STOP if active else Control.MOUSE_FILTER_IGNORE
	if not active and bill_button.has_focus():
		bill_button.release_focus()
	var slot := bill_button.get_parent() as Control
	if is_instance_valid(slot):
		slot.modulate.a = 1.0 if active else 0.0


func _insert_active_button(bill_button: TextureButton) -> void:
	if _pile_buttons.has(bill_button):
		return
	var slot_index: int = BILL_TYPES_AVAILABLE.find(int(bill_button.get_meta("bill_value")))
	for i in _pile_buttons.size():
		var other_index: int = BILL_TYPES_AVAILABLE.find(int(_pile_buttons[i].get_meta("bill_value")))
		if slot_index < other_index:
			_pile_buttons.insert(i, bill_button)
			return
	_pile_buttons.append(bill_button)


func _find_bill_button(bill_value: int) -> TextureButton:
	return _slot_buttons.get(bill_value) as TextureButton


func _reenable_slot(bill_value: int) -> void:
	var bill_button := _find_bill_button(bill_value)
	if bill_button == null:
		return
	_set_slot_active(bill_button, true)
	_insert_active_button(bill_button)
	_refresh_stack_depth(bill_button, bill_value)
	if not _pile_rows.is_empty():
		DeskOverlay.chain_vertical(_pile_buttons, back_button)


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
	label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	return label


func _clear_ui() -> void:
	for child in get_children():
		if child is VBoxContainer:
			child.queue_free()
	_pile_layout = null
	_pile_rows.clear()
	_pile_header = null
	_pile_buttons.clear()
	_slot_buttons.clear()


func _handle_bill_action(bill_button: TextureButton, steal: bool) -> void:
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
	_resync_pile_ui(bill_button, bill_value, had_focus, focused_bill_value)


func _signal_for_action(steal: bool) -> String:
	if steal:
		return "stolen"
	return CONTEXTS[pile_context]["primary"]


func _resync_pile_ui(bill_button: TextureButton, bill_value: int, had_focus: bool, focused_bill_value: int) -> void:
	_sync_slot_stack(bill_button, bill_value)
	_sync_header()
	DeskOverlay.chain_vertical(_pile_buttons, back_button)
	if had_focus:
		_focus_preferred(focused_bill_value)


func _sync_slot_stack(bill_button: TextureButton, bill_value: int) -> void:
	if bills.has(bill_value):
		_refresh_stack_depth(bill_button, bill_value)
		return
	_pile_buttons.erase(bill_button)
	_set_slot_active(bill_button, false)


func _sync_header() -> void:
	if is_instance_valid(_pile_header):
		_pile_header.text = _header_text()
		return
	push_warning("CashPileOverlay: header ref stale, rebuilding pile UI")
	rebuild_ui()


func _focused_pile_button() -> TextureButton:
	for pile_button in _pile_buttons:
		if is_instance_valid(pile_button) and pile_button.has_focus():
			return pile_button
	return null


func _focused_bill_value() -> int:
	var target := _focused_pile_button()
	if target == null:
		return NO_BILL
	return int(target.get_meta("bill_value"))


func _focus_preferred(preferred_bill_value: int = NO_BILL) -> void:
	for pile_button in _pile_buttons:
		if int(pile_button.get_meta("bill_value")) == preferred_bill_value:
			pile_button.call_deferred("grab_focus")
			return
	if _pile_buttons.is_empty():
		back_button.call_deferred("grab_focus")
	else:
		_pile_buttons[0].call_deferred("grab_focus")
