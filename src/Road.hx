import starling.display.Sprite;
import starling.display.Image;

class Road extends Sprite {
	private var _main_sprite:Sprite;

	public var _road_1:Image;
	public var _road_2:Image;

	public function new() {
		super();
		var ui_object:Dynamic = TurboShift.root_class.asset_manager.getObject("road_ui");
		_main_sprite = try cast(TurboShift.root_class.ui_builder.create(ui_object, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);
		_road_2.y = -960;
	}

	public function update(speed:Float):Void {
		_road_1.y += speed * _road_1.height / 20;
		_road_2.y += speed * _road_1.height / 20;

		if (_road_1.y >= _road_1.height) {
			_road_1.y = -_road_1.height;
		}

		if (_road_2.y >= _road_2.height) {
			_road_2.y = -_road_1.height;
		}
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;
	}
}
