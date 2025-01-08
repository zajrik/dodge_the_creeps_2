extends Control

const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

func _ready() -> void:
  $Message.hide()
  $ScoreLabel.set('theme_override_colors/font_color', BLACK)
  $DebugLabel.set('theme_override_colors/font_color', BLACK)
  $Message.set('theme_override_colors/font_color', BLACK)
  $Message.set('theme_override_colors/font_outline_color', WHITE)


## Show the retry screen.
func show_retry() -> void:
  $ScoreLabel.set('theme_override_colors/font_color', WHITE)
  $DebugLabel.set('theme_override_colors/font_color', WHITE)
  $Message.set('theme_override_colors/font_color', WHITE)
  $Message.set('theme_override_colors/font_outline_color', BLACK)
  $Retry.show()
  show_message('Press ENTER to retry', 32)


## Hide the retry screen.
func hide_retry() -> void:
  $ScoreLabel.set('theme_override_colors/font_color', BLACK)
  $DebugLabel.set('theme_override_colors/font_color', BLACK)
  $Message.set('theme_override_colors/font_color', BLACK)
  $Message.set('theme_override_colors/font_outline_color', WHITE)

  $Retry.hide()
  $Message.hide()
  $Message.set_text('')


## Show the given message for a specified duration.
##
## If duration is not set then the message must be manually hidden
## when no longer needed.
func show_message(msg: String, font_size: int = 64, duration: int = -1) -> void:
  $Message.set_text(msg)
  $Message.set('theme_override_font_sizes/font_size', font_size)
  $Message.show()

  if duration > 0:
    $Message/Timer.start(duration)
    await $Message/Timer.timeout
    $Message.hide()
