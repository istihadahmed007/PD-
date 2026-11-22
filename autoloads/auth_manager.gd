# ==============================================================================
# AUTH MANAGER (AUTOLOAD)
# Project: Bangladesh Online Multiplayer Game (DTA: Dhaka Theft Auto)
# Purpose: Manages user login, registration, persistent JWT auth token,
#          and player profile synchronization with the live PostgreSQL backend.
# ==============================================================================
extends Node

signal login_succeeded(user_data: Dictionary)
signal login_failed(error_message: String)
signal register_succeeded(user_data: Dictionary)
signal register_failed(error_message: String)
signal profile_loaded(profile_data: Dictionary)
signal auth_state_changed(is_logged_in: bool)

const DEFAULT_API_BASE_URL: String = "https://bc.vartualtutor.com/api"
const LOCAL_API_BASE_URL: String = "http://127.0.0.1:3000/api"
const SESSION_CACHE_PATH: String = "user://dta_session.json"

var api_base_url: String = DEFAULT_API_BASE_URL
var is_authenticated: bool = false
var auth_token: String = ""
var current_user: Dictionary = {}
var current_profile: Dictionary = {}

var _auth_http: HTTPRequest = null
var _profile_http: HTTPRequest = null
var _pending_action: String = ""


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	_auth_http = HTTPRequest.new()
	_auth_http.name = "AuthHTTPRequest"
	_auth_http.timeout = 10.0
	_auth_http.request_completed.connect(_on_auth_request_completed)
	add_child(_auth_http)
	
	_profile_http = HTTPRequest.new()
	_profile_http.name = "ProfileHTTPRequest"
	_profile_http.timeout = 10.0
	_profile_http.request_completed.connect(_on_profile_request_completed)
	add_child(_profile_http)
	
	_load_cached_session()


func login(identifier: String, password: String) -> void:
	var clean_login := identifier.strip_edges()
	if clean_login.is_empty() or password.is_empty():
		login_failed.emit("Username/Email and Password cannot be empty.")
		return
	
	_pending_action = "login"
	var url := "%s/auth/login" % api_base_url
	var payload := JSON.stringify({
		"login": clean_login,
		"password": password
	})
	var headers := PackedStringArray(["Content-Type: application/json"])
	
	var err := _auth_http.request(url, headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		login_failed.emit("Failed to initiate login request (Error %d)" % err)


func register(username: String, email: String, password: String) -> void:
	var clean_user := username.strip_edges()
	var clean_email := email.strip_edges()
	if clean_user.length() < 3:
		register_failed.emit("Username must be at least 3 characters.")
		return
	if clean_email.is_empty() or not clean_email.contains("@"):
		register_failed.emit("Valid email address required.")
		return
	if password.length() < 6:
		register_failed.emit("Password must be at least 6 characters.")
		return
	
	_pending_action = "register"
	var url := "%s/auth/register" % api_base_url
	var payload := JSON.stringify({
		"username": clean_user,
		"email": clean_email,
		"password": password
	})
	var headers := PackedStringArray(["Content-Type: application/json"])
	
	var err := _auth_http.request(url, headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		register_failed.emit("Failed to initiate registration (Error %d)" % err)


func fetch_profile() -> void:
	if auth_token.is_empty():
		return
	
	var url := "%s/player/profile" % api_base_url
	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % auth_token
	])
	
	var err := _profile_http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		print("[AUTH] Could not request profile sync: %d" % err)


func logout() -> void:
	is_authenticated = false
	auth_token = ""
	current_user.clear()
	current_profile.clear()
	_clear_cached_session()
	auth_state_changed.emit(false)
	print("[AUTH] User logged out.")


# ==============================================================================
# HTTP RESPONSE HANDLERS
# ==============================================================================
func _on_auth_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_text := body.get_string_from_utf8()
	var parse_result = JSON.parse_string(body_text)
	var resp_dict: Dictionary = parse_result if typeof(parse_result) == TYPE_DICTIONARY else {}
	
	if response_code in [200, 201]:
		auth_token = resp_dict.get("token", "")
		current_user = resp_dict.get("user", {})
		is_authenticated = not auth_token.is_empty()
		
		# Update NetworkManager's default nickname to authenticated username
		if current_user.has("username"):
			NetworkManager.local_nickname = str(current_user["username"])
		
		_save_cached_session()
		auth_state_changed.emit(true)
		
		if _pending_action == "register":
			register_succeeded.emit(current_user)
		else:
			login_succeeded.emit(current_user)
		
		# Automatically fetch persistent player profile
		fetch_profile()
	else:
		var error_msg := str(resp_dict.get("error", "Server responded with code %d" % response_code))
		if _pending_action == "register":
			register_failed.emit(error_msg)
		else:
			login_failed.emit(error_msg)
	
	_pending_action = ""


func _on_profile_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		print("[AUTH] Profile sync returned status %d" % response_code)
		return
	
	var body_text := body.get_string_from_utf8()
	var parse_result = JSON.parse_string(body_text)
	if typeof(parse_result) == TYPE_DICTIONARY:
		current_profile = parse_result
		
		# Sync wallet & bank with GameManager if present
		if current_profile.has("profile"):
			var p_data: Dictionary = current_profile["profile"]
			if p_data.has("cash_wallet_bdt"):
				GameManager.wallet_bdt = int(p_data["cash_wallet_bdt"])
			if p_data.has("bank_balance_bdt"):
				GameManager.bank_bdt = int(p_data["bank_balance_bdt"])
			if p_data.has("wanted_level"):
				GameManager.wanted_stars = int(p_data["wanted_level"])
		
		profile_loaded.emit(current_profile)
		print("[AUTH] Player profile synchronized successfully.")


# ==============================================================================
# LOCAL CACHE MANAGEMENT
# ==============================================================================
func _save_cached_session() -> void:
	var f := FileAccess.open(SESSION_CACHE_PATH, FileAccess.WRITE)
	if f:
		var data := {
			"token": auth_token,
			"user": current_user
		}
		f.store_string(JSON.stringify(data))
		f.close()


func _load_cached_session() -> void:
	if not FileAccess.file_exists(SESSION_CACHE_PATH):
		return
	
	var f := FileAccess.open(SESSION_CACHE_PATH, FileAccess.READ)
	if not f:
		return
	var text := f.get_as_text()
	f.close()
	
	var parsed = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		var dict: Dictionary = parsed
		auth_token = dict.get("token", "")
		current_user = dict.get("user", {})
		if not auth_token.is_empty():
			is_authenticated = true
			if current_user.has("username"):
				NetworkManager.local_nickname = str(current_user["username"])
			auth_state_changed.emit(true)
			fetch_profile()


func _clear_cached_session() -> void:
	if FileAccess.file_exists(SESSION_CACHE_PATH):
		DirAccess.remove_absolute(SESSION_CACHE_PATH)
