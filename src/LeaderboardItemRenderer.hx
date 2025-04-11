import feathers.starling.controls.renderers.LayoutGroupListItemRenderer;
import starling.text.TextField;
import starling.display.Sprite;
import starling.utils.Color;

class LeaderboardItemRenderer extends LayoutGroupListItemRenderer {
	public var _rank_text:TextField;
	public var _name_text:TextField;
	public var _score_text:TextField;

	private var _main_sprite:Sprite;

	override private function initialize():Void {
		super.initialize();
		_main_sprite = try cast(Game.current_instance._ui_builder.create(ParsedLayouts.leaderboard_item_ui, true, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);
	}

	override private function commitData():Void {
		if (this._data != null) {
			_rank_text.text = Std.string(this.data.rank);
			_name_text.text = this.data.name;
			_score_text.text = Std.string(this.data.score);

			if (this.data.name == "YOU") {
				_name_text.format.color = Color.RED;
				_score_text.format.color = Color.LIME;
			} else {
				_name_text.format.color = 0x49f0ff;
				_score_text.format.color = 0xfffa39;
			}
		}
	}

	public function new() {
		super();
	}
}
