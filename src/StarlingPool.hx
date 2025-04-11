import openfl.errors.Error;
import starling.display.DisplayObject;

class StarlingPool {
	public var items:Array<Dynamic>;

	private var counter:Int;

	public function new(type:Class<Dynamic>, len:Int) {
		items = new Array<Dynamic>();
		counter = len;

		var i:Int = len;
		while (--i > -1) {
			items[i] = Type.createInstance(type, []);
		}
	}

	public function getSprite():DisplayObject {
		if (counter > 0) {
			return items[--counter];
		} else {
			throw new Error("You exhausted the pool!");
		}
	}

	public function returnSprite(s:DisplayObject):Void {
		items[counter++] = s;
	}

	public function destroy():Void {
		items = null;
	}
}
