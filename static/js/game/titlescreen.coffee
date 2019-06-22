menu_def =
	"new_game": "New Game"
	"new_with_seed": "New Custom Game"
	"credits": "Credits"
		
active_menu = "new_game"

window.HeavyAxeTitle =
	updateTitleMenu: () ->
		
		menu_html = "<ul class='no_bullets'>"

		for own menu_name, menu_text of menu_def
			li_class = if menu_name == active_menu then "active" else "inactive"
			menu_html += "<li class='menu_#{li_class}'>#{menu_text}</li>"

		menu_html += "</ul>"
		$("#id_div_title_menu").html(menu_html)

	startGame: (seed) ->
		window.location.href = "/"

