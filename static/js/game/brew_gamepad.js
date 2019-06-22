var gamepads = {};
var start;
var rAF = window.requestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.webkitRequestAnimationFrame;

var rAFStop = window.cancelRequestAnimationFrame ||
  window.mozCancelRequestAnimationFrame ||
  window.webkitCancelRequestAnimationFrame;


function gamepadHandler(event, connecting) {
  var gamepad = event.gamepad;
  // Note:
  // gamepad === navigator.getGamepads()[gamepad.index]

  if (connecting) {
    gamepads[gamepad.index] = gamepad;

    connectGamepad(event, gamepad);

  } else {
    delete gamepads[gamepad.index];
  }
}

// mozilla connect
////////////////////////////////////////////////////////////
window.addEventListener("gamepadconnected", function(e) { gamepadHandler(e, true); }, false);
window.addEventListener("gamepaddisconnected", function(e) { gamepadHandler(e, false); }, false);

function connectGamepad (event, gamepad) {
    console.log("Gamepad connected at index %d: %s. %d buttons, %d axes.",
		event.gamepad.index, event.gamepad.id,
		event.gamepad.buttons.length, event.gamepad.axes.length
	);

	gameLoop();
}

function disconnectGamepad (event, gamepad) {
	console.log("Gamepad #{event.gamepad.index} disconnected");
	rAFStop(start);
}

// Chrome connect
////////////////////////////////////////////////////////////
var interval;

if (!('ongamepadconnected' in window)) {
  // No gamepad events available, poll instead.
  interval = setInterval(pollGamepads, 500);
}

function pollGamepads() {
  var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
  for (var i = 0; i < gamepads.length; i++) {
    var gp = gamepads[i];
    if (gp) {
    	console.log("Connected to Gamepad ", gp.id)
      	gameLoop();
      	clearInterval(interval);
    }
  }
}

// handle button pressing and gamepad events
////////////////////////////////////////////////////////////

function buttonPressed(b) {
	if (typeof(b) == "object") {
		return b.pressed;
	}
	
	return b == 1.0;
}

var lastTimestamp = 0;

function gameLoop () {

	var gamepads = navigator.getGamepads ? navigator.getGamepads() : (navigator.webkitGetGamepads ? navigator.webkitGetGamepads : []);
	if (!gamepads) {
		return;
	}

	var gp = gamepads[0];

	if (buttonPressed(gp.buttons[0])) {
		buttonEvent(0, gp);
	} else if (buttonPressed(gp.buttons[1])) {
		buttonEvent(1, gp);
	} else if (buttonPressed(gp.buttons[2])) {
		buttonEvent(2, gp);
	} else if (buttonPressed(gp.buttons[3])) {
		buttonEvent(3, gp);
	} else if (buttonPressed(gp.buttons[12])) {
		buttonEvent(12, gp);
	} else if (buttonPressed(gp.buttons[13])) {
		buttonEvent(13, gp);
	} else if (buttonPressed(gp.buttons[14])) {
		buttonEvent(14, gp);
	} else if (buttonPressed(gp.buttons[15])) {
		buttonEvent(15, gp);
	} 

	start = rAF(gameLoop);
}


function buttonEvent (button_number, gamepad) {
	if (gamepad.timestamp > lastTimestamp) {
		// console.log("pressed button ", button_number, gamepad.timestamp);
		lastTimestamp = gamepad.timestamp;

		Brew.Input.gamepadInput(button_number);
	} 

}