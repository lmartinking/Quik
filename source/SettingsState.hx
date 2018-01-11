package ;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;

import ui.Button;
import ui.CheckBox;

class SettingsState extends FlxSubState {
	override public function new() {
		super();
	}

	override public function create():Void
	{
		var backdrop = new FlxBackdrop("assets/images/backdrop.png");
		backdrop.velocity.set(-5, -5);
		add(backdrop);

		var backBtn = new Button(10, 10, "Back", function() {
			close();
		});
		backBtn.y = FlxG.height - backBtn.height - 10;

		var yPos = 10;

		var frameSkip = new CheckBox(10, yPos, "Frame skip");
		frameSkip.checked = ! FlxG.fixedTimestep;
		frameSkip.callback = function () {
			FlxG.fixedTimestep = !frameSkip.checked;
		};

		yPos += 30;

		var muteSound = new CheckBox(10, yPos, "Mute all sounds");
		muteSound.checked = FlxG.sound.muted;

		yPos += 30;

		var muteMusic = new CheckBox(10, yPos, "Mute music");
		muteMusic.checked = Game.instance().musicDisabled;
		muteMusic.callback = function () {
			Game.instance().musicDisabled = muteMusic.checked;
		}

		muteSound.callback = function () {
			FlxG.sound.muted = muteSound.checked;

			if (! FlxG.sound.muted)
			{
				FlxG.sound.play("assets/sounds/bounce1.wav");

				if (! muteMusic.checked)
					Game.instance().musicDisabled = false;
			}
			else
			{
				Game.instance().musicDisabled = true;
			}
		}

		yPos += 30;

		#if desktop
		var fullScreen = new CheckBox(10, yPos, "Fullscreen");
		fullScreen.checked = FlxG.fullscreen;
		fullScreen.callback = function () {
			FlxG.fullscreen = fullScreen.checked;
		};
		add(fullScreen);
		yPos += 30;
		#end // desktop

		yPos += 10;
		var globalScores = new CheckBox(10, yPos, "");
		globalScores.text = "Fetch and submit global high scores";
		globalScores.checked = Game.instance().globalScoresEnabled;
		globalScores.callback = function () {
			var enabled = globalScores.checked;
			Game.instance().globalScoresEnabled = enabled;

			if (enabled && Game.instance().getGlobalScores().length == 0)
				Game.instance().cacheGlobalScores();
		}
		#if demo
		globalScores.text = "Fetch global high scores";
		#end

		add(backBtn);

		add(frameSkip);
		add(muteSound);
		add(muteMusic);
		add(globalScores);
	}

	override public function destroy():Void
	{
		Game.saveGlobalSettings();

		super.destroy();
	}
}
