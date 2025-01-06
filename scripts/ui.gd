extends Control

const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
  $Message.hide()

func _process(_delta: float) -> void:
  if not $Retry.visible:
    $Message.set('theme_override_colors/font_color', BLACK)
    $ScoreLabel.set('theme_override_colors/font_color', BLACK)
    $DebugLabel.set('theme_override_colors/font_color', BLACK)
  else:
    $Message.set('theme_override_colors/font_color', WHITE)
    $ScoreLabel.set('theme_override_colors/font_color', WHITE)
    $DebugLabel.set('theme_override_colors/font_color', WHITE)

func show_message(msg: String, duration: int = 2) -> void:
  $Message.set_text(msg)
  $Message/Timer.set_wait_time(duration)
  $Message/Timer.start()

  await $Message/Timer.timeout

  $Message.hide()
