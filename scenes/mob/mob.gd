class_name Mob extends CharacterBody3D

## Emitted when the mob has been squashed by the player.
signal squashed

## Minimum movement speed in meters/sec.
@export var min_speed: int = 10

## Maximum movement speed in meters/sec.
@export var max_speed: int = 18

## Timestep used for interpolating turn direction
var timestep: float = 0.0


## Initialize this mob, setting its position and velocity.
func initialize(start_pos: Vector3, player_pos: Vector3) -> void:
  var target_pos := Vector3(player_pos)

  # Maintain y heading in target position to avoid mobs looking up at the player
  # if spawned while the player is airborne
  target_pos.y = position.y

  # Move mob to start_pos and look at target_pos
  look_at_from_position(start_pos, target_pos, Vector3.UP)

  # Randomize look rotation within +/-45 degrees towards target
  rotate_y(randf_range(-PI / 4, PI / 4))

  # Set velocity vector to the direction the mob is looking
  var speed: float = randi_range(min_speed, max_speed)
  velocity = (Vector3.FORWARD * speed).rotated(Vector3.UP, rotation.y)

  # Set random animation speed scale
  $AnimationPlayer.speed_scale = speed / min_speed


## Squash this mob.
func squash() -> void:
  squashed.emit()
  queue_free()


func _physics_process(_delta: float) -> void:
  # Iterate collisions to handle bouncing when collision is enabled
  for index in range(get_slide_collision_count()):
    var collision: KinematicCollision3D = get_slide_collision(index)

    # Bounce on first non-terrain collision
    if collision.get_collider() != null:
      set_velocity(velocity.bounce(collision.get_normal()))
      timestep = 0.0

  # Force mob to look in the direction of its movement but lerp rotation
  # based on animation speed scale so faster mobs turn faster and vice-versa
  timestep += _delta * 0.1 * $AnimationPlayer.speed_scale
  var current_basis := Quaternion(transform.basis)
  var target_basis := Quaternion(Basis.looking_at(velocity))
  var new_basis := current_basis.slerp(target_basis, clamp(timestep, 0.0, 1.0))
  transform.basis = Basis(new_basis)

  move_and_slide()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
  # Free self when no longer visible on screen
  queue_free()
