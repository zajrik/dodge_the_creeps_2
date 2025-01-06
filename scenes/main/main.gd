extends Node

@export var mob_scene: PackedScene

var score: int = 0

func _ready() -> void:
  $UI/Retry.hide()

  # Randomize starting spawn location
  $SpawnPath/SpawnLocation.progress_ratio = randf()
  new_game()

func _process(_delta) -> void:
  var mob_count: int = get_tree().get_nodes_in_group('mobs').size()

  var debug_text: String = ''
  debug_text += 'Mobs: %s\n' % mob_count

  $UI/DebugLabel.set_text(debug_text)
  $UI/ScoreLabel.set_text('Score: %s' % str(score))

  if Input.is_action_just_pressed('debug_clear'):
    get_tree().call_group('mobs', 'queue_free')

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed('ui_accept') and $UI/Retry.visible:
    new_game()

## Prepare and spawn a mob on SpawnTimer tick
func _on_spawn_timer_timeout() -> void:
  var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
  spawn_location.progress_ratio = randf()

  var mob: Mob = mob_scene.instantiate()
  mob.initialize(spawn_location.position, $Player.position)
  mob.squashed.connect(increase_score)

  add_child(mob)

## Show retry screen and stop spawn timer on Player hit
func _on_player_hit() -> void:
  game_over()

## Start a new game.
func new_game() -> void:
  score = 0
  get_tree().call_group('mobs', 'queue_free')
  $UI/Retry.hide()
  $Player.show()

  # Enable player mob collision
  $Player.set_collision_mask_value(2, true)

  # Disable mob collision during gameplay
  get_tree().call_group('mobs', 'set_collision_mask_value', 2, false)

## End the current game, displaying the retry screen
func game_over() -> void:
  # Hide player and disable player mob collision
  $Player.hide()
  $Player.set_collision_mask_value(2, false)

  # Allow mobs to collide with eachother during game-over screen
  get_tree().call_group('mobs', 'set_collision_mask_value', 2, true)

  $UI/Retry.show()

## Increment the score by 1.
func increase_score() -> void:
  score += 1

## Spawn a mob at a random location along the spawn path.
func debug_spawn_mob() -> void:
  pass
