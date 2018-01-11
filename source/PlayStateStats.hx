package ;


import Reg.LevelStats;
import flixel.text.FlxText;
import flixel.util.FlxSignal;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxTimer;
import flixel.FlxState;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

import PlayState;

import ui.Button;
import ui.SpinnerText;

using flixel.util.FlxSpriteUtil;


class PlayStateStats extends FlxState {
	private var values:Array<SpinnerValue>;
	private var s:LevelStats;
	private var onContinue:Void->Void;

	static var fadeOutColour:Int = FlxColor.BLACK;
	static var fadeDuration:Float = 1.0;

	override public function new(stats:LevelStats, callback:Void->Void):Void
	{
		super();

		s = stats;
		onContinue = callback;
	}

	override public function create():Void
	{
		super.create();

		var backdrop:FlxSprite = new FlxSprite(0, 0);
		backdrop.loadGraphic("assets/images/backdrop.png", false, FlxG.width, FlxG.height);
		backdrop.scrollFactor.set(0, 0);
		add(backdrop);

		var title = new FlxText(0, 0, 0, 'Completed Level ${s.levelIndex + 1} of ${Reg.levels.length}');
		title.centerOffsets();
		title.scale.set(2.0, 2.0);
		title.borderStyle = FlxText.BORDER_SHADOW;
		title.screenCenter(true, false);
		title.y = 12;
		add(title);

		values = new Array<SpinnerValue>();

		values.push(new SpinnerValue("Time:", Std.int(s.elapsedTime)));
		values.push(new SpinnerValue("Air Flips:", s.airJumps));
		values.push(new SpinnerValue("Jumps:", s.jumps));
		values.push(new SpinnerValue("Bounces:", s.bounces));
		values.push(new SpinnerValue("Flips Collected:", s.flipsCollected));
		values.push(new SpinnerValue("Flips Saved:", s.flipsCollected - s.flipsUsed));
		values.push(new SpinnerValue("Bounces Collected:", s.bouncesCollected));
		values.push(new SpinnerValue("Bounces Saved:", s.bouncesCollected - s.bouncesUsed));
		values.push(new SpinnerValue("Stops Collected:", s.stopsCollected));
		values.push(new SpinnerValue("Stops Saved:", s.stopsCollected- s.stopsUsed));

		values.push(new SpinnerValue("Spikes Smashed:", s.spikesSmashed));

		var points = Game.calculatePoints(s, true);
		values.push(new SpinnerValue("Points:", points, 0, 10));

		var xLbl = 10;
		var xPos = 120;
		var yPos = 40;
		var delay = 0.5;

		for (val in values)
		{
			if (val.value == 0)
				continue;

			xPos += val.offset[0];
			yPos += val.offset[1];

			val.text.x = xPos;
			val.text.y = yPos;
			val.text.setTo(0);
			add(val.text);

			val.lbl.x = xLbl;
			val.lbl.y = yPos;
			val.lbl.visible = false;
			add(val.lbl);

			val.timer.start(delay, function(timer:FlxTimer)
			{
				val.lbl.visible = true;

				val.text.showZero = true;
				val.text.setTo(val.value);

				timer.cancel();
				val.timer = FlxDestroyUtil.destroy(val.timer);
			});

			delay += 0.5;
			yPos += 20;
		}

		var btn = new Button(10, 10, "Continue", onContinue);
		btn.x = FlxG.width - btn.width - 10;
		btn.y = FlxG.height - btn.height - 10;
		add(btn);
	}

	override public function destroy():Void
	{
		super.destroy();

		values = null;
	}
}

class SpinnerValue
{
	public var lbl:FlxText;
	public var text:SpinnerText;
	public var value:Int;
	public var timer:FlxTimer;
	public var offset:Array<Int>;

	public function new(label:String, val:Int, xOff = 0, yOff = 0)
	{
		lbl = new FlxText(0, 0, label);
		text = new SpinnerText();
		text.showZero = false;
		text.setTo(0);
		value = val;
		timer = new FlxTimer();
		offset = [xOff, yOff];
	}
}