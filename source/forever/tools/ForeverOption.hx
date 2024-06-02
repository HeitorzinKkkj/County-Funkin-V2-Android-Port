package forever.tools;

import flixel.math.FlxMath;

/** Helper Enumerator for Option Types. **/
enum OptionType {
	/** Dummy Placeholder Type Option. **/
	NONE();

	/** Boolean Type Option. **/
	CHECKMARK();

	/** Category Type Option. **/
	CATEGORY();

	/**
	 * Number Type Option.
	 * @param min 		The minimum Value the option can go.
	 * @param max 		The maximum Value the option can go.
	 * @param steps 	Numbers that the option should be skipping, e.g: skip five, skipe 10, skip 30.
	 * @param clamp 	If the value should stop updating once the `max` is reached
	**/
	NUMBER(min:Float, max:Float, ?steps:Null<Float>, ?clamp:Bool);

	/**
	 * StringArray Type Option.
	 * @param options 		A list with options that this option can be changed to.
	**/
	CHOICE(?options:Array<String>);
}

/** Class Structure that handles options. **/
class ForeverOption {
	/** Name of the Option. **/
	public var name:String = "NO NAME.";

	/** Option Descriptor. **/
	public var description:String = "No Description.";

	/** Variable Reference in `Settings` **/
	public var variable:String = null;

	/** Type of the Option. **/
	public var type:OptionType = CHECKMARK;

	/** the Value of the Variable. **/
	public var value(get, set):Dynamic;

	/** Callback fired when hovering over the optiom. **/
	public var onHover:ForeverOption->Void;
	/** Callback Fired when the value changes. **/
	public var onChangeV:ForeverOption->Void;

	/**
	 * Creates a new option reference struct.
	**/
	public function new(name:String, ?variable:String = "", type:OptionType = CHECKMARK, ?description:String = null):Void {
		this.name = name;
		this.variable = variable;

		if (description == null && Settings.descriptions.exists(variable))
			description = Settings.descriptions.get(variable);

		this.description = description;
		this.type = type;
	}

	/**
	 * Changes the value of the option
	 * @param increment 		by how much should it be changed (used by `NUMBER` and `CHOICE` options)
	**/
	public function changeValue(increment:Int = 0):Void {
		switch (type) {
			case CHECKMARK:
				if (increment == 0)
					value = !value;

			case NUMBER(min, max, steps, clamp):
				if (steps == null)
					steps = Std.isOfType(value, Int) ? 1 : 0.1;
				if (clamp == null)
					clamp = false;

				final wrapMethod = clamp ? FlxMath.bound : Tools.wrapf;
				if (Std.isOfType(value, Int)) {
					final wrapMethod = clamp ? FlxMath.bound : FlxMath.wrap;
					value = wrapMethod(value + Math.floor(steps) * increment, Math.floor(min), Math.floor(max));
				}
				else {
					final wrapMethod = clamp ? FlxMath.bound : Tools.wrapf;
					value = wrapMethod(value + steps * increment, min, max);
				}

			case CHOICE(options):
				final curValue:Int = options.indexOf(value);
				final stringFound:String = options[FlxMath.wrap(curValue + increment, 0, options.length - 1)];
				value = stringFound;

			default:
				// nothing
		}
	}

	@:dox(hide) @:noCompletion function get_value():Dynamic
		return Reflect.field(Settings, variable);

	@:dox(hide) @:noCompletion function set_value(v:Dynamic):Dynamic {
		if (Reflect.hasField(Settings, variable))
			Reflect.setField(Settings, variable, v);
		if (onChangeV != null) onChangeV(this);
		return v;
	}
}
