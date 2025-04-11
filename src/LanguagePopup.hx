import starling.display.Sprite;
import starling.display.Button;
import starling.events.Event;
import feathers.starling.core.PopUpManager;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.controls.LayoutGroup;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;

class LanguagePopup extends Sprite {
	private var _main_sprite:Sprite;

	public var _close_button:Button;
	public var _main_layout:LayoutGroup;

	public static var linkers:Array<Dynamic> = [AnchorLayout, VerticalLayout];

	public function new() {
		super();
		_main_sprite = new Sprite();
		_main_sprite = try cast(Game.current_instance._ui_builder.create(ParsedLayouts.language_popup_ui, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_close_button.addEventListener(Event.TRIGGERED, onClose);
		_main_layout.addEventListener(TouchEvent.TOUCH, onTouch);
	}

	private function onTouch(event:TouchEvent):Void {
		var touch_ended:Touch = event.getTouch(stage, TouchPhase.ENDED);
		var button:Button = try cast(event.target, Button) catch (e:Dynamic) null;
		if (touch_ended != null && button != null) {
			trace("button.name = ", button.name);
			Game.current_instance.locale = button.name;
			_close_button.dispatchEventWith(Event.TRIGGERED, true);
		}
	}

	private function onClose(event:Event):Void {
		_close_button.removeEventListener(Event.TRIGGERED, onClose);
		PopUpManager.removePopUp(this, true);
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;
	}
}
