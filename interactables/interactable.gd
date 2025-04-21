extends Area2D

signal interacted()

@rpc("any_peer", "call_local", "reliable")
func interact() -> void:
	if multiplayer.is_server():
		interacted.emit()
