import starling.display.Sprite;
import starlingbuilder.engine.ICustomComponent;
import starling.display.Image;
import starling.core.Starling;
import starling.filters.SineWaveFilter;

class PlayerCar extends Sprite implements ICustomComponent {
	private var car_image:Image;
	private var blazing_fire:BlazingFire;
	private var damaged_filter:SineWaveFilter;

	public function initComponent():Void {
		car_image = try cast(getChildByName("player_car"), Image) catch (e:Dynamic) null;
		damaged_filter = try cast(car_image.filter, SineWaveFilter) catch (e:Dynamic) null;
		car_image.filter = null;
	}

	public function reset():Void {
		this.rotation = 0;

		car_image.filter = null;

		if (blazing_fire != null) {
			blazing_fire.destroy();
			blazing_fire.removeFromParent(true);
			blazing_fire = null;
		}
	}

	public function crashed():Void {
		car_image.filter = damaged_filter;

		Starling.current.juggler.delayCall(function():Void {
			blazing_fire = new BlazingFire();
			addChild(blazing_fire);
			blazing_fire.x = 50;
		}, 1);
	}

	public function destroy():Void {
		blazing_fire.destroy();
		blazing_fire.removeFromParent(true);
		blazing_fire = null;

		car_image.filter = null;
		damaged_filter = null;
	}

	public function new() {
		super();
	}
}
