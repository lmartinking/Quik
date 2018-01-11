package ui;

import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class SpinnerText extends FlxText {

	public var value:Int;
	public var tweenTime:Float;
	public var showZero:Bool;

	private var lastValue:Int;
	private var valuesToSet:List<Int>;
	private var tweening:Bool;

	public function set_showZero(val:Bool)
	{
		showZero = val;
		lastValue = -1;
		update();
	}

	public override function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		value = 0;
		lastValue = -1;
		valuesToSet = new List<Int>();
		tweening = false;
		tweenTime = 0.25;
		showZero = true;

		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	public override function update()
	{
		if (lastValue != value)
		{
			var val = Math.floor(value);

			if (val == 0 && showZero == false)
				text = "";
			else
				text = Std.string(val);
			lastValue = value;
		}

		super.update();
	}

	public override function destroy()
	{
		valuesToSet = null;

		super.destroy();
	}

	public function setTo(amount:Int, direct:Bool=false)
	{
		if (direct && ! tweening)
		{
			this.value = amount;
			return;
		}

		if (tweening)
		{
			valuesToSet.add(amount);
			return;
		}

		tweening = true;
		FlxTween.tween(this, { value: amount }, tweenTime, { complete: tweenComplete });
	}

	private function tweenComplete(tween:FlxTween)
	{
		if (valuesToSet.length == 0)
		{
			tweening = false;
			return;
		}

		var nextValue = valuesToSet.pop();
		FlxTween.tween(this, { value: nextValue }, tweenTime, { complete: tweenComplete });
	}
}
