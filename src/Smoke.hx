import starling.display.Sprite;
import com.funkypandagame.stardustplayer.SimPlayer;
import com.funkypandagame.stardustplayer.SimLoader;
import com.funkypandagame.stardustplayer.project.ProjectValueObject;
import openfl.events.Event;
import starling.events.Event;
import starling.events.EnterFrameEvent;

class Smoke extends Sprite {
	private var _sim_container:Sprite;
	private var _player:SimPlayer;
	private var _loader:SimLoader;
	private var _project:ProjectValueObject;

	public function new() {
		super();
		_sim_container = new Sprite();
		addChild(_sim_container);

		_loader = new SimLoader();
		_loader.addEventListener(flash.events.Event.COMPLETE, onSimulationLoaded);
		_loader.loadSim(TurboShift.root_class.asset_manager.getByteArray("smoke"));

		_player = new SimPlayer();
	}

	private function onSimulationLoaded(event:Dynamic):Void {
		_loader.removeEventListener(flash.events.Event.COMPLETE, onSimulationLoaded);
		_project = _loader.createProjectInstance();
		_player.setProject(_project);
		_player.setRenderTarget(_sim_container);
		addEventListener(starling.events.Event.ENTER_FRAME, onEnterFrame);
		_project.resetSimulation();
	}

	private function onEnterFrame(event:EnterFrameEvent):Void {
		_player.stepSimulation(event.passedTime);
	}

	public function destroy():Void {
		removeEventListener(starling.events.Event.ENTER_FRAME, onEnterFrame);
		_player = null;
		_project.destroy();
		_project = null;
		_loader.dispose();
		_loader = null;
		_sim_container.removeFromParent(true);
		_sim_container = null;
	}
}
