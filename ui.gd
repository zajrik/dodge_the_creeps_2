extends Control

const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

func _process(_delta: float) -> void:
  if not $Retry.visible:
    $ScoreLabel.set('theme_override_colors/font_color', BLACK)
    $DebugLabel.set('theme_override_colors/font_color', BLACK)
  else:
    $ScoreLabel.set('theme_override_colors/font_color', WHITE)
    $DebugLabel.set('theme_override_colors/font_color', WHITE)
