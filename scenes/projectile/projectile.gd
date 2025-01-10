class_name Projectile extends Area3D

@onready var model: Node3D = $Model


## Projectile speed in meters/sec
@export var projectile_speed: int = 25

var velocity := Vector3.ZERO


## Initialize this projectile, setting its position and rotation
func initialize(pos: Vector3, rot: Vector3) -> void:
    set_position(pos)
    set_rotation(rot)
    velocity = Vector3.FORWARD.rotated(Vector3.UP, rot.y)


func _physics_process(delta: float) -> void:
    position += velocity * projectile_speed * delta


func _on_body_entered(body: Node3D) -> void:
    if body is Mob:
        body.squash()
        queue_free()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
    queue_free()
