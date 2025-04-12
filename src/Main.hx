import openfl.display.Sprite;
import openfl.events.Event;
import starling.core.Starling;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.display.StageDisplayState;
import starling.utils.Color;
import starling.events.Event;
import openfl.geom.Rectangle;
import starlingbuilder.engine.util.StageUtil;
import openfl.geom.Point;
import starling.events.ResizeEvent;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;

class Main extends Sprite {
	private var _starling:Starling;
	private var _stage_util:StageUtil;
	private var _root_class:Game;

	public function new() {
		super();
		addEventListener(flash.events.Event.ADDED_TO_STAGE, addedToStage);
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.displayState = StageDisplayState.NORMAL;
		stage.color = Color.BLACK;
	}

	private function addedToStage(event:flash.events.Event):Void {
		removeEventListener(flash.events.Event.ADDED_TO_STAGE, addedToStage);
		trace("added to stage");
		_starling = new Starling(Game, stage, null, null, "auto", ["baselineExtended", "baseline"]);
		_starling.stage3D.addEventListener(starling.events.Event.CONTEXT3D_CREATE, startStarling);
		_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
	}

	private function startStarling(event:flash.events.Event):Void {
		_starling.stage3D.removeEventListener(starling.events.Event.CONTEXT3D_CREATE, startStarling);
		_starling.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		_stage_util = new StageUtil(stage);
		var size:Point = _stage_util.getScaledStageSize(_stage_util.stageWidth, _stage_util.stageHeight);
		_starling.stage.stageWidth = Std.int(size.x);
		_starling.stage.stageHeight = Std.int(size.y);
		_starling.supportHighResolutions = true;
		_starling.antiAliasing = 1;
		// _starling.showStats = true;
		_starling.start();
		_starling.stage.addEventListener(starling.events.Event.RESIZE, onResize);
	}

	private function onRootCreated(event:starling.events.Event, root:Game):Void {
		_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		trace("root created");
		_root_class = root;
		_root_class.startGame();
	}

	private function onResize(event:ResizeEvent):Void {
		var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, 640, 960), new Rectangle(0, 0, event.width, event.height), ScaleMode.SHOW_ALL);

		Starling.current.viewPort = viewPort;
	}
}
