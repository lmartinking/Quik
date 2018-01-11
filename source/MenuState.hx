package;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.addons.display.FlxBackdrop;

#if ! mobile
import openfl.system.System;
#end

#if demo
import openfl.Lib;
import openfl.net.URLRequest;
#end

using flixel.util.FlxSpriteUtil;

import Reg.HighScore;
import misc.MacroStuff;

import ui.Button;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	static var bgColour:Int = FlxColor.WHITE;

	static var fadeInColour:Int = FlxColor.BLACK;
	static var fadeOutColour:Int = FlxColor.BLACK;
	static var fadeDuration:Float = 1.0;

	private static var Margin = 4;
	private static var FontSize = 8;

	override public function create():Void
	{
		super.create();

		this.bgColor = bgColour;

		FlxG.camera.fade(fadeInColour, fadeDuration, true);

		var backdrop = new FlxBackdrop("assets/images/backdrop.png");
		backdrop.velocity.set(-10, 0);

		var title = new FlxText(0, 0, 0, "Quik", 32);
		title.alignment = "center";
		title.borderStyle = FlxTextBorderStyle.SHADOW;
		title.borderSize = 4;
		title.bold = true;

		var newGameBtn:Button = new Button(0, 0, "New Game", doNewGame);
		var scoreBtn:Button = new Button(0, 30, "High Scores", doHighScores);
		var settingsBtn:Button = new Button(0, 60, "Settings", doSettings);

		#if (! mobile)
		var quitBtn:Button = new Button(0, 90, "Exit", doQuit);
		#end

		var buttonGroup = new FlxSpriteGroup();
		buttonGroup.add(newGameBtn);
		buttonGroup.add(scoreBtn);
		buttonGroup.add(settingsBtn);

	#if demo
		var upSellBtn:Button = new Button(0, 90, "Full Version", doUpsell);
		upSellBtn.x = settingsBtn.x;
		upSellBtn.y = settingsBtn.y + 30;
	#if ! mobile
		quitBtn.y += 30;
	#end
		buttonGroup.add(upSellBtn);
	#end // demo

	#if (! mobile)
		buttonGroup.add(quitBtn);
	#end

		buttonGroup.screenCenter();
		buttonGroup.y += 30;

		title.screenCenter();
		title.y -= 60;
		title.x -= 2;

	#if mobile
		title.y += 15;
	#end

	#if demo
		title.y -= 15;
	#if (! mobile)
		buttonGroup.y -= 10;
	#end
	#end // demo

		add(backdrop);
		add(title);
		add(buttonGroup);

		var buildNote = new FlxText();
		buildNote.size = 8;
		buildNote.alignment = "right";
		buildNote.borderStyle = FlxTextBorderStyle.SHADOW;
		buildNote.borderSize = 1.0;
		buildNote.text = "Version " + MacroStuff.get_version();
	#if (! release && ! demo)
		buildNote.text += "\nBuilt: " + MacroStuff.compilation_date();
	#end
	#if demo
		buildNote.text += '\nLimited DEMO\n(${Reg.levels.length} levels)';
	#end
		buildNote.x = FlxG.width - 2 - buildNote.fieldWidth;
		buildNote.y = 2;
		add(buildNote);

		checkScore();

		Game.instance().playMusic();
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

	#if (! mobile)
		if (Input.escapePressed())
		{
			doQuit();
		}
	#end
	}

#if demo
	#if android
	static var UPSELL_LINK = "https://play.google.com/store/apps/details?id=com.irrationalidiom.quik_release";
	#else
	static var UPSELL_LINK = "http://irrationalidiom.com/quik";
	#end
	private function doUpsell():Void
	{
		Lib.getURL(new URLRequest(UPSELL_LINK));
	}
#end // demo

#if ! mobile
	private function doQuit():Void
	{
		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function() {
			System.exit(0);
		});
	}
#end

	private function doNewGame():Void
	{
		Game.resetGlobals();
		Game.autoSave();

		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function() {
			var switchToPlayState = function () {
				FlxG.switchState(new PlayState());
			};

			if (! Game.instance().seenInstructions)
			{
				var instructions = new InstructionsState();
				instructions.closeCallback = switchToPlayState;
				openSubState(instructions);
				Game.instance().seenInstructions = true;
			}
			else
			{
				switchToPlayState();
			}
		});
	}

	private function checkScore():Void
	{
		var score = Reg.score;
		if (Game.validHighscore(score) == false)
			return;

		Game.instance().cacheGlobalScores();

		var enter = new EnterNameState(score);
		enter.finished.add(function (name:String) {
			closeSubState();

			var highscore = new HighScore(name, score);
			var index = Game.insertHighscore(name, score);
			Reg.score = 0;

			Game.saveHighScores();

			Game.instance().submitGlobalScore(highscore);

			var state = new HighscoresState(index, highscore);
			FlxG.switchState(state);
		});
		openSubState(enter);
	}

	private function doHighScores():Void
	{
		FlxG.switchState(new HighscoresState());
	}

	private function doSettings():Void
	{
		openSubState(new SettingsState());
	}
}
