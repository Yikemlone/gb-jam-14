class_name PassBookOverlay
extends InfoOverlay

@onready var name_label: Label = $NameLabel
@onready var balance_label: Label = $BalanceLabel


func show_customer(customer_name: String, balance: int) -> void:
	name_label.text = customer_name
	balance_label.text = "BAL: $%d" % balance
