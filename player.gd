extends CharacterBody3D

## Emitted when the player gets hit.
signal hit

## How fast the player character moves in meters/sec.
@export var speed: int = 14

## Downward acceleration while airborne in meters/sec squared.
@export var fall_acceleration: int = 75

## Upward impulse to be added on jump in meters/sec.
@export var jump_impulse: int = 20

## Upward impulse to be added on bounce in meters/sec.
@export var bounce_impulse: int = 16

var target_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
  var direction := Vector3.ZERO

  # Add jump impulse to target velocity if jump is pressed
  if is_on_floor() and Input.is_action_just_pressed('jump'):
    target_velocity.y = jump_impulse

  # Get input direction
  var input: Vector2 = Input.get_vector('move_left', 'move_right', 'move_forward', 'move_back')
  direction += Vector3(input.x, 0, input.y)

  # Normalize direction and LOOK AT IT
  if direction != Vector3.ZERO:
    direction = direction.normalized()
    $Character.basis = Basis.looking_at(direction)

  # Set horizontal target velocity
  target_velocity.x = direction.x * speed
  target_velocity.z = direction.z * speed

  # Apply gravity to target velocity if airborne
  if not is_on_floor():
    target_velocity.y -= fall_acceleration * delta

  # Check for mob collision and squash if hit from above
  for index in range(get_slide_collision_count()):
    var collision: KinematicCollision3D = get_slide_collision(index)

    # Ignore collisions that are not mobs
    if collision.get_collider() is not Mob:
      continue

    var mob: Mob = collision.get_collider()

    # If we land on a mob, give it the ol' squash n' bounce
    if mob.is_in_group('mobs') and Vector3.UP.dot(collision.get_normal()) > 0.1:
      mob.squash()
      target_velocity.y = bounce_impulse

      break

  velocity = target_velocity
  move_and_slide()

func _on_mob_detector_body_entered(body: Node3D) -> void:
  hit.emit()
  queue_free()
