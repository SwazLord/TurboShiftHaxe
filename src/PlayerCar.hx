import starling.display.Sprite;
import starling.filters.SineWaveFilter;
import starlingbuilder.engine.ICustomComponent;
import starling.display.Image;
import starling.core.Starling;

class PlayerCar extends Sprite implements ICustomComponent {
	private var _damaged_filter:SineWaveFilter;
	private var _blazing_fire:BlazingFire;
	private var player_car:Image;

	public function initComponent():Void {
		player_car = try cast(getChildByName("player_car"), Image) catch (e:Dynamic) null;
		_damaged_filter = try cast(player_car.filter, SineWaveFilter) catch (e:Dynamic) null;
		player_car.filter = null;
	}

	public function reset():Void {
		this.rotation = 0;
		player_car.filter = null;
		removeBlazingFire();
	}

	public function crashed():Void {
		player_car.filter = _damaged_filter;
		Starling.current.juggler.delayCall(addBlazingFire, 1);
	}

	private function addBlazingFire():Void {
		_blazing_fire = new BlazingFire();
		addChild(_blazing_fire);
		_blazing_fire.x = 50;
	}

	private function removeBlazingFire():Void {
		_blazing_fire.destroy();
		_blazing_fire.removeFromParent(true);
		_blazing_fire = null;
	}

	public function destroy():Void {
		removeBlazingFire();
		_damaged_filter = null;
		player_car.filter = null;
	}
}
