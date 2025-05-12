import starling.display.Sprite;
import starling.display.Image;
import starling.textures.Texture;
import starling.filters.SineWaveFilter;

class EnemyCar extends Sprite {
	private var _car_image:Image;

	public function new() {
		super();
		_car_image = new Image(getCarTexture());
		addChild(_car_image);
		trace("enemy added");
	}

	public function reset():Void {
		_car_image.texture = getCarTexture();
		this.filter = null;
	}

	private function getCarTexture():Texture {
		return TurboShift.root_class.asset_manager.getTexture("enemy_car_0" + (Math.floor(Math.random() * 5) + 1));
	}

	public function crashed():Void {
		this.filter = new SineWaveFilter(10, 30);
	}

	public function destroy():Void {
		this.filter = null;
		_car_image.removeFromParent(true);
		_car_image = null;
	}
}
