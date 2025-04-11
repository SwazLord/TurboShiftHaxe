import openfl.Assets;
import treefortress.sound.SoundInstance;
import starling.display.Sprite;
import starling.assets.AssetManager;
import starlingbuilder.engine.UIBuilder;
import starlingbuilder.engine.DefaultAssetMediator;
import feathers.starling.controls.LayoutGroup;
import starling.display.Image;
import feathers.starling.layout.AnchorLayout;
import starlingbuilder.engine.LayoutLoader;
import openfl.net.SharedObject;
import treefortress.sound.SoundManager;
import starlingbuilder.engine.localization.ILocalization;
import openfl.system.Capabilities;
import starlingbuilder.engine.localization.DefaultLocalization;

class Game extends Sprite {
	public var topScore(get, set):Int;
	public var bgm_muted(get, set):Bool;
	public var sfx_muted(get, set):Bool;
	public var locale(get, set):String;

	public var _asst_manager:AssetManager;
	public var _ui_builder:UIBuilder;

	private var _asst_mediator:DefaultAssetMediator;

	public static var linkers:Array<Dynamic> = [LayoutGroup, Image, AnchorLayout];

	public var _current_state:IState;

	public static var current_instance:Game;

	private var _layout_loader:LayoutLoader;
	private var _sharedObject:SharedObject;
	private var _topScore:Int;

	public var _bgmPlayer:SoundManager = new SoundManager();
	public var _sfxPlayer:SoundManager = new SoundManager();

	private var _bgm_muted:Bool;
	private var _sfx_muted:Bool;
	private var _localization:ILocalization;
	private var _locale:String;
	private var SUPPORTED_LOCALES(default, never):Array<Dynamic> = ["en", "fr", "de"];

	public function new() {
		super();
		trace("game class contructor");
		_sharedObject = SharedObject.getLocal("turbo-shift-data");
		current_instance = this;
		Animations.registerTransitions();
	}

	public function startGame():Void {
		trace("start Game");
		_asst_manager = new AssetManager();
		_asst_manager.verbose = true;
		_asst_manager.enqueue([
			"assets/textures/texture.png",
			"assets/textures/texture.xml",
			"assets/textures/lilita_one.png",
			"assets/textures/lilita_one.fnt",
			"assets/backgrounds/road_tile.png",
			"assets/particles/bigExplosion.sde",
			"assets/particles/blazingFire.sde",
			"assets/particles/pinkSmoke.sde",
			"assets/localization/strings.json"
		]);
		_asst_manager.loadQueue(onComplete, onError, onProgress);

		// Wait for loading to complete before playing
		_bgmPlayer.loadCompleted.add(function(si:SoundInstance) {
			if (si.type == "game_loop") {
				_bgmPlayer.playLoop("game_loop", 0);
				_bgmPlayer.getSound("game_loop").fadeFrom(0, 1, 3000);
			}
		});
		_bgmPlayer.loadSound("assets/sounds/game_loop.mp3", "game_loop");
		_sfxPlayer.loadSound("assets/sounds/button_click.mp3", "button_click");
	}

	private function onComplete():Void {
		trace("ASSET LOADED");
		_localization = new DefaultLocalization(_asst_manager.getObject("strings"), locale);
		_layout_loader = new LayoutLoader(ParsedLayouts);
		_asst_mediator = new DefaultAssetMediator(_asst_manager);
		_ui_builder = new UIBuilder(_asst_mediator, false, null, _localization);
		_bgmPlayer.mute = bgm_muted;
		_sfxPlayer.mute = sfx_muted;
		changeState(0);
	}

	private function onError(error:String):Void {
		trace("ERROR : " + error);
	}

	private function onProgress(ratio:Float):Void {
		trace("PROGRESS : " + ratio);
	}

	public function changeState(state:Int):Void {
		if (_current_state != null) {
			_current_state.destroy();
			_current_state = null;
		}

		switch (state) {
			case 0:
				_current_state = new Lobby();
			case 1:
				_current_state = new RaceGame();
		}

		addChild(cast(_current_state, Sprite));
	}

	private function get_topScore():Int {
		if (_sharedObject.data.topScore == null) {
			return 0;
		} else {
			return Std.int(_sharedObject.data.topScore);
		}
	}

	private function set_topScore(value:Int):Int {
		_sharedObject.setProperty("topScore", value);
		_sharedObject.flush();
		return value;
	}

	private function get_bgm_muted():Bool {
		if (_sharedObject.data.bgm_muted == null) {
			return false;
		} else {
			return _sharedObject.data.bgm_muted;
		}
	}

	private function set_bgm_muted(value:Bool):Bool {
		_bgmPlayer.mute = value;
		_sharedObject.setProperty("bgm_muted", value);
		_sharedObject.flush();
		return value;
	}

	private function get_sfx_muted():Bool {
		if (_sharedObject.data.sfx_muted == null) {
			return false;
		} else {
			return _sharedObject.data.sfx_muted;
		}
	}

	private function set_sfx_muted(value:Bool):Bool {
		_sfxPlayer.mute = value;
		_sharedObject.setProperty("sfx_muted", value);
		_sharedObject.flush();
		return value;
	}

	private function get_locale():String {
		if (Lambda.indexOf(SUPPORTED_LOCALES, Capabilities.language) != -1) {
			return Capabilities.language;
		} else {
			return "en";
		}
	}

	private function set_locale(value:String):String {
		_localization.locale = _locale = value;
		_current_state.update();
		return value;
	}
}
