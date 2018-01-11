package;

import flixel.FlxG;
import flixel.util.FlxRect;

class Input {
	private static var ignoreRegion:FlxRect = new FlxRect();
	private static var useIgnoreRegion:Bool = false;

	private static var bounceFlag:Bool = false;
	private static var stopFlag:Bool = false;

	public static function update():Void
	{
	}

	public static function setIgnoreRegion(x:Float, y:Float, width:Float, height:Float)
	{
		trace(x, y, width, height);
		ignoreRegion.set(x, y, width, height);
	}

	public static function setBounceFlag(set:Bool)
	{
		bounceFlag = set;
	}

	public static function setStopFlag(set:Bool)
	{
		stopFlag = set;
	}

	public static function setIgnoreRegionEnabled(enable:Bool)
	{
		useIgnoreRegion = enable;
	}

	#if mobile
	private static function isTouched():Bool
	{
		// FIXME: this is a lame Hack but it works to prevent bouncing and flipping
		//        when the button is pressed in the HUD
		if (bounceFlag || stopFlag)
			return false;

		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				if (useIgnoreRegion && ignoreRegion.containsFlxPoint(touch))
				{
					continue;
				}

				return true;
			}
		}

		return false;
	}
	#end

	public static function setMouseVisible(show:Bool)
	{
		#if (desktop || flash)
		FlxG.mouse.visible = show;
		#end
	}

	public static function setMouseCursor(asset:String)
	{
		#if (desktop || flash)
		FlxG.mouse.load(asset, 2.0);
		#end
	}

	public static function skipPressed():Bool
	{
		#if (desktop || flash)
		return FlxG.keys.justPressed.SPACE || FlxG.mouse.pressed;
		#end

		#if mobile
		return isTouched();
		#end
	}

	public static function flipPressed():Bool
	{
		#if (desktop || flash)
		return FlxG.keys.justPressed.SPACE;
		#end

		#if mobile
		return isTouched();
		#end
	}

	public static function bouncePressed():Bool
	{
		#if (desktop || flash)
		return FlxG.keys.justPressed.CONTROL;
		#end

		#if mobile
		if (bounceFlag)
		{
			return true;
		}
		#end

		return false;
	}

	public static function stopHeld():Bool
	{
		#if desktop
		return FlxG.keys.pressed.SHIFT;
		#end

		return stopFlag;
	}

	public static function escapePressed():Bool
	{
		#if (desktop || flash)
		return FlxG.keys.justPressed.ESCAPE;
		#end

		#if android
		return FlxG.android.justPressed("BACK");
		#end

		return false;
	}
}
