package ;

import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxSave;
import flixel.system.FlxSound;

import flash.Lib;

import Reg.HighScore;
import Reg.LevelStats;
import misc.GlobalHighscores;

class Game extends FlxGame {

	public var globalScoresEnabled:Bool;
	private var globalScores:GlobalHighscores;
	private var latestGlobalScores:Array<HighScore>;
	private var requestingGlobalScores:Bool;

	public var seenInstructions:Bool;

	public var musicDisabled(default, set):Bool;

	private static var SCOREBOARD_SIZE = 10;

	private static var _instance:Game;

	override public function new()
	{
		var gameWidth:Int = 300; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
		var gameHeight:Int = 200; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
		var initialState:Class<FlxState> = SplashState; // The FlxState the game starts with.
		var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
		var framerate:Int = 60; // How many frames per second the game should run at.
		var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
		var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
			trace("zoom is now", zoom);
		}

		#if mobile
		framerate = 30;
		#end

		seenInstructions = false;

		attachAutoSave();
		if (Reg.autoSave.data.active != null && Reg.autoSave.data.active == true)
		{
			Reg.score = Reg.autoSave.data.score;
			Reg.level = Reg.autoSave.data.level;
			trace("found active autosave", Reg.score, Reg.level);
			initialState = PlayState;
			Reg.resumed = true;
		}
		else
		{
			Reg.resumed = false;
		}

		super(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);

		#if mobile
		focusLostFramerate = 1;
		#end

		FlxG.signals.gameStarted.add(gameSetup);
		FlxG.signals.stateSwitched.add(onStateSwitch);
		FlxG.signals.focusLost.add(saveData);

		globalScoresEnabled = true;
		globalScores = new GlobalHighscores();
		latestGlobalScores = null;
		requestingGlobalScores = false;

		musicDisabled = false;

		_instance = this;
	}

	public static function instance():Game
	{
		return _instance;
	}

	public function set_musicDisabled(val:Bool):Bool
	{
		musicDisabled = val;

		if (FlxG.sound.music != null && FlxG.sound.music.exists)
		{
			if (musicDisabled)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.play();
		}

		return musicDisabled;
	}

	public function preloadMusic():Void
	{
		if (FlxG.sound.music == null)
		{
			trace("preload music");
			var music = new FlxSound();
			music.loadEmbedded("assets/music/bit2.ogg", true);
			music.persist = true;
			music.volume = 0.8;
			FlxG.sound.music = music;
		}
	}

	public function playMusic():Void
	{
		if (musicDisabled)
			return;

		if (FlxG.sound.music == null)
		{
			trace("loading music fresh");
			FlxG.sound.playMusic("assets/music/bit2.ogg", 0.8, true);
		}
		else if (FlxG.sound.music.active == false)
		{
			trace("resuming music");
			FlxG.sound.music.play();
		}
	}

	public function gameSetup():Void
	{
		#if android
		// Default behavior is to end the current activity, instead
		// we can use this for our pause screen
		FlxG.android.preventDefaultBackAction = true;
		#end

		loadGlobalSettings();
		loadHighScores();
		Input.setMouseCursor("assets/images/cursor.png");

		resetGlobals(true);

		cacheGlobalScores();
	}

	public static function attachAutoSave():Void
	{
		if (Reg.autoSave != null)
			return;

		Reg.autoSave = new FlxSave();
		Reg.autoSave.bind("quik-autosave");
	}

	public static function autoSave():Void
	{
		trace("autosave:", Reg.score, Reg.level);
		Reg.autoSave.data.active = true;
		Reg.autoSave.data.level = Reg.level;
		Reg.autoSave.data.score = Reg.score;
		Reg.autoSave.flush();
	}

	public static function autoSaveClear():Void
	{
		trace("clearing autosave");
		Reg.autoSave.data.active = false;
		Reg.autoSave.data.level = 0;
		Reg.autoSave.data.score = 0;
		Reg.autoSave.flush();
	}

	public static function detachAutoSave():Void
	{
		if (Reg.autoSave == null)
			return;

		Reg.autoSave.close();
		Reg.autoSave.destroy();
		Reg.autoSave = null;
	}

	public static function resetGlobals(onlyStats:Bool = false):Void
	{
		if (! onlyStats)
		{
			Reg.level = 0;
			Reg.score = 0;
		}

		Reg.level_stats = new Array<Reg.LevelStats>();
	}

	public function submitGlobalScore(score:HighScore):Void
	{
		if (! globalScoresEnabled)
			return;

		#if demo
		// Don't submit global scores in Demo mode
		return;
		#end

		if (latestGlobalScores != null && latestGlobalScores.length == SCOREBOARD_SIZE)
		{
			for (s in latestGlobalScores)
			{
				if (score.points > s.points)
				{
					globalScores.postScore(score);
					s = score; // overwrite existing entry (fake it locally)
					return;
				}
			}
		}
		else
		{
			// Either no cached scores, or there are free slots in the scoreboard
			globalScores.postScore(score);

			if (latestGlobalScores == null)
				latestGlobalScores = [];
			// Fake it locally, as updates to the global scores table may take a while to propagate
			latestGlobalScores.push(score);
		}
	}

	public function cacheGlobalScores():Void
	{
		if (! globalScoresEnabled || requestingGlobalScores)
			return;

		requestingGlobalScores = true;

		globalScores.requestScores( function(scores:Array<HighScore>) {
			if (scores != null && scores.length != 0)
			{
				trace("cached latest global scores");
				latestGlobalScores = scores.copy();
			}

			requestingGlobalScores = false;
		});
	}

	public function getGlobalScores():Array<HighScore>
	{
		if (latestGlobalScores == null)
		{
			return new Array<HighScore>();
		}

		return latestGlobalScores.copy();
	}

	private function onStateSwitch():Void
	{
		// FUDGE: At this point FlxG.state is the prior state; we have to dig to get our upcoming state
		var isPlayState = Std.is(_requestedState, PlayState);

		Input.setMouseVisible(! isPlayState);
	}

	private static var SAVE_SETTINGS_VERSION = 1;

	public static function loadGlobalSettings():Void
	{
		var settings = new FlxSave();
		settings.bind("quik-settings");

		if (settings.data.version != null && settings.data.version == SAVE_SETTINGS_VERSION)
		{
			if (settings.data.fixedTimestep != null)
				FlxG.fixedTimestep = settings.data.fixedTimestep;

			if (settings.data.soundMuted != null)
				FlxG.sound.muted = settings.data.soundMuted;

			if (settings.data.globalScoresEnabled != null)
				Game.instance().globalScoresEnabled = settings.data.globalScoresEnabled;

			#if desktop
			if (settings.data.fullscreen != null)
				FlxG.fullscreen = settings.data.fullscreen;
			#end
		}

		settings.close();
		settings.destroy();
	}

	public static function saveGlobalSettings():Void
	{
		var settings = new FlxSave();
		settings.bind("quik-settings");

		settings.erase();
		settings.data.version = SAVE_SCORES_VERSION;
		settings.data.fixedTimestep = FlxG.fixedTimestep;
		settings.data.globalScoresEnabled = Game.instance().globalScoresEnabled;
		settings.data.soundMuted = FlxG.sound.muted;
		settings.data.fullscreen = FlxG.fullscreen;

		settings.close();
		settings.destroy();
	}

	private static var DUMMY_SCORES = [100000, 50000, 25000, 15000, 10000, 5000, 2500, 1000, 500, 100];
	private static var SAVE_SCORES_VERSION = 1;

	public static function loadHighScores():Void
	{
		var scores = new FlxSave();
		scores.bind("quik-highscores");

		if (scores.data.version != null && scores.data.version == SAVE_SCORES_VERSION)
		{
			if (scores.data.scores != null)
				Reg.highscores = scores.data.scores;
		}
		else
		{
			trace("No scores found. Using dummy data");

			for (score in DUMMY_SCORES)
			{
				var s = new Reg.HighScore("AAA", score);
				Reg.highscores.push(s);
			}
		}

		scores.close();
		scores.destroy();
	}

	public static function saveHighScores():Void
	{
		var scores = new FlxSave();
		scores.bind("quik-highscores");

		scores.erase();
		scores.data.version = SAVE_SCORES_VERSION;
		scores.data.scores = Reg.highscores.copy();

		scores.close();
		scores.destroy();
	}

	public static function validHighscore(value:Int):Bool
	{
		if (Reg.highscores.length < SCOREBOARD_SIZE)
			return true;

		for (score in Reg.highscores)
		{
			if (value >= score.points)
				return true;
		}

		return false;
	}

	public static function insertHighscore(name:String, value:Int):Int
	{
		var score = new HighScore(name, value);

		for (idx in 0...Reg.highscores.length)
		{
			if (value >= Reg.highscores[idx].points)
			{
				Reg.highscores.insert(idx, score);
				Reg.highscores.pop();
				return idx;
			}
		}

		Reg.highscores.insert(0, score);
		return 0;
	}

	private static var FLIP_VALUE = 1000;
	private static var FLIP_KEPT_VALUE = 1500;
	private static var BOUNCE_POWERUP_VALUE = 1000;
	private static var BOUNCE_POWERUP_KEPT_VALUE = 1500;
	private static var STOP_VALUE = 1000;
	private static var STOP_KEPT_VALUE = 1500;
	private static var AIR_JUMP_VALUE = 50;
	private static var JUMP_VALUE = 25;
	private static var BOUNCE_VALUE = 1;
	private static var TIME_SECOND_VALUE = 500;
	private static var SPIKE_VALUE = 250;

	public static function calculatePoints(stats:LevelStats, calculateTime:Bool = false):Int
	{
		var points:Int = 0;

		points += (stats.flipsCollected * FLIP_VALUE);
		points += ((stats.flipsCollected - stats.flipsUsed) * FLIP_KEPT_VALUE);

		points += (stats.bouncesCollected * BOUNCE_POWERUP_VALUE);
		points += ((stats.bouncesCollected - stats.bouncesUsed) * BOUNCE_POWERUP_KEPT_VALUE);

		points += (stats.stopsCollected * STOP_VALUE);
		points += ((stats.stopsCollected - stats.stopsUsed) * STOP_KEPT_VALUE);

		points += (stats.airJumps * AIR_JUMP_VALUE);
		points += (stats.jumps * JUMP_VALUE);
		points += (stats.bounces * BOUNCE_VALUE);
		points += (stats.spikesSmashed * SPIKE_VALUE);

		if (calculateTime)
		{
			var limit = stats.levelTimeLimit;
			var remaining = limit - stats.elapsedTime;

			points += Math.floor(remaining * TIME_SECOND_VALUE);
		}

		return points;
	}

	private static function saveData():Void
	{
		saveGlobalSettings();
	}
}
