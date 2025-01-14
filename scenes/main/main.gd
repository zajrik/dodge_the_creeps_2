extends Node

#region NodePath references
@onready var player: Player = $Player

@onready var player_spawn: Marker3D = $Arena/PlayerSpawnMarker
@onready var mob_spawn: PathFollow3D = $Arena/SpawnPath/SpawnLocation
@onready var jail: Marker3D = $Jail/PlayerJailMarker

@onready var ui: UI = $UI
@onready var score_label: Label = $UI/ScoreLabel
@onready var debug_label: Label = $UI/DebugLabel
@onready var retry_screen: ColorRect = $UI/Retry

@onready var start_timer: Timer = $StartTimer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var shoot_cooldown: Timer = $ShootCooldown
@onready var explode_cooldown: Timer = $ExplodeCooldown
#endregion

#region Exported properties
@export var mob_scene: PackedScene
@export var projectile_scene: PackedScene
@export var explosion_scene: PackedScene

@export var spawn_interval: float = 0.5
@export var demo_spawn_interval: float = 0.2
#endregion

var score: int = 0
var combo: int = 0

# Start in demo mode, allowing mobs to collide for my amusement
var demo: bool = true

func _ready() -> void:
    player.set_position(jail.global_position)

    # Randomize starting mob spawn location
    mob_spawn.progress_ratio = randf()

    spawn_timer.set_wait_time(demo_spawn_interval)
    spawn_timer.start()
    ui.show_message('Squash the Creeps!')

func _process(_delta) -> void:
    var mob_count: int = get_tree().get_nodes_in_group(&'mobs').size()

    var debug_text: String = ''
    debug_text += 'Mobs: %s\n' % mob_count
    debug_text += 'Pos: %s\n' % player.position
    debug_text += 'Facing: %s\n' % (Vector3.FORWARD.rotated(Vector3.UP, player.rotation.y))
    debug_text += 'Spawn: %s\n' % mob_spawn.global_position

    debug_label.set_text(debug_text)
    score_label.set_text('Score: %s' % str(score))

    # Append combo text to score label
    if (combo > 1):
        score_label.text += ' (x%s)' % combo

    # Reset combo if player falls to the ground
    if player.global_position.y < 0.6:
        combo = 0

    if Input.is_action_pressed(&'shoot') and shoot_cooldown.is_stopped():
        shoot()

    if Input.is_action_just_pressed(&'explode') and explode_cooldown.is_stopped():
        explode()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed(&'ui_accept') and demo:
        new_game()

    if event.is_action_pressed(&'debug_clear'):
        get_tree().call_group(&'mobs', &'queue_free')
        get_tree().call_group(&'projectiles', &'queue_free')

## Prepare and spawn a mob on SpawnTimer tick.
func _on_spawn_timer_timeout() -> void:
    mob_spawn.progress_ratio = randf()

    var mob: Mob = mob_scene.instantiate()
    mob.initialize(mob_spawn.global_position, player.position)
    mob.squashed.connect(_on_squash)

    # Enable inter-mob collision in demo mode
    if demo:
        mob.set_collision_mask_value(LayerNames.PHYSICS_3D.MOBS, true)

    add_child(mob)

## Show game over/retry screen.
func _on_player_hit() -> void:
    game_over()

## Start a new game.
func new_game() -> void:
    score = 0
    demo = false
    spawn_timer.stop()
    get_tree().call_group(&'mobs', &'queue_free')
    ui.hide_retry()

    # Move player to player_spawn and unhide
    player.show()
    player.set_position(player_spawn.global_position)

    # Disable inter-mob collision during gameplay
    get_tree().call_group(
        &'mobs',
        &'set_collision_mask_value',
        LayerNames.PHYSICS_3D.MOBS,
        false
    )

    ui.show_message('Get ready!', 64, 2)

    start_timer.start()
    await start_timer.timeout

    spawn_timer.set_wait_time(spawn_interval)
    spawn_timer.start()
    score_timer.start()

## End the current game, displaying the retry screen.
func game_over() -> void:
    score_timer.stop()

    # Hide player and move out of arena so mobs don't bounce off the invisible player
    player.hide()
    player.set_position(jail.global_position)

    # I tried disabling the player's mob collision mask but that didn't stop
    # collisions for some reason??? So making a little jail below the arena
    # and moving the player out of harms way seemed like the easiest solution

    # Update: I figured out the mob collision problem. I was setting it for all
    # current mobs but forgot to set it on newly spawned mobs which is what I
    # accomplished with "demo" mode in the 2D version. Implemented that here,
    # but I'm keeping the jail because I think it's silly and that makes me happy

    # Allow mobs to collide with eachother during game-over screen
    demo = true
    get_tree().call_group(
        &'mobs',
        &'set_collision_mask_value',
        LayerNames.PHYSICS_3D.MOBS,
        true
    )

    # Remove any remaining projectiles so a mob can't be squashed after game-over
    get_tree().call_group(&'projectiles', &'queue_free')

    spawn_timer.set_wait_time(demo_spawn_interval)

    ui.show_retry()

## Shoot a projectile.
func shoot() -> void:
    var projectile: Projectile = projectile_scene.instantiate()
    projectile.initialize(player.position, player.rotation)
    add_child(projectile)

    shoot_cooldown.start()

## EXPLOSION
func explode() -> void:
    if demo: return

    var explosion: SphericalExplosion = explosion_scene.instantiate()
    explosion.set_position(Vector3(player.global_position.x, 0, player.global_position.z))
    add_child(explosion)
    explosion.explode()

    explode_cooldown.start()

## Increment the score by the given multiplier.
func increase_score(multiplier: int) -> void:
    score += multiplier

## Increment score by 1 on ScoreTimer tick.
func _on_score_timer_timeout() -> void:
    increase_score(1)

## Handle mob squash, incrementing combo and increasing score.
func _on_squash() -> void:
    combo += 1
    increase_score(combo)
