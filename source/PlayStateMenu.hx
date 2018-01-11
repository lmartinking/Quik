package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;

import Input;
import ui.Button;

class PlayStateMenu extends FlxSubState
{
	public var leaveSignal:FlxSignal;
	public var resumeSignal:FlxSignal;
	public var restartSignal:FlxSignal;

	override public function new():Void
	{
		leaveSignal = new FlxSignal();
		resumeSignal = new FlxSignal();
		restartSignal = new FlxSignal();

		super();
	}

	override public function create():Void
	{
		super.create();

		var resumeBtn:Button = new Button(0, 0, "Continue", doResume);
		var restartBtn:Button = new Button(0, 30, "Restart", doRestart);
		var leaveBtn:Button = new Button(0, 60, "Leave", doLeave);

		resumeBtn.y = FlxG.height / 2 - resumeBtn.height / 2 - 30;
		resumeBtn.x = FlxG.width / 2 - resumeBtn.width / 2;
		restartBtn.y = resumeBtn.y + 30;
		restartBtn.x = FlxG.width / 2 - resumeBtn.width / 2;
		leaveBtn.y = restartBtn.y + 30;
		leaveBtn.x = FlxG.width / 2 - restartBtn.width / 2;

		var backdrop:FlxSprite = new FlxSprite(0, 0);
		backdrop.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK, false, "PlayStateMenuBackdrop");
		backdrop.scrollFactor.set(0, 0);
		backdrop.alpha = 0.0;
		backdrop.scale.set(2.0, 2.0);

		FlxTween.tween(backdrop, { alpha: 0.4 }, 0.5);

		add(backdrop);
		add(resumeBtn);
		add(restartBtn);
		add(leaveBtn);
	}

	private function doResume()
	{
		resumeSignal.dispatch();
	}

	private function doRestart()
	{
		restartSignal.dispatch();
	}

	private function doLeave()
	{
		leaveSignal.dispatch();
	}

	override public function destroy():Void
	{
		super.destroy();
	}
}
