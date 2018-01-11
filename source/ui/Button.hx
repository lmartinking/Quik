package ui;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class Button extends FlxButton
{
	public var clickSnd:FlxSound;
	public var callback:Void->Void;

	override public function new(X:Float = 0, Y:Float = 0, ?Text:String, ?OnClick:Void->Void)
	{
		super(X, Y, Text);

		clickSnd = FlxG.sound.load("assets/sounds/ui1.wav");
		callback = OnClick;

		loadGraphic("assets/ui/button_green.png", true, 80, 20);
		label.color = FlxColor.WHITE;
		label.borderStyle = FlxTextBorderStyle.OUTLINE;
		label.borderColor = FlxColor.BLACK;
		label.borderSize = 1.0;
		labelAlphas = [1.0, 0.9, 0.5];
		label.antialiasing = false;

		labelOffsets[0].set(-2, 2);
		labelOffsets[1].set(-2, 2);
		labelOffsets[2].set(0, 4);

		this.onDown.callback = onClick;
	}

	private function onClick():Void
	{
		if (clickSnd.playing)
			return;

		clickSnd.play();
		clickSnd.onComplete = function () {
			if (callback != null)
				callback();
		}
	}
}
