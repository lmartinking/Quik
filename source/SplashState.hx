package;

import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;

import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class SplashState extends FlxState
{
	static var bgColour:Int = FlxColor.WHITE;
	static var fadeInColour:Int = FlxColor.BLACK;
	static var fadeOutColour:Int = FlxColor.BLACK;
	static var fadeDuration:Float = 1.0;

	static var titleColour:Int = FlxColor.BLACK;
	static var titleText:String = "irrational idiom";
	static var titleSize:Int = 16;

	private var title:FlxText;
	private var timer:FlxTimer;

	override public function create():Void
	{
		super.create();

		this.bgColor = bgColour;

		title = new FlxText(0, 0, 0, titleText, titleSize, true);
		title.color = titleColour;
		title.alignment = "center";
		title.screenCenter();

		add(title);

		FlxG.sound.cache("assets/sounds/logo.wav");
		FlxG.camera.fade(fadeInColour, fadeDuration, true, function () {
			FlxG.sound.play("assets/sounds/logo.wav");
			Game.instance().preloadMusic();
		});

		timer = new FlxTimer(4.0, function(timer:FlxTimer) { leaveState(); }, 1);
	}

	override public function destroy():Void
	{
		super.destroy();

		title = FlxDestroyUtil.destroy(title);
		timer = FlxDestroyUtil.destroy(timer);
	}

	override public function update():Void
	{
		super.update();

		if (Input.skipPressed())
		{
			leaveState();
		}
	}

	private function leaveState():Void
	{
		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function() {
			FlxG.switchState(new MenuState());
		});
	}
}
