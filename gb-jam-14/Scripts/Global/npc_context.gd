class_name NPCContext

enum Type {
	HIDDEN,
	DESK
}

enum Context {
	DEPOSIT,
	WITHDRAW
}


static func get_request_options(context: Context, dialog_set: NPCDialogSet = null) -> Array[String]:
	match context:
		Context.DEPOSIT:
			if dialog_set != null and not dialog_set.deposit_requests.is_empty():
				return dialog_set.deposit_requests
			return DialogLines.DEPOSIT_REQUESTS
		Context.WITHDRAW:
			if dialog_set != null and not dialog_set.withdraw_requests.is_empty():
				return dialog_set.withdraw_requests
			return DialogLines.WITHDRAW_REQUESTS
	return DialogLines.WITHDRAW_REQUESTS
