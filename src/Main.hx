
import luxe.GameConfig;
import luxe.Input;

class Main extends luxe.Game {

	override function config(config:GameConfig) {

		config.window.title = 'ld template';
		config.window.width = 960;
		config.window.height = 640;
		config.window.fullscreen = false;

		return config;

	}

	override function ready() {

	}

	override function onkeyup( e:KeyEvent ) {

		if(e.keycode == Key.escape) {
			Luxe.shutdown();
		}

	}

	override function update(dt:Float) {

	}

}
