extends Control

# Sprite page variables
var start_up_page
var no_wifi_page
var menu_page
var back_button
var library_button
var library_page
var search_button
var menu_shown = false
var news_button
var news_pages = []
var current_news_index = 0
var current_page = "Start-up"

# Timer variables for sequencing the pages
var no_wifi_timer = Timer.new()
var menu_timer = Timer.new()

func _ready():
	# Assign the sprite nodes to the variables
	start_up_page = $"Visuals/Case/Start-up"
	no_wifi_page = $"Visuals/Case/No-WiFi"
	menu_page = $"Visuals/Case/Menu"
	back_button = $"Visuals/Case/BackTextureButton"
	library_button = $"Visuals/Case/Menu/LibraryTextureButton"
	library_page = $"Visuals/Case/Library"
	search_button = $"Visuals/Case/Menu/SearchTextureButton"
	news_button = $"Visuals/Case/Menu/NewsTextureButton"
	news_pages = [ $"Visuals/Case/News-1", $"Visuals/Case/News-2", $"Visuals/Case/News-3" ]
	for news_page in news_pages:
		news_page.visible = false
	news_button.connect("pressed", self, "_on_NewsButton_pressed")
	back_button.connect("pressed", self, "_on_BackButton_pressed")

	# Initially hide all pages except the startup page
	start_up_page.visible = true
	no_wifi_page.visible = false
	menu_page.visible = false
	library_page.visible = false
	back_button.visible = false

	# Play the 'ShowEreader' animation on scene start
	$AnimationPlayer.play("ShowEreader")
	print("ShowEreader animation started")

	# Connect signals
	$PutDownButton.connect("pressed", self, "_on_PutDownButton_pressed")
	library_button.connect("pressed", self, "_on_LibraryButton_pressed")
	search_button.connect("pressed", self, "_on_SearchButton_pressed")
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

	# Set up timers
	setup_timers()

func setup_timers():
	no_wifi_timer.wait_time = 1 # Time before showing the No-WiFi page
	no_wifi_timer.one_shot = true
	no_wifi_timer.connect("timeout", self, "_on_NoWifiTimer_timeout")
	add_child(no_wifi_timer)
	
	menu_timer.wait_time = 1 # Time before showing the Menu page
	menu_timer.one_shot = true
	menu_timer.connect("timeout", self, "_on_MenuTimer_timeout")
	add_child(menu_timer)

func show_page(page_name):
	# Update the current page
	current_page = page_name
	print("Showing page:", page_name)

	# Hide all pages first
	start_up_page.visible = false
	no_wifi_page.visible = false
	menu_page.visible = false
	library_page.visible = false
	for news_page in news_pages:
		news_page.visible = false

	# Then make the requested page visible
	var page = get_node("Visuals/Case/" + page_name)
	page.visible = true

	# Handle back button visibility
	if page_name == "Menu":
		back_button.visible = true
		menu_shown = true
	if menu_shown:
		back_button.visible = true



# Signal callbacks
func _on_AnimationPlayer_animation_finished(anim_name):
	print("Animation finished:", anim_name)
	if anim_name == "ShowEreader":
		print("Starting No-WiFi timer...")
		no_wifi_timer.start()
	elif anim_name == "HideEreader":
		queue_free()
		print("Scene queued for freeing")

func _on_PutDownButton_pressed():
	$AnimationPlayer.play("HideEreader")
	$PutDownButton.visible = false
	print("HideEreader animation started")

func _on_NoWifiTimer_timeout():
	print("No-WiFi timer timeout, showing No-WiFi page")
	show_page("No-WiFi")
	print("Starting Menu timer...")
	menu_timer.start()

func _on_MenuTimer_timeout():
	print("Menu timer timeout, transitioning from No-WiFi to Menu")
	no_wifi_page.visible = false
	menu_page.visible = true
	back_button.visible = true
	current_page = "Menu"
	print("Menu page shown")


func _on_LibraryButton_pressed():
	show_page("Library")
	print("Library page shown")

func _on_SearchButton_pressed():
	show_page("No-WiFi")
	print("No-WiFi page shown")

func _on_NewsButton_pressed():
	show_news_page(0)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_RIGHT:
			current_news_index += 1
			if current_news_index >= news_pages.size():
				current_news_index = 0 # Loop back to the first news page
			show_news_page(current_news_index)
		elif event.scancode == KEY_LEFT:
			current_news_index -= 1
			if current_news_index < 0:
				current_news_index = news_pages.size() - 1 # Loop to the last news page
			show_news_page(current_news_index)

func show_news_page(index):
	# Set all news pages to invisible and the selected one to visible
	for i in range(news_pages.size()):
		news_pages[i].visible = i == index
	# Update current page identifier
	current_news_index = index
	current_page = "News-" + str(index + 1)
	print("Current news page: " + current_page)

func _on_BackButton_pressed():
	print("Current page on back button press: " + current_page)
	# Check if the user is currently viewing one of the news pages
	if current_page in ["News-1", "News-2", "News-3"]:
		# If on a news page, navigate back to the Menu
		show_page("Menu")
		print("Returning to Menu from News")
	elif current_page != "Menu" and current_page != "Start-up":
		# For other pages, navigate back to the Menu
		show_page("Menu")
		print("Returning to Menu from", current_page)

