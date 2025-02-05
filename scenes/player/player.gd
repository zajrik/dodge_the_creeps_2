class_name Player extends CharacterBody3D

#region NodePath references
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var character: Node3D = $Character
#endregion

## Emitted when the player gets hit.
signal hit

#region Exported properties
## How fast the player character moves in meters/sec.
@export var speed: int = 14

## Downward acceleration while airborne in meters/sec squared.
@export var fall_acceleration: int = 75

## Upward impulse to be added on jump in meters/sec.
@export var jump_impulse: int = 20

## Upward impulse to be added on bounce in meters/sec.
@export var bounce_impulse: int = 16
#endregion

const move_actions: Array[StringName] = [
    &'move_left',
    &'move_right',
    &'move_forward',
    &'move_back'
]

var target_velocity := Vector3.ZERO

func _physics_process(delta: float) -> void:
    # Get input direction
    var input: Vector2 = Input.get_vector.bindv(move_actions).call()
    var direction := Vector3(input.x, 0, input.y)

    # Normalize direction and LOOK AT IT
    if direction != Vector3.ZERO:
        direction = direction.normalized()
        set_basis(Basis.looking_at(direction))

        # Speed up animation scale when moving
        animation.set_speed_scale(4)
    else:
        animation.set_speed_scale(1)

    # Set horizontal target velocity
    target_velocity.x = direction.x * speed
    target_velocity.z = direction.z * speed

    # Apply gravity to target velocity if airborne
    if not is_on_floor():
        target_velocity.y -= fall_acceleration * delta

    # Add jump impulse to target velocity if jump is pressed
    if is_on_floor() and Input.is_action_just_pressed(&'jump'):
        target_velocity.y = jump_impulse

    # Check for mob collision and squash if hit from above
    for index in range(get_slide_collision_count()):
        var collision: KinematicCollision3D = get_slide_collision(index)

        # Ignore collisions that are not mobs
        if collision.get_collider() is not Mob:
            continue

        var mob: Mob = collision.get_collider()

        # If we land on a mob from above, give it the ol' squash n' bounce
        if Vector3.UP.dot(collision.get_normal()) > 0.1:
            mob.squash()
            target_velocity.y = bounce_impulse

            break

    set_velocity(target_velocity)
    move_and_slide()

    # Adjust character angle over jump arc
    character.rotation.x = PI / 6 * velocity.y / jump_impulse

func _on_mob_detector_body_entered(_body: Node3D) -> void:
    hit.emit()
