import starling.display.Sprite;
import starling.display.Button;
import feathers.starling.controls.List;
import starling.events.Event;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.core.PopUpManager;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.VerticalLayout;

class LeaderboardPopup extends Sprite {
	private var _main_sprite:Sprite;

	public var _close_button:Button;
	public var _list:List;

	private var _leaderboard:Array<Dynamic> = [
		{
			name: "JACK",
			score: 500
		},
		{
			name: "MAX",
			score: 450
		},
		{
			name: "ADAM",
			score: 390
		},
		{
			name: "BILL",
			score: 420
		},
		{
			name: "SAM",
			score: 350
		},
		{
			name: "TIM",
			score: 250
		},
		{
			name: "BEN",
			score: 120
		},
		{
			name: "PAT",
			score: 90
		},
		{
			name: "JEFF",
			score: 50
		},
		{
			name: "PEG",
			score: 40
		}
	];

	public static var linkers:Array<Dynamic> = [AnchorLayout, VerticalLayout];

	public function new() {
		super();
		_main_sprite = new Sprite();
		_main_sprite = try cast(Game.current_instance._ui_builder.create(ParsedLayouts.leaderboard_popup_ui, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		_close_button.addEventListener(Event.TRIGGERED, onClose);

		_list.isSelectable = false;

		_list.itemRendererFactory = function():IListItemRenderer {
			return new LeaderboardItemRenderer();
		};

		// Add player score
		_leaderboard.push({
			name: "YOU",
			score: Game.current_instance.topScore
		});

		// Sort the array by score in descending order
		_leaderboard.sort(function(a:Dynamic, b:Dynamic):Int {
			if (a.score > b.score) {
				return -1;
			}
			if (a.score < b.score) {
				return 1;
			}
			return 0;
		});

		_list.dataProvider = new ArrayCollection();

		var len:Int = _leaderboard.length;
		for (i in 0...len) {
			var player:Dynamic = _leaderboard[i];
			_list.dataProvider.addItem({
				rank: i + 1,
				name: player.name,
				score: player.score
			});
		}
	}

	private function onClose(event:Event):Void {
		_close_button.removeEventListener(Event.TRIGGERED, onClose);
		Game.current_instance._sfxPlayer.playFx("button_click");
		PopUpManager.removePopUp(this);
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;

		_leaderboard = [];

		_list.removeFromParent(true);
		_list = null;
	}
}
