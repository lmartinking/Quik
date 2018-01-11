package ;

import flixel.FlxG;
import flixel.FlxSprite;

import openfl.geom.Point;
import openfl.geom.Rectangle;

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

import ui.SpinnerText;
import ui.PowerupButton;

using flixel.util.FlxSpriteUtil;

class PlayStateHUD extends FlxSpriteGroup {
	var scoreValue:Int;
	var scoreText:SpinnerText;
	var flipText:SpinnerText;
	var timeText:FlxText;
	var timeSecs:Int;
	var timeTextTween:FlxTween;

	var flips:Int;

	var barBg:FlxSprite;
	var barTicks:FlxSprite;
	var barTickGreen:FlxSprite;
	var barGfx:FlxSprite;
	var barCount:Int;

	var bounceBtn:PowerupButton;
	var stopBtn:PowerupButton;

	private static var MARGIN_TOP = 5;
	private static var MARGIN_SIDE = 5;
	private static var FONT_SIZE = 8;

	override public function new() {
		super();

		scrollFactor.set(0, 0);

		bounceBtn = new PowerupButton(0, 0, Bounce);
		bounceBtn.x = MARGIN_SIDE;
		bounceBtn.y = FlxG.height - bounceBtn.height - MARGIN_TOP;
		bounceBtn.onDown.callback = onBouncePress;

		stopBtn = new PowerupButton(0, 0, Stop);
		stopBtn.x = bounceBtn.x;
		stopBtn.y = bounceBtn.y;
		stopBtn.onDown.callback = onStopPress;
		stopBtn.onUp.callback = onStopRelease;

		Input.setIgnoreRegion(bounceBtn.x, bounceBtn.y, bounceBtn.width, bounceBtn.height);
		Input.setBounceFlag(false);
		Input.setStopFlag(false);

		setBounceCount(0);
		setStopCount(0);

		// TODO: Better fonts
		scoreText = new SpinnerText((FlxG.width / 4) * 3, MARGIN_TOP, 100, "", FONT_SIZE);
		scoreText.alignment = "right";
		scoreText.borderStyle = FlxTextBorderStyle.OUTLINE;
		scoreText.borderSize = 1.0;
		scoreText.borderColor = FlxColor.BLACK;
		scoreText.antialiasing = false;
		scoreText.centerOrigin();
		scoreText.scale.set(1.8, 1.8);

		barBg = new FlxSprite(MARGIN_SIDE, MARGIN_TOP, "assets/images/hud_bar.png");
		barTickGreen = new FlxSprite(MARGIN_SIDE, MARGIN_SIDE, "assets/images/hud_bar_tick_green.png");
		barTicks = new FlxSprite(0, 0, "assets/images/hud_bar_ticks.png");
		barGfx = new FlxSprite(MARGIN_SIDE, MARGIN_TOP);
		barGfx.makeGraphic(Math.floor(barTicks.width), Math.floor(barTicks.height), FlxColor.TRANSPARENT, true);
		barCount = 0;

		flipText = new SpinnerText(barBg.x + barBg.width + MARGIN_SIDE, MARGIN_TOP, 100, "", FONT_SIZE);
		flipText.alignment = "left";
		flipText.borderStyle = FlxTextBorderStyle.OUTLINE;
		flipText.borderSize = 1.0;
		flipText.borderColor = FlxColor.BLACK;
		flipText.antialiasing = false;
		flipText.centerOrigin();
		flipText.x += 30;
		flipText.y += 3;
		flipText.scale.set(1.6, 1.6);

		var timeIcon = new FlxSprite(0, 0, "assets/images/timer.png");
		timeIcon.x = FlxG.width - 60;
		timeIcon.y = MARGIN_TOP;

		timeText = new FlxText((FlxG.width / 4) * 3, MARGIN_TOP, 100, "0", FONT_SIZE);
		timeText.alignment = "right";
		timeText.borderStyle = FlxTextBorderStyle.OUTLINE;
		timeText.borderSize = 1.0;
		timeText.borderColor = FlxColor.BLACK;
		timeText.antialiasing = false;
		timeText.width = 100;
		timeText.x = FlxG.width - MARGIN_SIDE - timeText.width;
		timeText.y = MARGIN_TOP;
		timeText.centerOrigin();
		timeText.scale.set(1.8, 1.8);
		timeText.x -= 42;
		timeText.y += 3;

		scoreText.x = timeText.x;
		scoreText.y = timeText.y + 24;

		flipText.showZero = false;
		setFlipCount(0);

		scoreValue = -1;
		timeSecs = 0;

		add(scoreText);
		add(flipText);

		add(timeIcon);
		add(timeText);

		add(barBg);
		add(barTickGreen);
		add(barGfx);

		add(bounceBtn);
		add(stopBtn);
	}

	override public function destroy()
	{
		scoreText = null;
		flipText = null;
		timeText = null;
		timeTextTween = null;

		barBg = null;
		barGfx = null;
		barTicks = null;
		barTickGreen = null;

		bounceBtn = null;
		stopBtn = null;

		super.destroy();
	}

	public function setScore(amount:Int, ?immediate=false)
	{
		if (scoreValue != amount)
		{
			scoreText.setTo(amount, immediate);
			scoreValue = amount;
		}
	}

	public function setTime(seconds:Int)
	{
		if (seconds != timeSecs)
		{
			timeSecs = seconds;
			timeText.text = Std.string(timeSecs);

			if (seconds == 10)
			{
				timeTextTween = FlxTween.color(timeText, 0.25, timeText.color, timeText.color, { startDelay:1.0, loopDelay: 0.0, type: FlxTween.PINGPONG });
			}
			else if (seconds == 5)
			{
				if (timeTextTween != null) timeTextTween.duration = 0.1;
			}
		}
	}

	public function setCannotJumpOrFlip(cannotFlip:Bool)
	{
		barTickGreen.visible = ! cannotFlip;
	}

	public function setBounceCount(amount:Int)
	{
		var canBounce = (amount > 0);
		bounceBtn.visible = canBounce;
		bounceBtn.active = canBounce;
		Input.setIgnoreRegionEnabled(canBounce);
	}

	public function setStopCount(amount:Int)
	{
		var canStop = (amount > 0);
		stopBtn.visible = canStop;
		stopBtn.active = canStop;
		Input.setIgnoreRegionEnabled(canStop);
	}

	public function setFlipCount(amount:Int)
	{
		flips = amount;
		flipText.setTo(amount);
		FlxTween.num(barCount, amount, 0.25, null, updateBarGfx);
	}

	private function updateBarGfx(amount:Float)
	{
		barCount = Math.floor(amount);
		var width = Math.floor(Math.min(amount, 8) * 8);

		barGfx.pixels.fillRect(barGfx.pixels.rect, 0);
		barGfx.pixels.copyPixels(barTicks.pixels, new Rectangle(0, 0, width, barTicks.height), new Point(0, 0));
	}

	private function onBouncePress():Void
	{
		Input.setBounceFlag(true);
	}

	private function onStopPress():Void
	{
		Input.setStopFlag(true);
	}

	private function onStopRelease():Void
	{
		Input.setStopFlag(false);
	}
}
