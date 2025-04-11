package treefortress.sound;

import openfl.Lib;
import msignal.Signal;

class SoundTween {
	public var isComplete(get, never):Bool;
	public var sound(get, set):SoundInstance;

	public var startTime:Int;
	public var startVolume:Float;
	public var endVolume:Float;
	public var duration:Float;

	public var isMasterFade:Bool;

	private var _sound:SoundInstance;
	private var _isComplete:Bool;

	public var ended:Signal1<SoundInstance>;
	public var stopAtZero:Bool;

	public function new(si:SoundInstance, endVolume:Float, duration:Float, isMasterFade:Bool = false) {
		if (si != null) {
			sound = si;
			startVolume = sound.volume;
		}

		ended = new Signal1<SoundInstance>();
		this.isMasterFade = isMasterFade;
		init(startVolume, endVolume, duration);
	}

	public function update(t:Int, manager:SoundManager):Bool {
		if (_isComplete) {
			return _isComplete;
		}

		if (isMasterFade) {
			if ((t - startTime) < duration) {
				manager.masterVolume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
			} else {
				manager.masterVolume = endVolume;
			}
			_isComplete = (manager.masterVolume == endVolume);
		} else {
			if ((t - startTime) < duration) {
				sound.volume = easeOutQuad(t - startTime, startVolume, endVolume - startVolume, duration);
			} else {
				sound.volume = endVolume;
			}
			_isComplete = sound.volume == endVolume;
		}
		return _isComplete;
	}

	public function init(startVolume:Float, endVolume:Float, duration:Float):Void {
		this.startTime = Lib.getTimer();
		this.startVolume = startVolume;
		this.endVolume = endVolume;
		this.duration = duration;
		_isComplete = false;
	}

	/** 
	 * End the fade and dispatch ended signal. Optionally, apply the end volume as well. 
	* **/
	public function end(applyEndVolume:Bool = false):Void {
		_isComplete = true;
		if (!isMasterFade) {
			if (applyEndVolume) {
				sound.volume = endVolume;
			}
			if (stopAtZero && sound.volume == 0) {
				sound.stop();
			}
		}
		ended.dispatch(this.sound);
		ended.removeAll();
	}

	/** End the fade silently, will not send 'ended' signal **/
	public function kill():Void {
		_isComplete = true;
		ended.removeAll();
	}

	/**
	 * Equations from the man Robert Penner, see here for more:
	 * http://www.dzone.com/snippets/robert-penner-easing-equations
	 */
	public static function easeOutQuad(position:Float, startValue:Float, change:Float, duration:Float):Float {
		return -change * (position /= duration) * (position - 2) + startValue;
	}

	public static function easeInOutQuad(position:Float, startValue:Float, change:Float, duration:Float):Float {
		if ((position /= duration / 2) < 1) {
			return change / 2 * position * position + startValue;
		}
		return -change / 2 * ((--position) * (position - 2) - 1) + startValue;
	}

	private function get_isComplete():Bool {
		return _isComplete;
	}

	private function get_sound():SoundInstance {
		return _sound;
	}

	private function set_sound(value:SoundInstance):SoundInstance {
		_sound = value;
		if (sound == null) {
			trace("SOUND IS NULLLLL");
		}
		return value;
	}
}
