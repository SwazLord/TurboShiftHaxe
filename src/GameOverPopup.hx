import starling.display.Sprite;
import starling.display.Button;
import starling.events.Event;
import starling.text.TextField;

class GameOverPopup extends Sprite {
	private var _main_sprite:Sprite;

	public var _play_again_button:Button;
	public var _quit_button:Button;
	public var _player_score_text:TextField;

	public function new(score:Int) {
		super();
		var ui_object:Dynamic = TurboShift.root_class.asset_manager.getObject("round_over_ui");
		_main_sprite = try cast(TurboShift.root_class.ui_builder.create(ui_object, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_play_again_button.addEventListener(Event.TRIGGERED, onPlayAgain);
		_quit_button.addEventListener(Event.TRIGGERED, onQuit);

		_player_score_text.text = Std.string(score);
	}

	private function onPlayAgain(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		(try cast(TurboShift.root_class.curent_state, Race) catch (e:Dynamic) null).resetRace();
	}

	private function onQuit(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		(try cast(TurboShift.root_class.curent_state, Race) catch (e:Dynamic) null).quitRace();
	}
}
