import starling.display.Sprite;
import starling.assets.AssetManager;
import starlingbuilder.engine.UIBuilder;
import starlingbuilder.engine.DefaultAssetMediator;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.layout.AnchorLayout;
import starling.display.Button;
import starling.events.Event;
import starling.events.EnterFrameEvent;
import openfl.net.SharedObject;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.layout.HorizontalLayout;
import treefortress.sound.SoundManager;
import openfl.system.Capabilities;
import starlingbuilder.engine.localization.ILocalization;
import starlingbuilder.engine.localization.DefaultLocalization;

class Game extends Sprite {
	public var asset_manager(get, never):AssetManager;
	public var curent_state(get, never):IState;
	public var ui_builder(get, never):UIBuilder;
	public var best_score(get, set):Int;
	public var bgm_player(get, never):SoundManager;
	public var sfx_player(get, never):SoundManager;
	public var bgm_muted(get, set):Bool;
	public var sfx_muted(get, set):Bool;
	public var locale(get, set):String;

	public static var linkers:Array<Dynamic> = [AnchorLayout, VerticalLayout, HorizontalLayout];

	private var _asset_manager:AssetManager;

	private function get_asset_manager():AssetManager {
		return _asset_manager;
	}

	private var _curent_state:IState;

	private function get_curent_state():IState {
		return _curent_state;
	}

	private var _ui_builder:UIBuilder;

	private function get_ui_builder():UIBuilder {
		return _ui_builder;
	}

	private var _asset_mediator:DefaultAssetMediator;
	private var _best_score:Int;

	private function get_best_score():Int {
		if (_shared_object.data.bestScore == null) {
			return 0;
		} else {
			return Std.int(_shared_object.data.bestScore);
		}
	}

	private function set_best_score(value:Int):Int {
		_shared_object.setProperty("bestScore", value);
		_shared_object.flush();
		return value;
	}

	private var _shared_object:SharedObject;
	private var _bgm_player:SoundManager;

	private function get_bgm_player():SoundManager {
		return _bgm_player;
	}

	private var _sfx_player:SoundManager;

	private function get_sfx_player():SoundManager {
		return _sfx_player;
	}

	private var _bgm_muted:Bool;

	private function get_bgm_muted():Bool {
		if (_shared_object.data.bgm_muted == null) {
			return false;
		} else {
			return _shared_object.data.bgm_muted;
		}
	}

	private function set_bgm_muted(value:Bool):Bool {
		_bgm_player.mute = value;
		_shared_object.setProperty("bgm_muted", value);
		_shared_object.flush();
		return value;
	}

	private var _sfx_muted:Bool;

	private function get_sfx_muted():Bool {
		if (_shared_object.data.sfx_muted == null) {
			return false;
		} else {
			return _shared_object.data.sfx_muted;
		}
	}

	private function set_sfx_muted(value:Bool):Bool {
		_sfx_player.mute = value;
		_shared_object.setProperty("sfx_muted", value);
		_shared_object.flush();
		return value;
	}

	private var _locale:String;

	private function get_locale():String {
		if (SUPPORTED_LOCALES.indexOf(Capabilities.language) != -1) {
			return Capabilities.language;
		} else {
			return "en";
		}
	}

	private function set_locale(value:String):String {
		_localization.locale = _locale = value;
		if (_curent_state != null) {
			cast(_curent_state, Lobby).localize();
		}
		return value;
	}

	private var _localization:ILocalization;
	private var SUPPORTED_LOCALES(default, never):Array<Dynamic> = ["en", "fr", "de"];

	public function new() {
		super();
		trace("Root game instance created");
		Animations.registerTransitions();
		_shared_object = SharedObject.getLocal("turbo-shift-gamedata-test");
		_bgm_player = new SoundManager();
		_sfx_player = new SoundManager();
		_asset_manager = new AssetManager();
		_asset_manager.enqueue([
			"assets/backgrounds/road_tile.png",
			"assets/textures/texture.png",
			"assets/textures/texture.xml",
			"assets/textures/LilitaOne.fnt",
			"assets/layouts/lobby_ui.json",
			"assets/layouts/road_ui.json",
			"assets/layouts/race_ui.json",
			"assets/layouts/round_over_ui.json",
			"assets/layouts/leaderboard_ui.json",
			"assets/layouts/leaderboard_item_ui.json",
			"assets/layouts/languages_ui.json",
			"assets/particles/bigExplosion.sde",
			"assets/particles/blazingFire.sde",
			"assets/particles/smoke.sde",
			"assets/localization/strings.json"
		]);

		_asset_manager.loadQueue(onComplete, onError, onProgress);

		bgm_player.loadSound("assets/sounds/game_loop.mp3", "game_loop");
		sfx_player.loadSound("assets/sounds/button_click.mp3", "button_click");
	}

	private function onComplete():Void {
		trace("assets loading complete");
		_localization = new DefaultLocalization(asset_manager.getObject("strings"), locale);
		_asset_mediator = new DefaultAssetMediator(_asset_manager);
		_ui_builder = new UIBuilder(_asset_mediator, false, null, _localization);
		bgm_player.mute = bgm_muted;
		sfx_player.mute = sfx_muted;
		changeState(0);
	}

	private function onError(error:String):Void {
		trace("assets loading failed " + error);
	}

	private function onProgress(ratio:Float):Void {
		trace("assets loading : " + ratio + "%");
	}

	public function changeState(state:Int):Void {
		if (curent_state != null) {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			curent_state.destroy();
			_curent_state = null;
		}

		switch (state) {
			case 0:
				bgm_player.playLoop("game_loop", 0);
				bgm_player.getSound("game_loop").fadeFrom(0, 1, 3000);
				_curent_state = new Lobby();

			case 1:
				_curent_state = new Race();
		}

		addChild(try cast(_curent_state, Sprite) catch (e:Dynamic) null);
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	private function onEnterFrame(event:EnterFrameEvent):Void {
		curent_state.update(event.passedTime);
	}
}
