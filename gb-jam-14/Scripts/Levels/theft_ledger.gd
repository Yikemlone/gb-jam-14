class_name TheftLedger
extends RefCounted

var stolen_from_customer: int = 0
var stolen_from_box: int = 0
var taken_out: int = 0
var entered_into_box: int = 0

var _world = null
var _npc: Node2D = null
var _settled: bool = false


func setup(world_ref, npc_ref: Node2D) -> void:
	_world = world_ref
	_npc = npc_ref


func record_stolen(source: String, bill_value: int) -> void:
	if source == "customer":
		stolen_from_customer += bill_value
	else:
		stolen_from_box += bill_value
	if _world != null:
		_world.add_stolen(bill_value)
	print("STOLE $%d from %s" % [bill_value, source])


func record_take_out(bill_value: int) -> void:
	taken_out += bill_value
	print("TOOK OUT $%d" % bill_value)


func record_put_in(bill_value: int) -> void:
	entered_into_box += bill_value
	print("PUT IN $%d" % bill_value)


func settle() -> void:
	if _settled:
		return
	_settled = true
	if _world == null or _npc == null:
		return
	# Leftovers stay: deposits only land what was Entered, withdrawals only remove what was taken out.
	if _npc.transaction_type == NPCContext.Transaction.DEPOSIT:
		_world.register_money = maxi(0, _world.register_money + entered_into_box - stolen_from_box)
		_npc.balance += entered_into_box
	else:
		_world.register_money = maxi(0, _world.register_money - taken_out - stolen_from_box)
		_npc.balance -= taken_out
	print("SETTLED entered=$%d taken=$%d stole customer=$%d box=$%d register=$%d" % [entered_into_box, taken_out, stolen_from_customer, stolen_from_box, _world.register_money])
