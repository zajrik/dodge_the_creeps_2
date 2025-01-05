extends Node

@export var mob_scene: PackedScene

var score: int = 0

func _ready() -> void:
  $UI/Retry.hide()

  # Randomize starting spawn location
  $SpawnPath/SpawnLocation.progress_ratio = randf()

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
    get_tree().reload_current_scene()

## Prepare and spawn a mob on SpawnTimer tick
func _on_spawn_timer_timeout() -> void:
  var mob: Mob = mob_scene.instantiate()

  var spawn_location: PathFollow3D = $SpawnPath/SpawnLocation
  spawn_location.progress_ratio = randf()

  mob.initialize(spawn_location.position, $Player.position)
  mob.squashed.connect(increase_score)

  add_child(mob)

## Show retry screen and stop spawn timer on Player hit
func _on_player_hit() -> void:
  $UI/Retry.show()
  $SpawnTimer.stop()

## Start a new game.
func new_game() -> void:
  score = 0

## Increment the score by 1.
func increase_score() -> void:
  score += 1

## Spawn a mob at a random location along the spawn path.
func debug_spawn_mob() -> void:
  pass
