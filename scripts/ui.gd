class_name UI extends Control

const BLACK := Color(0.0, 0.0, 0.0, 1.0)
const WHITE := Color(1.0, 1.0, 1.0, 1.0)

# Node path reference convenience vars
@onready var message_label: Label = $Message
@onready var message_timer: Timer = $Message/Timer
@onready var score_label: Label = $ScoreLabel
@onready var debug_label: Label = $DebugLabel
@onready var retry_overlay: ColorRect = $Retry

func _ready() -> void:
    message_label.hide()
    score_label.set(&'theme_override_colors/font_color', BLACK)
    debug_label.set(&'theme_override_colors/font_color', BLACK)
    message_label.set(&'theme_override_colors/font_color', BLACK)
    message_label.set(&'theme_override_colors/font_outline_color', WHITE)

## Show the retry screen.
func show_retry() -> void:
    score_label.set(&'theme_override_colors/font_color', WHITE)
    debug_label.set(&'theme_override_colors/font_color', WHITE)
    message_label.set(&'theme_override_colors/font_color', WHITE)
    message_label.set(&'theme_override_colors/font_outline_color', BLACK)

    retry_overlay.show()
    show_message('Press ENTER to retry', 32)

## Hide the retry screen.
func hide_retry() -> void:
    score_label.set(&'theme_override_colors/font_color', BLACK)
    debug_label.set(&'theme_override_colors/font_color', BLACK)
    message_label.set(&'theme_override_colors/font_color', BLACK)
    message_label.set(&'theme_override_colors/font_outline_color', WHITE)

    retry_overlay.hide()
    message_label.hide()
    message_label.set_text('')

## Show the given message for a specified duration.
##
## If duration is not set then the message must be manually hidden
## when no longer needed.
func show_message(msg: String, font_size: int = 64, duration: int = -1) -> void:
    message_label.set_text(msg)
    message_label.set(&'theme_override_font_sizes/font_size', font_size)
    message_label.show()

    if duration > 0:
        message_timer.start(duration)
        await message_timer.timeout
        message_label.hide()
