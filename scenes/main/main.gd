extends Node

@export var mob_scene: PackedScene

var score: int = 0

# Start in demo mode, allowing mobs to collide for my amusement
var demo: bool = true

func _ready() -> void:
  $UI/Retry.hide()

  # Randomize starting spawn location
  $Arena/SpawnPath/SpawnLocation.progress_ratio = randf()
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

## Prepare and spawn a mob on SpawnTimer tick.
func _on_spawn_timer_timeout() -> void:
  var spawn_location: PathFollow3D = $Arena/SpawnPath/SpawnLocation
  spawn_location.progress_ratio = randf()

  var mob: Mob = mob_scene.instantiate()
  mob.initialize(spawn_location.position, $Player.position)
  mob.squashed.connect(increase_score)

  # Enable inter-mob collision in demo mode
  if demo:
    mob.set_collision_mask_value(2, true)

  add_child(mob)

## Show retry screen and stop spawn timer on Player hit.
func _on_player_hit() -> void:
  game_over()

## Start a new game.
func new_game() -> void:
  score = 0
  demo = false
  get_tree().call_group('mobs', 'queue_free')
  $UI/Retry.hide()

  # Move player to spawn and unhide
  $Player.show()
  $Player.set_position($Arena/PlayerSpawnMarker.global_position)

  # Disable inter-mob collision during gameplay
  get_tree().call_group('mobs', 'set_collision_mask_value', 2, false)

## End the current game, displaying the retry screen.
func game_over() -> void:
  # Hide player and move out of arena so mobs don't bounce off the invisible player
  $Player.hide()
  $Player.set_position($Jail/PlayerJailMarker.global_position)

  # I tried disabling the player's mob collision mask but that didn't stop
  # collisions for some reason??? So making a little jail below the arena
  # and moving the player out of harms way seemed like the easiest solution

  # Udpate: I figured out the mob collision problem. I was setting it for all
  # current mobs but forgot to set it on newly spawned mobs which is what I
  # accomplished with "demo" mode in the 2D version. Implemented that here,
  # but I'm keeping the jail because I think it's silly and that makes me happy

  # Allow mobs to collide with eachother during game-over screen
  demo = true
  get_tree().call_group('mobs', 'set_collision_mask_value', 2, true)

  $UI/Retry.show()

## Increment the score by 1.
func increase_score() -> void:
  score += 1
