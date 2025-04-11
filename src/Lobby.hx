import starling.utils.Color;
import starling.display.Sprite;
import starling.display.Button;
import starling.text.TextField;
import starling.events.Event;
import starling.core.Starling;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.layout.VerticalLayout;
import starling.animation.Transitions;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.display.DisplayObject;
import feathers.starling.core.PopUpManager;
import starling.display.Image;
import starling.animation.Tween;

class Lobby extends Sprite implements IState {
	private var _main_sprite:Sprite;

	public var _start_button:Button;
	public var _best_score_text:TextField;

	public var _bgm_sprite:ButtonSprite;
	public var _sfx_sprite:ButtonSprite;
	public var _info_button:Button;
	public var _leaderboard_button:Button;
	public var _language_button:Button;
	public var _settings_drop_down:Sprite;
	public var _settings_button:Button;

	private var info_popup:InfoPopup;
	private var leaderboard_popup:LeaderboardPopup;
	private var language_popup:LanguagePopup;
	private var _params:Map<DisplayObject, Dynamic>;

	public var _turbo_shift:Image;

	public static var linkers:Array<Dynamic> = [AnchorLayout, LayoutGroup, VerticalLayout];

	public function new() {
		super();
		trace("Lobby Constructor");
		_main_sprite = new Sprite();
		var data:Dynamic = Game.current_instance._ui_builder.load(ParsedLayouts.lobby_ui, false, this);
		_main_sprite = try cast(data.object, Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_params = data.params;

		_settings_drop_down.y = -250;
		_settings_drop_down.visible = false;

		_best_score_text.text = _best_score_text.text + Game.current_instance.topScore;

		_start_button.addEventListener(Event.TRIGGERED, onStartButtonTrigger);
		_settings_button.addEventListener(Event.TRIGGERED, onSettingsTrigger);
		_leaderboard_button.addEventListener(Event.TRIGGERED, onLeaderboardTrigger);
		_language_button.addEventListener(Event.TRIGGERED, onLanguageTrigger);

		_bgm_sprite.disabled = Game.current_instance.bgm_muted;
		_sfx_sprite.disabled = Game.current_instance.sfx_muted;

		var shift_tween:Tween = new Tween(_turbo_shift, 3, Transitions.EASE_IN_OUT);
		shift_tween.reverse = true;
		shift_tween.repeatCount = 0;
		shift_tween.animate("x", 90);
		Starling.current.juggler.add(shift_tween);
	}

	public function update():Void {
		Game.current_instance._ui_builder.localizeTexts(_main_sprite, _params);

		_best_score_text.text = Game.current_instance._ui_builder.localization.getLocalizedText("text_02") + Game.current_instance.topScore;
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_start_button.removeEventListener(Event.TRIGGERED, onStartButtonTrigger);
		trace("Lobby Destroyed");
	}

	private function onStartButtonTrigger(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");
		Game.current_instance.changeState(1);
	}

	private function onSettingsTrigger(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");

		if (_settings_drop_down.visible == false) {
			_settings_drop_down.visible = true;
			Starling.current.juggler.tween(_settings_drop_down, 0.2, {
				y: 50,
				transition: Transitions.EASE_OUT_BACK,
				onComplete: this.addEventListener,
				onCompleteArgs: ([TouchEvent.TOUCH, onTouchStage] : Array<Dynamic>)
			});
		}
	}

	private function onTouchStage(event:TouchEvent):Void {
		var touch_ended:Touch = event.getTouch(stage, TouchPhase.ENDED);
		if (touch_ended != null) {
			var targetObject:DisplayObject = try cast(event.target, DisplayObject) catch (e:Dynamic) null;
			trace("user touched ", targetObject.name);

			if (targetObject.name == "_bgm_sprite") {
				Game.current_instance._sfxPlayer.playFx("button_click");
				_bgm_sprite.disabled = !_bgm_sprite.disabled;
				Game.current_instance.bgm_muted = !Game.current_instance.bgm_muted;
			} else if (targetObject.name == "_sfx_sprite") {
				Game.current_instance._sfxPlayer.playFx("button_click");
				_sfx_sprite.disabled = !_sfx_sprite.disabled;
				Game.current_instance.sfx_muted = !Game.current_instance.sfx_muted;
			} else if (targetObject.name == "_info_button") {
				info_popup = new InfoPopup();
				info_popup.addEventListener(Event.REMOVED_FROM_STAGE, onInfoPopupRemoved);
				PopUpManager.addPopUp(info_popup);
				hideDroDown();
			} else {
				hideDroDown();
			}
		}
	}

	public function hideDroDown():Void {
		this.removeEventListener(TouchEvent.TOUCH, onTouchStage);

		Starling.current.juggler.tween(_settings_drop_down, 0.2, {
			y: -250,
			transition: Transitions.EASE_IN_OUT_BACK,
			onComplete: function():Void {
				_settings_drop_down.visible = false;
			}
		});
	}

	private function onInfoPopupRemoved(event:Event):Void {
		info_popup.removeEventListener(Event.REMOVED_FROM_STAGE, onInfoPopupRemoved);
		info_popup = null;
	}

	private function onLeaderboardTrigger(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");
		leaderboard_popup = new LeaderboardPopup();
		leaderboard_popup.addEventListener(Event.REMOVED_FROM_STAGE, onLeaderboardPopupRemoved);
		PopUpManager.addPopUp(leaderboard_popup);
	}

	private function onLeaderboardPopupRemoved(event:Event):Void {
		leaderboard_popup.removeEventListener(Event.REMOVED_FROM_STAGE, onLeaderboardPopupRemoved);
		leaderboard_popup.destroy();
		leaderboard_popup = null;
	}

	private function onLanguageTrigger(event:Event):Void {
		Game.current_instance._sfxPlayer.playFx("button_click");
		language_popup = new LanguagePopup();
		language_popup.addEventListener(Event.REMOVED_FROM_STAGE, onLanguagePopupRemoved);
		PopUpManager.addPopUp(language_popup);
	}

	private function onLanguagePopupRemoved(event:Event):Void {
		language_popup.removeEventListener(Event.REMOVED_FROM_STAGE, onLanguagePopupRemoved);
		language_popup.destroy();
		language_popup = null;
	}
}
