package ;

import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import de.polygonal.core.fmt.NumberFormat;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxState;

import Reg.HighScore;
import misc.GlobalHighscores;

import ui.Button;

using flixel.util.FlxSpriteUtil;

class HighscoresState extends FlxState {
	private var hilightIndex:Int;
	private var latestScore:HighScore;
	private var table:Array<Array<FlxText>> = [];
	private var tweens:Array<FlxTween>;

	private static var UNKNOWN_NAME = "???";
	private static var UNKNOWN_SCORE = "???";

	public override function new(hilight = -1, score:HighScore = null) {
		super();

		hilightIndex = hilight;
		latestScore = score;
	}

	private var useLocal:Bool;
	private var scoreSwitchBtn:Button;

	public override function create():Void
	{
		super.create();

		var backdrop = new FlxBackdrop("assets/images/backdrop.png");
		backdrop.velocity.set(5, 5);
		add(backdrop);

		var btn = new Button(10, 0, "Back", onBack);
		btn.y = FlxG.height - btn.height - 10;

		scoreSwitchBtn = new Button(0, 0, "Global Scores", onScoreSwitch);
		scoreSwitchBtn.x = FlxG.width - scoreSwitchBtn.width - 10;
		scoreSwitchBtn.y = FlxG.height - scoreSwitchBtn.height - 10;

		var xPosIndex = 10;
		var xPosName = 40;
		var xPosScore = 200;
		var yPos = 15;

		for (index in 0...10)
		{
			var idxTxt = new FlxText(xPosIndex, yPos, Std.string(index + 1));
			var nameTxt = new FlxText(xPosName, yPos, "");

			var scoreTxt = new FlxText(xPosScore, yPos, 100, "");
			scoreTxt.alignment = "right";
			scoreTxt.x = FlxG.width - scoreTxt.width - 10;

			add(idxTxt);
			add(nameTxt);
			add(scoreTxt);

			table.push([idxTxt, nameTxt, scoreTxt]);

			yPos += 15;
		}

		add(btn);
		add(scoreSwitchBtn);

		tweens = new Array<FlxTween>();

		#if demo
		var demoTxt = new FlxText(0, 0, 300, "This is the DEMO version of Quik.\nIn the full version, high scores\ncan be posted online.");
		demoTxt.alignment = "center";
		demoTxt.screenCenter(true, true);
		demoTxt.borderStyle = FlxText.BORDER_SHADOW;
		add(demoTxt);
		#end

		useLocal = true;
		updateList(useLocal);
	}

	private function updateList(useLocal:Bool)
	{
		var list:Array<HighScore> = (useLocal ? Reg.highscores : Game.instance().getGlobalScores());

		for (tween in tweens)
			tween.cancel();
		tweens = new Array<FlxTween>();

		var index = 0;
		for (row in table)
		{
			var idx = row[0];
			var name = row[1];
			var score = row[2];

			idx.color = FlxColor.WHITE;
			name.color = FlxColor.WHITE;
			score.color = FlxColor.WHITE;

			if (index >= list.length)
			{
				name.text = UNKNOWN_NAME;
				score.text = UNKNOWN_SCORE;
			}
			else
			{
				name.text = list[index].name;
				score.text = NumberFormat.groupDigits(list[index].points, ",");

				if ((useLocal && hilightIndex == index) || (! useLocal && latestScore == list[index]))
				{
					idx.color = FlxColor.LIME;
					name.color = FlxColor.LIME;
					score.color = FlxColor.LIME;

					for (obj in [name, score])
					{
						obj.alpha = 0.0;
						var tw = FlxTween.tween(obj, { alpha: 1.0 }, 1.0, { type: FlxTween.LOOPING });
						tweens.push(tw);
					}
				}
			}

			index++;
		}
	}

	private function onScoreSwitch():Void
	{
		useLocal = ! useLocal;
		updateList(useLocal);
		scoreSwitchBtn.text = useLocal ? "Global Scores" : "Local Scores";
	}

	private function onBack():Void
	{
		FlxG.switchState(new MenuState());
	}

	public override function destroy():Void
	{
		for (tween in tweens)
			tween.cancel();
		tweens = null;

		latestScore = null;

		table = null;
		scoreSwitchBtn = null;

		super.destroy();
	}
}
