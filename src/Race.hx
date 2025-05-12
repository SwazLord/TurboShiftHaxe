import starling.display.Sprite;
import starling.core.Starling;
import feathers.starling.controls.LayoutGroup;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import starling.animation.DelayedCall;
import starling.animation.Tween;
import starling.text.TextField;
import feathers.starling.core.PopUpManager;
import treefortress.sound.SoundManager;
import treefortress.sound.SoundInstance;

class Race extends Sprite implements IState {
	private var _current_speed:Float;
	private var _road:Road;

	public var _main_layout:LayoutGroup;
	public var _player_car:PlayerCar;

	private var _main_sprite:Sprite;
	private var _lane_positions:Array<Dynamic> = [];
	private var _player_car_lane:Int;
	private var _enemy_pool:StarlingPool;
	private var _current_enemy_car:EnemyCar;
	private var _active_enemies:Array<Dynamic> = [];
	private var _game_over:Bool;
	private var _big_explosion:BigExplosion;
	private var _increase_speed:DelayedCall;
	private var _turbo_shift_tween:Tween;

	public var _score_label:TextField;
	public var _score_text:TextField;

	private var _current_score:Int;
	private var _game_over_popup:GameOverPopup;
	private var _audio_player:SoundManager;
	private var _new_high_score:Bool;
	private var _smoke:Smoke;

	public function new() {
		super();
		trace("race state initiated");
		_audio_player = new SoundManager();
		_road = new Road();
		addChild(_road);

		_increase_speed = new DelayedCall(updateSpeed, 1);
		_increase_speed.repeatCount = 0; // repeats indefinitely

		var ui_object:Dynamic = TurboShift.root_class.asset_manager.getObject("race_ui");
		_main_sprite = try cast(TurboShift.root_class.ui_builder.create(ui_object, false, this), Sprite) catch (e:Dynamic) null;
		addChild(_main_sprite);

		var lane_width:Float = _main_layout.width / 2;
		_lane_positions = [lane_width / 2, lane_width + lane_width / 2];
		_player_car_lane = 0;

		_enemy_pool = new StarlingPool(EnemyCar, 5);

		_big_explosion = new BigExplosion();
		_audio_player.mute = TurboShift.root_class.sfx_muted;
		_audio_player.loadSound("assets/sounds/car_loop.mp3", "car_loop");
		_audio_player.loadSound("assets/sounds/big_explosion.mp3", "big_explosion");
		_audio_player.loadSound("assets/sounds/change_lane.mp3", "change_lane");
		_audio_player.loadSound("assets/sounds/new_high_score.mp3", "new_high_score");

		startRace();
	}

	private function startRace():Void {
		_audio_player.playLoop("car_loop", 0);
		_audio_player.getSound("car_loop").fadeFrom(0, 1, 3000);
		TurboShift.root_class.bgm_player.getSound("game_loop").fadeTo(0.5);
		_current_score = 0;
		_current_speed = 5; // starting speed
		_new_high_score = _game_over = false;
		Starling.current.juggler.add(_increase_speed);
		_player_car.x = _lane_positions[_player_car_lane];
		addEventListener(TouchEvent.TOUCH, onScreenTouch);
		updateScore(0);
		spawnEnemy();
		_smoke = new Smoke();
		_main_layout.addChildAt(_smoke, 0);
	}

	public function resetRace():Void {
		for (enemy in _active_enemies) {
			enemy.y = -enemy.height;
			enemy.reset();
			_enemy_pool.returnSprite(enemy);
		}

		_active_enemies = [];
		_player_car.reset();

		removeGameOverPopup();

		startRace();
	}

	public function quitRace():Void {
		removeGameOverPopup();
		TurboShift.root_class.changeState(0);
	}

	private function spawnEnemy():Void {
		_current_enemy_car = try cast(_enemy_pool.getSprite(), EnemyCar) catch (e:Dynamic) null;
		_current_enemy_car.reset();
		_current_enemy_car.alignPivot();
		_current_enemy_car.x = _lane_positions[Math.floor(Math.random() * 2)];
		_current_enemy_car.y = _current_enemy_car.height * -(Math.floor(Math.random() * 4) + 1); // add randomness to enemy car's starting position
		_active_enemies.push(_current_enemy_car);
		_main_layout.addChildAt(_current_enemy_car, 0);
	}

	public function update(timePassed:Float):Void {
		if (_game_over == false) {
			_road.update(_current_speed * timePassed);

			_smoke.x = _player_car.x + _player_car.width / 8;
			_smoke.y = _player_car.y + _player_car.height / 4;

			var len:Int = _active_enemies.length;
			var i:Int = Std.int(len - 1);
			var enemy:EnemyCar = null;
			while (i >= 0) {
				enemy = _active_enemies[i];
				enemy.y += _current_speed * timePassed * 60;

				if (enemy.y > _main_layout.height + enemy.height) {
					_active_enemies.splice(i, 1);
					_main_layout.removeChild(enemy);
					_enemy_pool.returnSprite(enemy);
					spawnEnemy();
					updateScore(10);
				}

				if (_player_car.bounds.intersects(enemy.bounds)) {
					removeEventListener(TouchEvent.TOUCH, onScreenTouch);
					Starling.current.juggler.remove(_increase_speed);
					Starling.current.juggler.remove(_turbo_shift_tween);
					var collision_area:Rectangle = _player_car.bounds.intersection(enemy.bounds);
					var collision_point:Point = new Point(collision_area.x + collision_area.width / 2, collision_area.y + collision_area.height / 2);
					trace("collision took place");
					_audio_player.getSound("car_loop").fadeTo(0).soundCompleted.add(function(si:SoundInstance):Void {
						_audio_player.pause("car_loop");
					});
					_main_layout.addChild(_big_explosion);
					_big_explosion.x = collision_point.x;
					_big_explosion.y = collision_point.y;
					_big_explosion.play();
					_audio_player.playFx("big_explosion");
					_player_car.crashed();
					_smoke.destroy();
					_smoke.removeFromParent(true);
					_smoke = null;
					enemy.crashed();
					_game_over = true;
					Starling.current.juggler.delayCall(displayGameOverPopup, 3);
					Starling.current.juggler.tween(this, 0.3, {
						x: this.x + 10,
						transition: Animations.SHAKE_3X
					});

					if (_current_score > TurboShift.root_class.best_score) {
						TurboShift.root_class.best_score = _current_score;
						trace("new best score - updated");
					}
				}

				i--;
			}
		}
	}

	private function displayGameOverPopup():Void {
		TurboShift.root_class.bgm_player.getSound("game_loop").fadeFrom(0.5, 1, 3000);
		_game_over_popup = new GameOverPopup(_current_score);
		PopUpManager.addPopUp(_game_over_popup);
	}

	private function removeGameOverPopup():Void {
		PopUpManager.removePopUp(_game_over_popup);
		_game_over_popup = null;
	}

	private function updateScore(val:Int):Void {
		_current_score += val;
		_score_text.text = Std.string(_current_score);

		if (_new_high_score == false && (_current_score > TurboShift.root_class.best_score)) {
			_new_high_score = true;
			_audio_player.playFx("new_high_score");
		}
	}

	private function updateSpeed():Void {
		_current_speed += 1;
	}

	public function destroy():Void {
		_main_sprite.removeFromParent(true);
		_main_sprite = null;

		_road.destroy();
		_road.removeFromParent(true);
		_road = null;

		_big_explosion.destroy();
		_big_explosion.removeFromParent(true);
		_big_explosion = null;

		_player_car.destroy();
		_player_car.removeFromParent(true);
		_player_car = null;

		for (enemy in _active_enemies) {
			enemy.destroy();
			enemy.removeFromParent(true);
		}

		_enemy_pool = null;
		_lane_positions = _active_enemies = [];

		this.removeFromParent(true);

		trace("race state  destroyed");
	}

	private function onScreenTouch(event:TouchEvent):Void {
		var touch_ended:Touch = event.getTouch(stage, TouchPhase.ENDED);
		if (touch_ended != null) {
			_player_car_lane = (_player_car_lane == 0) ? 1 : 0; // switch to opposite lane
			// _player_car.x = _lane_positions[_player_car_lane];
			var rotation:Float = (_player_car_lane == 1) ? 0.2 : -0.2;
			_turbo_shift_tween = new Tween(_player_car, 0.1);
			_turbo_shift_tween.animate("x", _lane_positions[_player_car_lane]);
			_turbo_shift_tween.animate("rotation", rotation);
			_turbo_shift_tween.onComplete = function():Void {
				var reset_tween:Tween = new Tween(_player_car, 0.05);
				reset_tween.animate("rotation", 0);
				Starling.current.juggler.add(reset_tween);
			};
			Starling.current.juggler.add(_turbo_shift_tween);
			_audio_player.playFx("change_lane");
		}
	}
}
