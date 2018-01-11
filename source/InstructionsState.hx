package ;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxSubState;

using flixel.util.FlxSpriteUtil;

class InstructionsState extends FlxSubState {

	public override function new() {
		super(FlxColor.BLACK);
	}

	public override function create()
	{
		#if (mobile)
		createTouch();
		#end

		#if (desktop)
		createKeys();
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true, null, true);
	}

	private function createKeys()
	{
		var screen = new FlxSprite(0, 0, "assets/images/instructions_keys.png");
		screen.centerOrigin();
		screen.screenCenter();
		add(screen);
	}

	private function createTouch()
	{
		var screen = new FlxSprite(0, 0, "assets/images/instructions_touch.png");
		screen.centerOrigin();
		screen.screenCenter();
		add(screen);

		var tap = new FlxSprite(0, 0);
		tap.loadGraphic("assets/images/tap.png", true, 18, 18);

		tap.scale.set(2.0, 2.0);

		tap.animation.add("touch", [0, 1, 2], 3, true);
		tap.animation.play("touch");

		tap.centerOrigin();
		tap.screenCenter();

		tap.x += 41.5;
		tap.y += 17.0;

		add(tap);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Input.skipPressed())
		{
			doClose();
		}
	}

	private function doClose()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1.0, false, this.close, true);
	}
}
