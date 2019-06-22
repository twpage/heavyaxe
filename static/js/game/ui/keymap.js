// Generated by CoffeeScript 1.7.1
(function() {
  var MOVEKEYS;

  window.Brew.keymap = {
    MOVE_LEFT: [ROT.VK_LEFT, ROT.VK_NUMPAD4, ROT.VK_H, ROT.VK_A],
    MOVE_RIGHT: [ROT.VK_RIGHT, ROT.VK_NUMPAD6, ROT.VK_L, ROT.VK_D],
    MOVE_UP: [ROT.VK_UP, ROT.VK_NUMPAD8, ROT.VK_K, ROT.VK_W],
    MOVE_DOWN: [ROT.VK_DOWN, ROT.VK_NUMPAD2, ROT.VK_J, ROT.VK_S],
    MOVE_DOWNLEFT: [ROT.VK_NUMPAD1, ROT.VK_B],
    MOVE_DOWNRIGHT: [ROT.VK_NUMPAD3, ROT.VK_N],
    MOVE_UPLEFT: [ROT.VK_NUMPAD7, ROT.VK_Y],
    MOVE_UPRIGHT: [ROT.VK_NUMPAD9, ROT.VK_U],
    GENERIC_ACTION: [ROT.VK_SPACE, ROT.VK_NUMPAD5],
    DROP: [ROT.VK_X, ROT.VK_Q],
    INVENTORY: [ROT.VK_I, ROT.VK_E],
    SHOW_ABILITIES: [ROT.VK_Z],
    HELP: [ROT.VK_SLASH, ROT.VK_QUESTION_MARK],
    DEBUG: [ROT.VK_BACK_QUOTE],
    ABILITY_HOTKEY: [ROT.VK_1, ROT.VK_2, ROT.VK_3, ROT.VK_4, ROT.VK_5, ROT.VK_6],
    EXIT_OR_CANCEL: [ROT.VK_ESCAPE],
    CYCLE_TARGET: [ROT.VK_TAB],
    STAIRS_DOWN: [ROT.VK_LESS_THAN, ROT.VK_COMMA],
    STAIRS_UP: [ROT.VK_GREATER_THAN, ROT.VK_PERIOD]
  };

  window.Brew.GamepadMap = {
    BUTTON_UP: 12,
    BUTTON_DOWN: 13,
    BUTTON_LEFT: 14,
    BUTTON_RIGHT: 15,
    BUTTON_A: 0,
    BUTTON_B: 1,
    BUTTON_X: 2,
    BUTTON_Y: 3
  };

  MOVEKEYS = [];

  MOVEKEYS.merge(Brew.keymap.MOVE_LEFT);

  MOVEKEYS.merge(Brew.keymap.MOVE_RIGHT);

  MOVEKEYS.merge(Brew.keymap.MOVE_UP);

  MOVEKEYS.merge(Brew.keymap.MOVE_DOWN);

  window.Brew.keymap.MOVEKEYS = MOVEKEYS;

}).call(this);

//# sourceMappingURL=keymap.map