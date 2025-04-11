import starling.text.TextFormat;
import starling.utils.Color;
import starling.display.Quad;
import feathers.starling.controls.Toast;
import openfl.events.IOErrorEvent;
import starling.display.Sprite;
import feathers.starling.controls.LayoutGroup;
import starling.display.Image;
import starling.display.MovieClip;
import feathers.starling.controls.ImageLoader;
import starling.display.Button;
import starling.events.Event;
import feathers.starling.core.PopUpManager;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.HorizontalLayout;
import starling.core.Starling;
import starling.animation.DelayedCall;
import starling.animation.Transitions;
import feathers.starling.motion.Wipe;
import feathers.starling.motion.Iris;
import feathers.starling.motion.Fade;

class InfoPopup extends Sprite {
	private var _main_sprite:Sprite;

	public var _main_layout:LayoutGroup;
	public var _air_icon:Image;
	public var _bird_mc:MovieClip;
	public var _feathers_img_loader:ImageLoader;
	public var _awesome_button:Button;

	private var air_rotate_animation:DelayedCall;

	public static var linkers:Array<Dynamic> = [AnchorLayout, HorizontalLayout];

	public function new() {
		super();
		_main_sprite = new Sprite();
		_main_sprite = try cast(Game.current_instance._ui_builder.create(ParsedLayouts.info_popup_ui, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_feathers_img_loader.showEffect = Iris.createIrisOpenEffect();
		_feathers_img_loader.hideEffect = Iris.createIrisCloseEffect();

		_feathers_img_loader.addEventListener(Event.COMPLETE, loader_completeHandler);
		_feathers_img_loader.addEventListener(Event.IO_ERROR, loader_ioErrorHandler);

		_awesome_button.addEventListener(Event.TRIGGERED, onAwesomeButtonTrigger);

		air_rotate_animation = new DelayedCall(animate, 1);
		air_rotate_animation.repeatCount = 0;
	}

	private function animate():Void {
		_feathers_img_loader.visible = !_feathers_img_loader.visible;

		Starling.current.juggler.tween(_air_icon, 1, {
			rotation: _air_icon.rotation += 1,
			transition: Transitions.EASE_IN_OUT_BACK
		});
	}

	private function onAwesomeButtonTrigger(event:Event):Void {
		_awesome_button.removeEventListener(Event.TRIGGERED, onAwesomeButtonTrigger);
		_main_sprite.removeFromParent(true);
		_main_sprite = null;

		PopUpManager.removePopUp(this, true);
	}

	private function loader_completeHandler(event:Event):Void {
		_feathers_img_loader.removeEventListener(Event.COMPLETE, loader_completeHandler);

		_feathers_img_loader.validate();

		_main_layout.validate();

		Starling.current.juggler.add(air_rotate_animation);
		Starling.current.juggler.add(_bird_mc);
	}

	private function loader_ioErrorHandler(event:Event, data:IOErrorEvent):Void {
		trace("loader_ioErrorHandler = ", event.toString());
		Toast.showMessage(Game.current_instance._ui_builder.localization.getLocalizedText("text_14"), 2, getSkinnedToast);
		Starling.current.juggler.add(air_rotate_animation);
		Starling.current.juggler.add(_bird_mc);
	}

	private function getSkinnedToast():Toast {
		var toast:Toast = new Toast();
		toast.backgroundSkin = new Quad(Starling.current.stage.stageWidth, 40, Color.RED);
		toast.fontStyles = new TextFormat("lilita_one", 40, Color.WHITE);
		toast.close(true);
		return toast;
	}
}
