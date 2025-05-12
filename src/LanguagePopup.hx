import starling.display.Sprite;
import starling.display.Button;
import starling.events.Event;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.core.PopUpManager;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;

class LanguagePopup extends Sprite {
	private var _main_sprite:Sprite;

	public var _close_button:Button;
	public var _main_layout:LayoutGroup;

	public function new() {
		super();
		var ui_object:Dynamic = TurboShift.root_class.asset_manager.getObject("languages_ui");
		_main_sprite = try cast(TurboShift.root_class.ui_builder.create(ui_object, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_close_button.addEventListener(Event.TRIGGERED, onClose);
		_main_layout.addEventListener(TouchEvent.TOUCH, onTouchLayout);
	}

	private function onClose(event:Event):Void {
		PopUpManager.removePopUp(this);
		_close_button.removeEventListener(Event.TRIGGERED, onClose);
	}

	private function onTouchLayout(event:TouchEvent):Void {
		var touch_ended:Touch = event.getTouch(stage, TouchPhase.ENDED);
		var button:Button = try cast(event.target, Button) catch (e:Dynamic) null;
		if (touch_ended != null) {
			trace("button name = " + button.name);
			TurboShift.root_class.locale = button.name;
			_close_button.dispatchEventWith(Event.TRIGGERED, true);
		}
	}
}
