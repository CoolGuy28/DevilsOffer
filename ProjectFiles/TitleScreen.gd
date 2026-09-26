class_name TitleScreen extends Node2D
@onready var title_screen: Panel = $Camera2D/CanvasLayer/TitleScreen
@onready var create_player_menu: TitleScreen_CreatePlayerMenu = $Camera2D/CanvasLayer/CreatePlayerMenu

func _ready() -> void:
	OpenTitleScreen()

func _on_newgame_pressed() -> void:
	title_screen.hide()
	create_player_menu.OpenCreatePlayerMenu()
	pass

func OpenTitleScreen():
	title_screen.show()
	create_player_menu.hide()
	create_player_menu.set_process(false)

func _on_loadgame_pressed() -> void:
	title_screen.hide()
	print("loading")
	GameManager.LoadSavedGameScene()

func _on_quit_pressed() -> void:
	get_tree().quit()
