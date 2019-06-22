// Generated by CoffeeScript 1.7.1
(function() {
  var active_menu, menu_def,
    __hasProp = {}.hasOwnProperty;

  menu_def = {
    "new_game": "New Game",
    "new_with_seed": "New Custom Game",
    "credits": "Credits"
  };

  active_menu = "new_game";

  window.HeavyAxeTitle = {
    updateTitleMenu: function() {
      var li_class, menu_html, menu_name, menu_text;
      menu_html = "<ul class='no_bullets'>";
      for (menu_name in menu_def) {
        if (!__hasProp.call(menu_def, menu_name)) continue;
        menu_text = menu_def[menu_name];
        li_class = menu_name === active_menu ? "active" : "inactive";
        menu_html += "<li class='menu_" + li_class + "'>" + menu_text + "</li>";
      }
      menu_html += "</ul>";
      return $("#id_div_title_menu").html(menu_html);
    },
    startGame: function(seed) {
      return window.location.href = "game.html";
    }
  };

}).call(this);

//# sourceMappingURL=titlescreen.map
