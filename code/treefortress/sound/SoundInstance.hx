package treefortress.sound;

import msignal.Signal;
import openfl.errors.Error;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * Controls playback of a single sound. Comes with convenience methods for all the common Sound APIs (pause, resume, set position, volume etc). This can be used in a modular fashion if all you need is a simple wrapper around the Sound class.
 */
class SoundInstance {
	public var enableSeamlessLoops(get, never):Bool;
	public var fade(get, never):SoundTween;
	public var mute(get, set):Bool;
	public var isPlaying(get, never):Bool;
	public var mixedVolume(get, never):Float;
	public var isPaused(get, never):Bool;
	public var position(get, set):Float;
	public var volume(get, set):Float;
	public var pan(get, set):Float;
	public var masterVolume(get, set):Float;
	public var loopsRemaining(get, never):Int;
	public var soundTransform(get, set):SoundTransform;

	public var manager:SoundManager;

	/**
	 * Registered type for this Sound
	 */
	public var type:String;

	/**
	 * URL this sound was loaded from. This is null if the sound was not loaded by SoundHX
	 */
	public var url:String;

	/**
	 * Current instance of Sound object
	 */
	public var sound:Sound;

	/**
	 * Current playback channel
	 */
	public var channel:SoundChannel;

	/**
	 * Dispatched when playback has completed
	 */
	public var soundCompleted:Signal1<SoundInstance>;

	/**
	 * Number of times to loop this sound. Pass -1 to loop forever.
	 */
	public var loops:Int;

	/**
	 * Allow multiple concurrent instances of this Sound. If false, only one instance of this sound will ever play.
	 */
	public var allowMultiple:Bool;

	/**
	 * Orphaned channels that are in the process of playing out. These will only exist when: allowMultiple = true
	 */
	public var oldChannels:Array<SoundChannel>;

	private var _loopsRemaining:Int;
	private var _muted:Bool;
	private var _volume:Float;
	private var _pan:Float;
	private var _enableSeamlessLoops:Bool;
	private var pauseTime:Float;
	private var _isPlaying:Bool;

	private var _soundTransform:SoundTransform;
	@:allow(treefortress.sound)
	private var currentTween:SoundTween;

	public function new(sound:Sound = null, type:String = null) {
		this.sound = sound;
		this.type = type;
		manager = SoundHX.manager;
		pauseTime = 0;
		_volume = 1;
		_pan = 0;
		_soundTransform = new SoundTransform();
		soundCompleted = new Signal1<SoundInstance>();
		oldChannels = [];
	}

	/**
	 * When is is enabled, you will have seamless looping of your sound files (assuming they are encoded properly), but will experience issues when pausing/resuming them.
	 * The bug is detailed here: http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/. As a workaround, always stop your looping sounds and start over, do not try and resume. 
	 */
	private function get_enableSeamlessLoops():Bool {
		return _enableSeamlessLoops;
	}

	/**
	 * Play this Sound 
	 * @param volume
	 * @param startTime Start position in milliseconds
	 * @param loops Number of times to loop Sound. Pass -1 to loop forever.
	 * @param allowMultiple Allow multiple concurrent instances of this Sound
	 * @param allow seamless sound loops. Note that this will exhibit a bug when attempting to pause/resume the looping sound.
	 */
	public function play(volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = true, enableSeamlessLoops:Bool = false):SoundInstance {
		this.loops = loops;
		_enableSeamlessLoops = enableSeamlessLoops;

		// If loops == -1, switch it to loop infinitely
		loops = ((loops < 0)) ? 0x7FFFFFFF : loops;
		_loopsRemaining = 0;

		// When not using seamless looping, maintain an internal loopsRemaining counter, and loop manually on soudn complete.
		// This avoids a SoundAPI bug with pause/resume: http://www.stevensacks.net/2008/08/07/as3-sound-channel-bug/
		if (enableSeamlessLoops == false) {
			_loopsRemaining = loops;
			loops = 0;
		}

		this.allowMultiple = allowMultiple;
		if (allowMultiple)
			// Store old channel, so we can still stop it if requested.
		{
			if (channel != null) {
				oldChannels.push(channel);
			}
			channel = sound.play(startTime, loops);
		} else {
			if (channel != null) {
				stopChannel(channel);
			}
			channel = sound.play(startTime, loops);
		}
		if (channel != null) {
			channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_isPlaying = true;
		}
		pauseTime = 0; // Always reset pause time on play

		this.volume = volume;
		this.mute = mute;
		return this;
	}

	private function get_fade():SoundTween {
		return currentTween;
	}

	/**
	 * Pause currently playing sound. Use resume() to continue playback. Pause / resume is supported for single sounds only.
	 */
	public function pause():SoundInstance {
		if (channel == null) {
			return this;
		}
		_isPlaying = false;
		pauseTime = channel.position;
		stopChannel(channel);
		stopOldChannels();
		return this;
	}

	/**
	 * Resume from previously paused time. Optionally start over if it's not paused.
	 */
	public function resume(forceStart:Bool = false):SoundInstance {
		if (isPaused || forceStart) {
			play(_volume, pauseTime, loops, allowMultiple);
		}
		return this;
	}

	/**
	 * Stop the currently playing sound and set it's position to 0
	 */
	public function stop():SoundInstance {
		pauseTime = 0;
		stopChannel(channel);
		channel = null;
		stopOldChannels();
		_isPlaying = false;
		return this;
	}

	/**
	 * Mute current sound.
	 */
	private function get_mute():Bool {
		return _muted;
	}

	private function set_mute(value:Bool):Bool {
		_muted = value;
		if (channel != null) {
			channel.soundTransform = (_muted) ? new SoundTransform(0) : soundTransform;
			updateOldChannels();
		}
		return value;
	}

	/**
	 * Fade using the current volume as the Start Volume
	 */
	public function fadeTo(endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):SoundInstance {
		currentTween = manager.addTween(type, -1, endVolume, duration, stopAtZero);
		return this;
	}

	/**
	 * Fade and specify both the Start Volume and End Volume.
	 */
	public function fadeFrom(startVolume:Float, endVolume:Float, duration:Float = 1000, stopAtZero:Bool = true):SoundInstance {
		currentTween = manager.addTween(type, startVolume, endVolume, duration, stopAtZero);
		return this;
	}

	/**
	 * Indicates whether this sound is currently playing.
	 */
	private function get_isPlaying():Bool {
		return _isPlaying;
	}

	/**
	 * Combined masterVolume and volume levels
	 */
	private function get_mixedVolume():Float {
		return _volume * manager.masterVolume;
	}

	/**
	 * Indicates whether this sound is currently paused.
	 */
	private function get_isPaused():Bool {
		return channel != null && sound != null && pauseTime > 0 && pauseTime < sound.length;
	}

	/**
	 * Set position of sound in milliseconds
	 */
	private function get_position():Float {
		return (channel != null) ? channel.position : 0;
	}

	private function set_position(value:Float):Float {
		if (channel != null) {
			stopChannel(channel);
		}
		channel = sound.play(value, loops);
		channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		return value;
	}

	/**
	 * Value between 0 and 1. You can call this while muted to change volume, and it will not break the mute.
	 */
	private function get_volume():Float {
		return _volume;
	}

	private function set_volume(value:Float):Float // Update the voume value, but respect the mute flag.
	{
		if (value < 0) {
			value = 0;
		} else if (value > 1 || Math.isNaN(volume)) {
			value = 1;
		}
		_volume = value;
		soundTransform.volume = mixedVolume;

		if (!_muted && channel != null) {
			channel.soundTransform = soundTransform;
			updateOldChannels();
		}
		return value;
	}

	/**
	 * The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right).
	 */
	private function get_pan():Float {
		return _pan;
	}

	private function set_pan(value:Float):Float // Update the voume value, but respect the mute flag.
	{
		if (value < -1) {
			value = -1;
		} else if (value > 1 || Math.isNaN(volume)) {
			value = 1;
		}
		_pan = soundTransform.pan = value;
		if (!_muted && channel != null) {
			channel.soundTransform = soundTransform;
			updateOldChannels();
		}
		return value;
	}

	private function get_masterVolume():Float {
		return manager.masterVolume;
	}

	/**
	 * Sets the master volume (the volume of the manager)
	 * Note : this will affect all sounds managed by the same sound manager
	 */
	private function set_masterVolume(value:Float):Float {
		manager.masterVolume = value;
		return value;
	}

	/**
	 * Create a duplicate of this SoundInstance
	 */
	public function clone():SoundInstance {
		var si:SoundInstance = new SoundInstance(sound, type);
		return si;
	}

	/**
	 * Unload sound from memory.
	 */
	public function destroy():Void {
		soundCompleted.removeAll();
		try {
			sound.close();
		} catch (e:Error) {}
		sound = null;
		_soundTransform = null;
		stopChannel(channel);
		channel = null;

		if (fade != null) {
			fade.end(false);
		}
	}

	/**
	 * Dispatched when Sound has finished playback
	 */
	private function onSoundComplete(event:Event):Void {
		// trace("stop", ++stopCount);
		var channel:SoundChannel = cast(event.target, SoundChannel);
		channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);

		// If it's the current channel, see if we should loop.
		if (channel == this.channel) {
			this.channel = null;
			pauseTime = 0;
			// Loop manually?
			if (_enableSeamlessLoops == false) {
				// loop forever?
				if (loops == -1) {
					play(_volume, 0, -1, allowMultiple);
				}
				// Loop set number of times?
				else if (--_loopsRemaining >= 0) {
					play(_volume, 0, _loopsRemaining, allowMultiple);
				} else {
					_isPlaying = false;
					soundCompleted.dispatch(this);
				}
			} else {
				soundCompleted.dispatch(this);
			}
		}
		// Clear out any old channels...
		var i:Int = oldChannels.length;
		while (--i >= 0) {
			if (channel.position == sound.length) {
				stopChannel(channel);
				oldChannels.splice(i, 1);
			}
		}
	}

	/**
	 * Loops remaining, this will auto-decrement each time the sound loops. It will equal -1 when the sound is completed. 
	 * It will equal 0 if the sound is looping infinitely, or not looping at all.
	 */
	private function get_loopsRemaining():Int {
		return _loopsRemaining;
	}

	/**
	 * Stop the currently playing channel.
	 */
	private function stopChannel(channel:SoundChannel):Void {
		if (channel == null) {
			return;
		}
		channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		try {
			channel.stop();
		} catch (e:Error) {}
	}

	/**
	 * Kill all orphaned channels
	 */
	private function stopOldChannels():Void {
		if (oldChannels.length == 0) {
			return;
		}
		var i:Int = oldChannels.length;
		while (--i >= 0) {
			stopChannel(oldChannels[i]);
		}
		oldChannels.splice(0, oldChannels.length);
	}

	/**
	 * Keep orphaned channels in sync with current volume
	 */
	private function updateOldChannels():Void {
		if (channel == null) {
			return;
		}
		var i:Int = oldChannels.length;
		while (--i >= 0) {
			oldChannels[i].soundTransform = channel.soundTransform;
		}
	}

	private function get_soundTransform():SoundTransform {
		if (_soundTransform == null) {
			_soundTransform = new SoundTransform(mixedVolume, _pan);
		}
		return _soundTransform;
	}

	private function set_soundTransform(value:SoundTransform):SoundTransform {
		if (value.volume > 0) {
			_muted = false;
		} else if (value.volume == 0) {
			_muted = true;
		}
		channel.soundTransform = value;
		updateOldChannels();
		return value;
	}
}
