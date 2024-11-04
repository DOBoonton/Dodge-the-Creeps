extends Node

@export var mob_scene: PackedScene
@onready var background = $ColorRect
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	$Mob/AnimatedSprite2D.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	_on_hud_start_game()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	$Player._speed(score)
	background = [5,5,5]

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0) + score / 2, 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	var scoreCheck = score
	add_child(mob)
	while scoreCheck / 10 >= 1:
		add_child(mob)
		scoreCheck -= 10
	
	if 2 - score / 16 > 0:
		$MobTimer.wait_time = 2 - score / 16
	elif 2 - (score / 16) + (score / 32) > 0:
		$MobTimer.wait_time = 2 - (score / 16) + (score / 32)
	elif score < 75:
		$MobTimer.wait_time = 0.5
	else:
		$MobTimer.wait_time = 0.1
func _on_player_hit():
	game_over()


func _on_hud_start_game():
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$Player._speed(score)
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Player.start($StartPosition.position)
	$StartTimer.start()
