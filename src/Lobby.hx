import starling.display.Sprite;
import starling.display.Button;
import starling.events.Event;
import feathers.starling.controls.LayoutGroup;
import starling.display.Image;
import openfl.geom.Rectangle;
import starling.text.TextField;
import feathers.starling.core.PopUpManager;
import starling.core.Starling;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.display.DisplayObject;
import starling.events.TouchPhase;
import openfl.utils.Dictionary;
import starling.display.MovieClip;

class Lobby extends Sprite implements IState {
	private var _main_sprite:Sprite;

	public var _start_button:Button;
	public var _root_layout:LayoutGroup;

	private var _tile_image:Image;
	private var _scroll_rect:Rectangle;

	public var _best_score_text:TextField;
	public var _leaderboard_button:Button;
	public var _settings_button:Button;
	public var _info_button:Button;
	public var _settings_drop_down:Sprite;
	public var _bgm_sprite:ButtonSprite;
	public var _sfx_sprite:ButtonSprite;

	private var _leaderboard_popup:LeaderboardPopup;
	private var _languages_popup:LanguagePopup;
	private var _ui_params:Map<DisplayObject, Dynamic>;

	public var _bird_mc:MovieClip;

	public function new() {
		super();
		trace("lobby state initiated");
		var ui_object:Dynamic = TurboShift.root_class.asset_manager.getObject("lobby_ui");
		var ui_data:Dynamic = TurboShift.root_class.ui_builder.load(ui_object, false, this);
		_ui_params = ui_data.params;
		_main_sprite = try cast(ui_data.object, Sprite) catch (e:Dynamic) null;
		// _main_sprite = TurboShift.root_class.ui_builder.create(ui_object, false, this) as Sprite;
		addChild(_main_sprite);
		_start_button.addEventListener(Event.TRIGGERED, onStartButtonTriggered);
		_leaderboard_button.addEventListener(Event.TRIGGERED, onLeaderboardTriggered);
		_settings_button.addEventListener(Event.TRIGGERED, onSettingsTriggered);
		_info_button.addEventListener(Event.TRIGGERED, onInfoButtonTriggered);
		_tile_image = try cast(_root_layout.backgroundSkin, Image) catch (e:Dynamic) null;
		_scroll_rect = _tile_image.tileGrid;
		_best_score_text.text = _best_score_text.text + Std.string(TurboShift.root_class.best_score);
		_settings_drop_down.y = -270;
		_settings_drop_down.visible = false;
		_bgm_sprite.disabled = TurboShift.root_class.bgm_muted;
		_sfx_sprite.disabled = TurboShift.root_class.sfx_muted;
		TurboShift.root_class.asset_manager.playSound("game_loop", 0, 999);
		Starling.current.juggler.add(_bird_mc);
	}

	public function update(timePassed:Float):Void {
		_scroll_rect.y += 2;
		_tile_image.tileGrid = _scroll_rect;
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;
		_start_button.removeEventListener(Event.TRIGGERED, onStartButtonTriggered);
		this.removeFromParent(true);
		trace("lobby state destroyed");
	}

	private function onStartButtonTriggered(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		TurboShift.root_class.changeState(1);
	}

	private function onLeaderboardTriggered(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		_leaderboard_popup = new LeaderboardPopup();
		PopUpManager.addPopUp(_leaderboard_popup);
	}

	private function onSettingsTriggered(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		if (_settings_drop_down.visible == false) {
			_settings_drop_down.visible = true;
			Starling.current.juggler.tween(_settings_drop_down, 0.2, {
				y: 50,
				onComplete: addEventListener,
				onCompleteArgs: ([TouchEvent.TOUCH, onTouchStage] : Array<Dynamic>)
			});
		}
	}

	private function onTouchStage(event:TouchEvent):Void {
		var touch_ended:Touch = event.getTouch(stage, TouchPhase.ENDED);
		if (touch_ended != null) {
			var targetObject:DisplayObject = try cast(event.target, DisplayObject) catch (e:Dynamic) null;
			trace("user touched - " + targetObject.name);

			if (targetObject.name == "_bgm_sprite") {
				_bgm_sprite.disabled = !_bgm_sprite.disabled;
				TurboShift.root_class.bgm_muted = !TurboShift.root_class.bgm_muted;
			} else if (targetObject.name == "_sfx_sprite") {
				_sfx_sprite.disabled = !_sfx_sprite.disabled;
				TurboShift.root_class.sfx_muted = !TurboShift.root_class.sfx_muted;
			} else {
				removeSettingsDropDown();
			}
		}
	}

	private function removeSettingsDropDown():Void {
		removeEventListener(TouchEvent.TOUCH, onTouchStage);

		Starling.current.juggler.tween(_settings_drop_down, 0.1, {
			y: -250,
			onComplete: function():Void {
				_settings_drop_down.visible = false;
			}
		});
	}

	private function onInfoButtonTriggered(event:Event):Void {
		TurboShift.root_class.sfx_player.playFx("button_click");
		_languages_popup = new LanguagePopup();
		PopUpManager.addPopUp(_languages_popup);
	}

	public function localize():Void {
		TurboShift.root_class.ui_builder.localizeTexts(_main_sprite, _ui_params);
		_best_score_text.text = TurboShift.root_class.ui_builder.localization.getLocalizedText("text_02") + Std.string(TurboShift.root_class.best_score);
	}
}
