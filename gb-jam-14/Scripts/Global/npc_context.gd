class_name NPCContext

enum Type {
	HIDDEN,
	DESK
}

enum Context {
	DEPOSIT,
	WITHDRAW
}


static func get_request_options(context: Context) -> Array[String]:
	match context:
		Context.DEPOSIT:
			return DialogLines.DEPOSIT_REQUESTS
		Context.WITHDRAW:
			return DialogLines.WITHDRAW_REQUESTS
	return DialogLines.WITHDRAW_REQUESTS
