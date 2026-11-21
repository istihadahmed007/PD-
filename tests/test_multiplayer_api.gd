extends SceneTree

func _init() -> void:
	print("--- MULTIPLAYER API VALIDATION TEST ---")
	
	# Test 1: ENetMultiplayerPeer
	var server_peer := ENetMultiplayerPeer.new()
	var err := server_peer.create_server(7779, 4)
	assert(err == OK, "Server creation failed with code: %d" % err)
	print("[PASS] ENetMultiplayerPeer create_server on port 7779: OK")
	server_peer.close()
	
	# Test 2: SceneReplicationConfig
	var rep_config := SceneReplicationConfig.new()
	rep_config.add_property(NodePath(".:sync_position"))
	rep_config.property_set_replication_mode(NodePath(".:sync_position"), SceneReplicationConfig.REPLICATION_MODE_ALWAYS)
	rep_config.property_set_spawn(NodePath(".:sync_position"), true)
	print("[PASS] SceneReplicationConfig created and properties configured: OK")
	
	print("--- ALL MULTIPLAYER API TESTS PASSED SUCCESSFULLY ---")
	quit(0)
