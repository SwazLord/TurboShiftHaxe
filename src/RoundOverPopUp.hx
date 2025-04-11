import starling.display.Sprite;
import starling.display.Button;
import starling.events.Event;
import feathers.starling.core.PopUpManager;

class RoundOverPopUp extends Sprite {
	private var _main_sprite:Sprite;

	public var _play_again_button:Button;
	public var _quit_button:Button;

	public function new() {
		super();
		trace("Roun Over Popup Constructor");
		_main_sprite = new Sprite();
		_main_sprite = try cast(Game.current_instance._ui_builder.create(ParsedLayouts.round_over_ui, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_play_again_button.addEventListener(Event.TRIGGERED, onPlayAgain);
		_quit_button.addEventListener(Event.TRIGGERED, onQuit);
	}

	private function onQuit(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");
		(try cast(Game.current_instance._current_state, RaceGame) catch (e:Dynamic) null).quitRaceGame();
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;

		_quit_button.removeEventListener(Event.TRIGGERED, onQuit);
		_play_again_button.removeEventListener(Event.TRIGGERED, onPlayAgain);
	}

	private function onPlayAgain(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");
		(try cast(Game.current_instance._current_state, RaceGame) catch (e:Dynamic) null).resetRace();
	}
}
