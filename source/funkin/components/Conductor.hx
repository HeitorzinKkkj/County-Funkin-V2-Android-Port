package funkin.components;

import flixel.util.FlxSignal;

/**
 * The Conductor is one of the most important components within Friday Night Funkin'
 *
 * It helps us to manage the song's time, along with synching it to the beat,
 * Just like your average rhythm game.
 *
 * @author voiddevv (Original GDScript Implementation) crowplexus (Haxe Implementation)
**/
class Conductor {
	// this looks very stupid but that is literally the correct answer, + dividing is slower.
	@:dox(hide) public static final SIXTY_IN_MULT:Float = 0.01666666666666;
	@:dox(hide) static var _lastTime:Float = -1.0;

	/** How many beats per minute will count. **/
	public static var bpm:Float = 100.0;

	/** Current (Music) Time, calcualted in seconds. **/
	public static var time:Float = 0.0;

	/** Current Music Pitch + Speed Rate. **/
	public static var rate:Float = 1.0;

	/** If the Conductor is currently active. **/
	public static var active:Bool = true;

	/** How many beats there are in a step. **/
	public static var stepsPerBeat:Int = 4;

	/** How many beats there are in a measure/bar. **/
	public static var beatsPerBar:Int = 4;

	/** The Current Step, expressed with a integer. **/
	public static var step(get, never):Int;

	/** The Current Beat, expressed with a integer. **/
	public static var beat(get, never):Int;

	/** The Current Bar/Measure, expressed with a integer. **/
	public static var bar(get, never):Int;

	/** The Delta Time between the last and current beat. **/
	public static var crochet(get, never):Float;

	/** The Delta Time between the last and current step. **/
	public static var stepCrochet(get, never):Float;

	/** The Time (in seconds) within a beat. **/
	public static var beatf:Float = 0.0;

	/** The Time (in seconds) within a step. **/
	public static var stepf:Float = 0.0;

	/** The Time (in seconds) within a bar. **/
	public static var barf:Float = 0.0;

	/** Signal emitted when a (new) step is hit. **/
	public static var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	/** Signal emitted when a (new) beat is hit. **/
	public static var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	/** Signal emitted when a (new) bar is hit. **/
	public static var onBar:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	/**
	 * Resets the time variables from the Conductor,
	 *
	 * @param resetSignals 		Will also remove every connected method in the music signals.
	**/
	public static function init(resetSignals:Bool = true):Void {
		time = 0.0;
		_lastTime = -1.0;
		stepf = beatf = barf = 0.0;
		if (resetSignals) {
			onStep.removeAll();
			onBeat.removeAll();
			onBar.removeAll();
		}
	}

	@:dox(hide) public static function update(deltaTime:Float):Void {
		if (!active) return;

		if (FlxG.state != null && FlxG.state.exists) {
			time += deltaTime;
			if (FlxG.sound.music != null && FlxG.sound.music.playing) {
				if (Math.abs(time - FlxG.sound.music.time / 1000.0) >= 0.05) // interpolation.
					time = FlxG.sound.music.time / 1000.0;
			}
		}

		if (time >= 0.0) {
			final timeDelta:Float = time - _lastTime;
			final beatDelta:Float = (bpm * SIXTY_IN_MULT) * timeDelta;
			// *
			if (beat != Math.floor(beatf += beatDelta)) onBeat.dispatch(beat);
			if (step != Math.floor(stepf += beatDelta * stepsPerBeat)) onStep.dispatch(step);
			if (bar != Math.floor(barf += beatDelta / beatsPerBar)) onBar.dispatch(bar);
			// *
		}

		_lastTime = time;
	}

	// -- HELPER CONVERSION FUNCTIONS -- //

	/** Converts the given amount of time, using the `_bpm`, to a Beat. **/
	public static inline function timeToBeat(_time:Float, _bpm:Float):Float return { (_time * _bpm) * SIXTY_IN_MULT; }

	/** Converts the given amount of time, using the `_bpm`, to a Step. **/
	public static inline function timeToStep(_time:Float, _bpm:Float):Float return timeToBeat(_time, _bpm) * stepsPerBeat;

	/** Converts the given amount of time, using the `_bpm`, to a Bar. **/
	public static inline function timeToBar(_time:Float, _bpm:Float):Float return timeToBeat(_time, _bpm) / beatsPerBar;

	/** Converts the time of a beat, using the `_bpm`, to Time (in seconds). **/
	public static inline function beatToTime(_beatt:Float, _bpm:Float):Float { return (_beatt * SIXTY_IN_MULT) / _bpm; }

	/** Converts the time of a step, using the `_bpm`, to Time (in seconds). **/
	public static inline function stepToTime(_stept:Float, _bpm:Float):Float return beatToTime(_stept, _bpm) * stepsPerBeat;

	/** Converts the time of a bar, using the `_bpm`, to Time (in seconds). **/
	public static inline function barToTime(_bart:Float, _bpm:Float):Float return beatToTime(_bart, _bpm) / beatsPerBar;
	// BART SIMPSON!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! -swordcube

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	@:noCompletion @:dox(hide) inline static function get_crochet():Float return 60.0 / bpm;
	@:noCompletion @:dox(hide) inline static function get_stepCrochet():Float return crochet / stepsPerBeat; // whoops! looks like i messed with one! >:3 -srt

	@:noCompletion @:dox(hide) inline static function get_step():Int return Math.floor(stepf);
	@:noCompletion @:dox(hide) inline static function get_beat():Int return Math.floor(beatf);
	@:noCompletion @:dox(hide) inline static function get_bar():Int return Math.floor(barf);
}
