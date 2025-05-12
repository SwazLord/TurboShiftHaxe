import starling.utils.Color;
import openfl.display.Sprite;
import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;
import starling.utils.RectangleUtil;
import openfl.geom.Rectangle;
import starling.utils.ScaleMode;

class TurboShift extends Sprite {
	private var _starling:Starling;

	private static var _root_class:Game;
	public static var root_class(get, never):Game;

	private static function get_root_class():Game {
		return _root_class;
	}

	public function new() {
		super();
		stage.color = Color.BLACK;
		trace("Hello Turbo Shift");
		_starling = new Starling(Game, stage);
		_starling.addEventListener(Event.ROOT_CREATED, onRootCreated);
		// _starling.showStats = true;
		_starling.supportHighResolutions = true;
		_starling.start();
		_starling.stage.addEventListener(Event.RESIZE, onStageResize);
	}

	private function onRootCreated(event:Event, root_instance:Game):Void {
		_starling.removeEventListener(Event.ROOT_CREATED, onRootCreated);
		_root_class = root_instance;
	}

	private function onStageResize(event:ResizeEvent):Void {
		Starling.current.viewPort = RectangleUtil.fit(new Rectangle(0, 0, 640, 960), new Rectangle(0, 0, event.width, event.height), ScaleMode.SHOW_ALL);
	}
}
