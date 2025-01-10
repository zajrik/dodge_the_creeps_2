class_name SphericalExplosion extends Area3D

@onready var animation: AnimationPlayer = $AnimationPlayer

func explode() -> void:
    print('explosion!!')
    animation.play(&'expand')
    await get_tree().create_timer(3).timeout
    queue_free()

func _on_body_entered(body: Node3D) -> void:
    if body is Mob:
        body.squash()
