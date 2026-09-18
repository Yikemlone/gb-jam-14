class_name NPCContext

enum Presence {
	HIDDEN,
	AT_DESK
}

enum Transaction {
	DEPOSIT,
	WITHDRAW
}

enum Wealth {
	POOR,
	AVERAGE,
	RICH
}

const WEALTH_BRACKETS := {
	Wealth.POOR: {"balance_min": -50, "balance_max": 50, "deposit_min": 5, "deposit_max": 25, "withdraw_min": 5, "withdraw_max": 20},
	Wealth.AVERAGE: {"balance_min": 50, "balance_max": 300, "deposit_min": 5, "deposit_max": 100, "withdraw_min": 5, "withdraw_max": 100},
	Wealth.RICH: {"balance_min": 500, "balance_max": 1500, "deposit_min": 100, "deposit_max": 600, "withdraw_min": 50, "withdraw_max": 250},
}


static func get_greeting_options(dialog_set: NPCDialogSet = null) -> Array[String]:
	if dialog_set != null and not dialog_set.greetings.is_empty():
		return dialog_set.greetings
	return DialogLines.GREETINGS


static func get_closing_options(dialog_set: NPCDialogSet = null) -> Array[String]:
	if dialog_set != null and not dialog_set.closings.is_empty():
		return dialog_set.closings
	return DialogLines.CLOSINGS


static func get_request_options(transaction_type: Transaction, dialog_set: NPCDialogSet = null) -> Array[String]:
	match transaction_type:
		Transaction.DEPOSIT:
			if dialog_set != null and not dialog_set.deposit_requests.is_empty():
				return dialog_set.deposit_requests
			return DialogLines.DEPOSIT_REQUESTS
		Transaction.WITHDRAW:
			if dialog_set != null and not dialog_set.withdraw_requests.is_empty():
				return dialog_set.withdraw_requests
			return DialogLines.WITHDRAW_REQUESTS
	return DialogLines.WITHDRAW_REQUESTS
