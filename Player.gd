extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@export var gravity = 200.0
@export var walk_speed = 200
@export var jump_speed = -200
@export var max_jumps = 2
@export var dash_speed = 600  # Kecepatan dash
@export var dash_duration = 0.3  # Durasi dash (dalam detik)

var jump_count = 0
var is_dashing = false  # Status apakah karakter sedang dash
var dash_timer = 0.0  # Timer untuk durasi dash
var last_direction = 0  # Arah terakhir (1 = kanan, -1 = kiri)
var last_input_time = 0.0  # Waktu terakhir input diterima
var double_tap_threshold = 0.2  # Batas waktu untuk double tap (dalam detik)

func _physics_process(delta):
	velocity.y += delta * gravity

	# Reset jump count ketika menyentuh lantai
	if is_on_floor():
		jump_count = 0

	# Lompat pertama atau double jump
	if Input.is_action_just_pressed('ui_up'):
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = jump_speed
			jump_count += 1

	# Handle dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = 0 
	else:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -walk_speed
			check_double_tap("ui_left", delta)
		elif Input.is_action_pressed("ui_right"):
			velocity.x = walk_speed
			check_double_tap("ui_right", delta)
		else:
			velocity.x = 0

	move_and_slide()

# Fungsi untuk mendeteksi double tap
func check_double_tap(action: String, delta: float):
	var current_time = Time.get_ticks_msec() / 1000.0  

	if Input.is_action_just_pressed(action):
		if current_time - last_input_time < double_tap_threshold and last_direction == (1 if action == "ui_right" else -1):
			start_dash(last_direction)
		last_input_time = current_time
		last_direction = 1 if action == "ui_right" else -1

# Fungsi untuk memulai dash
func start_dash(direction: int):
	is_dashing = true
	dash_timer = dash_duration
	velocity.x = dash_speed * direction
