extends Node2D

signal finished(next_level: String)

@onready var dialog_manager: CanvasLayer = $DialogManager
@onready var timer_label: Label = $TimerLabel
@onready var hand_icon: HandIcon = $HandIcon
@onready var cash_box_button: TextureButton = $Buttons/CashBoxButton
@onready var customer_book_button: TextureButton = $Buttons/CustomerBookButton
@onready var bank_statement_button: TextureButton = $Buttons/BankStatementButton
@onready var cash_button: TextureButton = $Buttons/CashButton
@onready var bell_button: TextureButton = $Buttons/BellButton
@onready var cash_box_overlay: CashPileOverlay = $CashBox
@onready var pass_book_overlay: PassBookOverlay = $PassBook
@onready var bank_statement_overlay: InfoOverlay = $BankStatement
@onready var cash_overlay: CashPileOverlay = $Cash

const SMALL_CASH_TEXTURE = preload("res://Assets/Concept art/bitta cash bitta change.png")
const LARGE_CASH_TEXTURE = preload("res://Assets/Concept art/wad_o_cash.png")
const LARGE_DEPOSIT_THRESHOLD: int = 200

var npc: Node2D
var world
var ledger := TheftLedger.new()
var _dialog_started: bool = false
var _invoking_button: TextureButton = null

var buttons: Array[TextureButton] = []
var overlays: Array[DeskOverlay] = []


func setup(npc_instance: Node2D) -> void:
	npc = npc_instance
	ledger.setup(world, npc)


func _ready() -> void:
	_collect_controls()
	_init_clock()
	_set_buttons_locked(true)
	_connect_hand_icon_tracking()
	_connect_overlay_buttons()
	_connect_overlay_signals()
	_start_customer_interaction()


func _collect_controls() -> void:
	buttons = [
		bell_button,
		cash_box_button,
		bank_statement_button,
		cash_button,
		customer_book_button
	]
	overlays = [
		cash_box_overlay,
		pass_book_overlay,
		bank_statement_overlay,
		cash_overlay
	]


func _init_clock() -> void:
	if world:
		timer_label.text = world.get_shift_text(world.clock.time_left)
		world.time_updated.connect(_on_time_updated)


func _set_buttons_locked(locked: bool) -> void:
	for button in buttons:
		button.disabled = locked


func _connect_hand_icon_tracking() -> void:
	for button in buttons:
		hand_icon.track(button)
	for overlay in overlays:
		overlay.control_focused.connect(hand_icon.show_at)
		overlay.control_resized.connect(hand_icon.follow)


func _connect_overlay_buttons() -> void:
	cash_box_button.pressed.connect(_show_cash_box)
	customer_book_button.pressed.connect(_show_pass_book)
	bank_statement_button.pressed.connect(_show_bank_statement)
	cash_button.pressed.connect(_show_cash)
	dialog_manager.dialog_complete.connect(_on_dialog_complete)


func _connect_overlay_signals() -> void:
	cash_box_overlay.stolen.connect(_on_stolen.bind("box"))
	cash_box_overlay.taken_out.connect(_on_box_take_out)
	cash_overlay.stolen.connect(_on_stolen.bind("customer"))
	cash_overlay.put_in.connect(_on_customer_put_in)
	cash_overlay.handed_over.connect(_on_customer_handed_over)
	for overlay in overlays:
		overlay.closed.connect(_on_overlay_closed)


func _start_customer_interaction() -> void:
	_rebuild_visible_button_focus_order()
	call_deferred("_start_dialog")


func _on_time_updated(text: String) -> void:
	timer_label.text = text


# Focus neighbors are dumb pointers: a hidden button in the chain traps arrow-key focus.
# Rebuild from visible buttons on every visibility change (dialog, gating, overlay close).
func _rebuild_visible_button_focus_order() -> void:
	var previous: TextureButton = null
	for button in buttons:
		if not button.visible:
			continue
		button.focus_neighbor_top = previous.get_path() if previous != null else NodePath("")
		if previous != null:
			previous.focus_neighbor_bottom = button.get_path()
		previous = button
	if previous != null:
		previous.focus_neighbor_bottom = NodePath("")


func _start_dialog() -> void:
	if _dialog_started:
		return
	_dialog_started = true

	if npc == null:
		push_error("Desk started without an NPC.")
		dialog_manager.start_dialog(["..."])
		return

	dialog_manager.start_dialog(npc.dialogue, npc.sound_effect)


func _on_dialog_complete() -> void:
	_set_buttons_locked(false)
	_update_cash_button()
	_rebuild_visible_button_focus_order()
	cash_box_button.call_deferred("grab_focus")


func _update_cash_button() -> void:
	if npc == null:
		cash_button.visible = false
		return
	_update_cash_texture()
	_update_cash_visibility()


func _update_cash_texture() -> void:
	if npc.transaction_amount > LARGE_DEPOSIT_THRESHOLD:
		cash_button.texture_normal = LARGE_CASH_TEXTURE
	else:
		cash_button.texture_normal = SMALL_CASH_TEXTURE


func _update_cash_visibility() -> void:
	# Deposit cash sits on the table from the start, withdraw cash only exists once taken from the box.
	if npc.transaction_type == NPCContext.Transaction.DEPOSIT:
		cash_button.visible = not cash_overlay.was_dealt() or not cash_overlay.is_empty()
	else:
		cash_button.visible = ledger.taken_out > 0 and not cash_overlay.is_empty()


func _show_cash_box() -> void:
	var flow := NPCContext.Transaction.DEPOSIT
	if npc != null:
		flow = npc.transaction_type
	var register := 0
	if world != null:
		register = world.register_money
	cash_box_overlay.open_for_box(flow, register)
	_show_overlay(cash_box_overlay, cash_box_button)


func _show_pass_book() -> void:
	if npc != null:
		pass_book_overlay.show_customer(npc.npc_name, npc.balance)
	_show_overlay(pass_book_overlay, customer_book_button)


func _show_bank_statement() -> void:
	bank_statement_overlay.populate()
	_show_overlay(bank_statement_overlay, bank_statement_button)


func _show_cash() -> void:
	if npc != null:
		cash_overlay.open_for_table(npc.transaction_type, npc.transaction_amount)
	_show_overlay(cash_overlay, cash_button)


func _show_overlay(active_overlay: DeskOverlay, invoking_button: TextureButton) -> void:
	for overlay in overlays:
		overlay.visible = overlay == active_overlay
	_invoking_button = invoking_button
	active_overlay.open()


func _on_overlay_closed(overlay: DeskOverlay) -> void:
	overlay.close()
	_refresh_cash_gating()
	_refocus_desk()


func _refocus_desk() -> void:
	# The cash button may have hidden itself, fall back to the passbook.
	if _invoking_button != null and is_instance_valid(_invoking_button) and _invoking_button.visible:
		_invoking_button.call_deferred("grab_focus")
	else:
		customer_book_button.call_deferred("grab_focus")


func _on_stolen(bill_value: int, source: String) -> void:
	ledger.record_stolen(source, bill_value)
	_refresh_cash_gating()


func _on_box_take_out(bill_value: int) -> void:
	ledger.record_take_out(bill_value)
	cash_overlay.add_bill(bill_value)
	_refresh_cash_gating()


func _on_customer_put_in(bill_value: int) -> void:
	ledger.record_put_in(bill_value)
	_refresh_cash_gating()


func _on_customer_handed_over(bill_value: int) -> void:
	print("HANDED OVER $%d" % bill_value)
	_refresh_cash_gating()


func _refresh_cash_gating() -> void:
	_update_cash_button()
	_rebuild_visible_button_focus_order()


func _on_bell_button_pressed() -> void:
	print("BELL PRESSED")
	ledger.settle()
	finished.emit("next_customer")
