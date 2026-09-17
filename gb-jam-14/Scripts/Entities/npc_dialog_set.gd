class_name NPCDialogSet
extends Resource
## Per-character dialog pools. Any empty list falls back to the shared DialogLines pools.
@export var greetings: Array[String] = []
@export var deposit_requests: Array[String] = []
@export var withdraw_requests: Array[String] = []
@export var closings: Array[String] = []
