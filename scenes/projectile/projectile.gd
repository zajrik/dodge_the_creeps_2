class_name Projectile extends Area3D

@onready var model: Node3D = $Model


## Projectile speed in meters/sec
@export var projectile_speed: int = 25

var velocity := Vector3.ZERO


## Initialize this projectile, setting its position and rotation
func initialize(position: Vector3, rotation: Vector3):
  set_position(position)
  set_rotation(rotation)
  velocity = Vector3.FORWARD.rotated(Vector3.UP, rotation.y)


func _physics_process(delta: float) -> void:
  position += velocity * projectile_speed * delta


func _on_body_entered(body: Node3D) -> void:
  if body is Mob:
    body.squash()
    queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
  queue_free()
