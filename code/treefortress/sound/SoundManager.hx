package treefortress.sound;

import openfl.utils.Timer;
import openfl.Lib;
import haxe.ds.StringMap;
import msignal.Signal.Signal1;
import openfl.errors.Error;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.media.Sound;
import openfl.media.SoundLoaderContext;
import openfl.media.SoundTransform;
import openfl.net.URLRequest;
import openfl.utils.Dictionary;

/**
 * Controls playback and loading of a group of sounds. SoundHX references a global instance of SoundManager, but you are free to instanciate your own and use them in a modular fashion.
 */
class SoundManager {
	private var soundTransform(never, set):SoundTransform;

	private var instances:Array<SoundInstance>;
	private var instancesBySound:Dictionary<Sound, SoundInstance>;
	private var instancesByType:StringMap<SoundInstance>;
	private var groupsByName:StringMap<SoundManager>;

	public var groups:Array<SoundManager>;

	private var activeTweens:Array<SoundTween>;

	private var ticker:Sprite;
	private var _tickEnabled:Bool;

	public var tickEnabled(get, set):Bool;

	private var _mute:Bool;

	public var mute(get, set):Bool;

	private var _volume:Float;

	public var volume(get, set):Float;

	private var _pan:Float;

	public var pan(get, set):Float;

	private var _masterVolume:Float;

	public var masterVolume(get, set):Float;

	private var _masterTween:SoundTween;

	private var _searching:Bool;

	public function new() {
		init();
	}

	/**
	 * Dispatched when an external Sound has completed loading. 
	 */
	public var loadCompleted:Signal1<SoundInstance>;

	/**
	 * Dispatched when an external Sound has failed loading. 
	 */
	public var loadFailed:Signal1<SoundInstance>;

	private var parent:SoundManager;

	/**
	 * Play audio by type. It must already be loaded into memory using the addSound() or loadSound() APIs. 
	 * @param type
	 * @param volume
	 * @param startTime Starting time in milliseconds
	 * @param loops Number of times to loop audio, pass -1 to loop forever.
	 * @param allowMultiple Allow multiple, overlapping instances of this Sound (useful for SoundFX)
	 * @param allowInterrupt If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
	 * @param enableSeamlessLoops If this sound is currently playing, interrupt it and start at the specified StartTime. Otherwise, just update the Volume.
	 */
	public function play(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0, allowMultiple:Bool = false, allowInterrupt:Bool = true,
			enableSeamlessLoops:Bool = false):SoundInstance {
		var si:SoundInstance = getSound(type);

		// If we retrieved this instance from another manager, add it to our internal list of active instances.
		if (instances.indexOf(si) == -1) {}

		// Sound is playing, and we're not allowed to interrupt it. Just set volume.
		if (!allowInterrupt && si.isPlaying) {
			si.volume = volume;
		}
		// Play sound
		else {
			si.play(volume, startTime, loops, allowMultiple, enableSeamlessLoops);
		}
		return si;
	}

	/**
	 * Convenience function to play a sound that should loop forever.
	 */
	public function playLoop(type:String, volume:Float = 1, startTime:Float = 0, enableSeamlessLoops:Bool = true):SoundInstance {
		return play(type, volume, startTime, -1, false, true, enableSeamlessLoops);
	}

	/**
	 * Convenience function to play a sound that can have overlapping instances (ie click or soundFx).
	 */
	public function playFx(type:String, volume:Float = 1, startTime:Float = 0, loops:Int = 0):SoundInstance {
		return play(type, volume, startTime, loops, true);
	}

	/**
	 * Stop all sounds immediately.
	 */
	public function stopAll():Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].stop();
		}
	}

	/**
	 * Resume specific sound 
	 */
	public function resume(type:String):SoundInstance {
		return getSound(type).resume();
	}

	/**
	 * Resume all paused instances.
	 */
	public function resumeAll():Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].resume();
		}
	}

	/** 
	 * Pause a specific sound 
	**/
	public function pause(type:String):SoundInstance {
		return getSound(type).pause();
	}

	/**
	 * Pause all sounds
	 */
	public function pauseAll():Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].pause();
		}
	}

	/** 
	 * Fade specific sound starting at the current volume
	**/
	public function fadeTo(type:String, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):SoundInstance {
		return getSound(type).fadeTo(endVolume, duration, stopAtZero);
	}

	/**
	 * Fade all sounds starting from their current Volume
	 */
	public function fadeAllTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].fadeTo(endVolume, duration, stopAtZero);
		}
	}

	/** 
	 * Fade master volume starting at the current value
	**/
	public function fadeMasterTo(endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		addMasterTween(_masterVolume, endVolume, duration, stopAtZero);
	}

	/** 
	 * Fade specific sound specifying both the StartVolume and EndVolume.
	**/
	public function fadeFrom(type:String, startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):SoundInstance {
		return getSound(type).fadeFrom(startVolume, endVolume, duration, stopAtZero);
	}

	/**
	 * Fade all sounds specifying both the StartVolume and EndVolume.
	 */
	public function fadeAllFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].fadeFrom(startVolume, endVolume, duration, stopAtZero);
		}
	}

	/** 
	 * Fade master volume specifying both the StartVolume and EndVolume.
	**/
	public function fadeMasterFrom(startVolume:Float = 0, endVolume:Float = 1, duration:Float = 1000, stopAtZero:Bool = true):Void {
		addMasterTween(startVolume, endVolume, duration, stopAtZero);
	}

	/**
	 * Mute all instances.
	 */
	private function get_mute():Bool {
		return _mute;
	}

	private function set_mute(value:Bool):Bool {
		_mute = value;
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].mute = _mute;
		}
		return _mute;
	}

	/**
	 * Set volume on all instances
	 */
	private function get_volume():Float {
		return _volume;
	}

	private function set_volume(value:Float):Float {
		_volume = value;
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].volume = _volume;
		}
		return _volume;
	}

	/**
	 * Set pan on all instances
	 */
	private function get_pan():Float {
		return _pan;
	}

	private function set_pan(value:Float):Float {
		_pan = value;
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].pan = _pan;
		}
		return _pan;
	}

	/**
	 * Set soundTransform on all instances. 
	 */
	private function set_soundTransform(value:SoundTransform):SoundTransform {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].soundTransform = value;
		}
		return value;
	}

	/**
	 * Returns a SoundInstance for a specific type.
	 */
	public function getSound(type:String, forceNew:Bool = false):SoundInstance {
		if (_searching) {
			return null;
		}

		_searching = true;

		var si:SoundInstance = null;

		try {
			if (type == null) {
				return null;
			}

			// Try and retrieve instance from this manager.
			si = instancesByType.get(type);

			if (si == null) {
				// If instance was not found, check out parent manager;
				if (parent != null) {
					si = parent.getSound(type);
				}

				// Still not found, check the children.
				if (si == null && groups != null) {
					var i:Int = groups.length;
					while (--i >= 0) {
						si = groups[i].getSound(type);
						if (si != null) {
							break;
						}
					}
				}

				// If we've found it, add it to our local instance list:
				if (si != null && instances.indexOf(si) == -1) {
					addInstance(si);
				}
			}

			if (si == null) {
				throw new Error("[SoundHX] Sound with type '" + type + "' does not appear to be loaded.");
			}

			if (forceNew) {
				si = si.clone();
			}
		} catch (e:Dynamic) {
			// Handle any exceptions that may occur
			trace("Error in getSound: " + e);
		}

		// Code that should always execute, similar to the 'finally' block
		_searching = false;

		return si;
	}

	/**
	 * Preload a sound from a URL or Local Path
	 * @param url External file path to the sound instance.
	 * @param type 
	 * @param buffer
	 * 
	 */
	public function loadSound(url:String, type:String, buffer:Int = 100):Void // Check whether this Sound is already loaded
	{
		var si:SoundInstance = instancesByType.get(type);
		if (si != null && si.url == url) {
			return;
		} else {
			trace("didn't find sound for ", url);
		}

		si = new SoundInstance(null, type);
		si.url = url; // Useful for looking in case of load error
		si.sound = new Sound(new URLRequest(url), new SoundLoaderContext(buffer, false));
		si.sound.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadError, false, 0, true);
		// si.sound.addEventListener(ProgressEvent.PROGRESS, onSoundLoadProgress, false, 0, true);
		si.sound.addEventListener(Event.COMPLETE, onSoundLoadComplete, false, 0, true);
		addInstance(si);
	}

	/**
	 * Inject a sound that has already been loaded.
	 */
	public function addSound(type:String, sound:Sound):Void {
		var si:SoundInstance;
		// If the type is already mapped, inject sound into the existing SoundInstance.
		if (instancesByType.exists(type)) {
			si = instancesByType.get(type);
			si.sound = sound;
		}
		// Create a new SoundInstance
		else {
			si = new SoundInstance(sound, type);
		}
		addInstance(si);
	}

	/**
	 * Remove a sound from memory.
	 */
	public function removeSound(type:String):Void {
		if (!instancesByType.exists(type)) {
			return;
		}
		var i:Int = instances.length;
		while (--i >= 0) {
			if (instances[i].type == type) {
				instancesBySound.remove(instances[i].sound);
				instances[i].destroy();
				instances.splice(i, 1);
			}
		}
		instancesByType.remove(type);
	}

	/**
	 * Unload all Sound instances.
	 */
	public function removeAll():Void {
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].destroy();
		}
		if (groups != null) {
			i = groups.length;
			while (--i >= 0) {
				groups[i].removeAll();
			}
			groups = [];
		}
		init();
	}

	/**
	 * Set master volume, which will me multiplied on top of all existing volume levels.
	 */
	private function get_masterVolume():Float {
		return _masterVolume;
	}

	private function set_masterVolume(value:Float):Float {
		_masterVolume = value;
		var i:Int = instances.length;
		while (--i >= 0) {
			instances[i].volume = value;
		}
		return _masterVolume;
	}

	/**
	 * Return a specific group , create one if it doesn't exist.
	 */
	public function group(name:String):SoundManager {
		if (!groupsByName.exists(name)) {
			groupsByName.set(name, new SoundManager());
			groupsByName.get(name).parent = this;

			if (groups == null) {
				groups = new Array<SoundManager>();
			}
			groups.push(groupsByName.get(name));
		}
		return groupsByName.get(name);
	}

	/**
	 * PRIVATE
	 */
	private function init():Void // Create external signals
	{
		if (loadCompleted == null) {
			loadCompleted = new Signal1<SoundInstance>();
		}
		if (loadFailed == null) {
			loadFailed = new Signal1<SoundInstance>();
		}

		// Init collections
		_volume = 1;
		_pan = 0;
		_masterVolume = 1;
		instances = [];
		instancesBySound = new Dictionary(true);
		instancesByType = new StringMap();
		groupsByName = new StringMap();
		activeTweens = new Array<SoundTween>();
	}

	@:allow(treefortress.sound)
	private function addMasterTween(startVolume:Float, endVolume:Float, duration:Float, stopAtZero:Bool):Void {
		if (_masterTween == null) {
			_masterTween = new SoundTween(null, 0, 0, true);
		}
		_masterTween.init(startVolume, endVolume, duration);
		_masterTween.stopAtZero = stopAtZero;
		_masterTween.update(0, this);
		// Only add masterTween if it isn't already active.
		if (activeTweens.indexOf(_masterTween) == -1) {
			activeTweens.push(_masterTween);
		}
		tickEnabled = true;
	}

	@:allow(treefortress.sound)
	private function addTween(type:String, startVolume:Float, endVolume:Float, duration:Float, stopAtZero:Bool):SoundTween {
		var si:SoundInstance = getSound(type);

		if (startVolume >= 0) {
			si.volume = startVolume;
		}

		// Kill any active fade, it will get removed the next time the tweens are updated.
		if (si.fade != null) {
			si.fade.kill();
		}

		var tween:SoundTween = new SoundTween(si, endVolume, duration);
		tween.stopAtZero = stopAtZero;
		tween.update(tween.startTime, this);

		// Add new tween
		activeTweens.push(tween);

		tickEnabled = true;
		return tween;
	}

	public function onTick(event:Event):Void {
		var t:Int = Lib.getTimer();
		var i:Int = activeTweens.length;
		while (--i >= 0) {
			if (activeTweens[i].update(t, this)) {
				activeTweens[i].end();
				activeTweens.splice(i, 1);
			}
		}
		tickEnabled = (activeTweens.length > 0);
	}

	public function addInstance(si:SoundInstance):Void {
		si.mute = _mute;
		si.manager = this;
		if (instances.indexOf(si) == -1) {
			instances.push(si);
		}
		instancesBySound[si.sound] = si;
		instancesByType.set(si.type, si);
	}

	public function onSoundLoadComplete(event:Event):Void {
		var sound_ins:SoundInstance = instancesBySound[cast(event.target, Sound)];
		loadCompleted.dispatch(sound_ins);
		trace("[SoundHX] SUCCESS: Sound " + sound_ins.type + " from " + sound_ins.url + "loaded");
	}

	public function onSoundLoadProgress(event:ProgressEvent):Void {}

	public function onSoundLoadError(event:IOErrorEvent):Void {
		var sound_ins:SoundInstance = instancesBySound[cast(event.target, Sound)];
		loadFailed.dispatch(sound_ins);
		trace("[SoundHX] ERROR: Failed Loading Sound '" + sound_ins.type + "' @ " + sound_ins.url);
	}

	public function get_tickEnabled():Bool {
		return _tickEnabled;
	}

	public function set_tickEnabled(value:Bool):Bool {
		if (value == _tickEnabled) {
			return value;
		}
		_tickEnabled = value;
		if (_tickEnabled) {
			if (ticker == null) {
				ticker = new Sprite();
			}
			ticker.addEventListener(Event.ENTER_FRAME, onTick);
		} else {
			ticker.removeEventListener(Event.ENTER_FRAME, onTick);
		}
		return value;
	}
}
