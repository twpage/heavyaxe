howl_sounds =

	bump: new Howl({
  		src: ['/static/audio/bump_0.wav']
	})


sounds_def = 
	"bump": 2
	"dropaxe": 1
	"hit": 3
	"pickup": 3
	"portal": 1
	"new_level": 1

howl_sounds = {}
for own sound_name, num_sounds of sounds_def
	for i in [0..num_sounds-1]
		sound_id = sound_name + "_" + "#{i}"
		sound_path = "/static/audio/#{sound_id}.wav"
		howl_sounds[sound_id] = new Howl({src: [sound_path]})

play_sound = false

Brew.Sounds =
	play: (sound_name) ->
		if play_sound
			if sound_name not of sounds_def
				console.error("bad sound #{sound_name}")

			num_sounds = sounds_def[sound_name]
			random_num = Math.floor(num_sounds * ROT.RNG.getUniform())
			sound_id = sound_name + "_" + "#{random_num}"
			howl_sounds[sound_id].play()

	mute: () ->
		play_sound = not play_sound
		onoff = if play_sound then "On" else "Off"
		console.log("Sound #{onoff}")