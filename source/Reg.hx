package;

import flixel.util.FlxSave;

import PlayState.SavePointState;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<String> = [
		"assets/data/level0_intro.tmx",
		"assets/data/level0_zigzag.tmx",
		"assets/data/level0_bounce.tmx",
		"assets/data/level0_powerup.tmx",

		#if (! demo)
		"assets/data/level5.tmx", // mario inspired
		"assets/data/level1.tmx", // 2 level cave
		"assets/data/level8.tmx", // smash
		"assets/data/level2.tmx", // upwards bounce
		"assets/data/level7.tmx", // flappy inspired
		"assets/data/level11.tmx",// all platforms
		"assets/data/level3.tmx", // progression then flying
		"assets/data/level4.tmx", // many paths
		"assets/data/level12.tmx",// more platforms
		"assets/data/level6.tmx", // maze
		"assets/data/level10.tmx",// blocks, save, bounce, squishy
		"assets/data/level13.tmx",// platforms and stop and spikes
		#end
	];

	public static var level:Int = 0;

	public static var level_stats:Array<LevelStats> = [];

	public static var highscores:Array<HighScore> = []; // local

	public static var score:Int = 0;

	public static var saves:Array<FlxSave> = [];

	public static var autoSave:FlxSave;
	public static var resumed:Bool;

	public static var savePoint:SavePointState;
}

class HighScore
{
	public var name:String;
	public var points:Int;

	public function new(scoreName:String, pointsValue:Int)
	{
		name = scoreName;
		points = pointsValue;
	}
}

class LevelStats
{
	public var levelIndex:Int;
	public var levelPassed:Bool;
	public var levelTimeLimit:Int;

	public var flipsCollected:Int;
	public var flipsUsed:Int;

	public var airJumps:Int;
	public var jumps:Int;
	public var bounces:Int;

	public var bouncesCollected:Int;
	public var bouncesUsed:Int;

	public var stopsCollected:Int;
	public var stopsUsed:Int;

	public var spikesSmashed:Int;

	public var elapsedTime:Float;

	public var points:Int;

	public function new(index:Int)
	{
		levelIndex = index;
		levelPassed = false;
		levelTimeLimit = 0;

		flipsCollected = 0;
		flipsUsed = 0;

		airJumps = 0;
		jumps = 0;
		bounces = 0;

		bouncesCollected = 0;
		bouncesUsed = 0;

		stopsCollected = 0;
		stopsUsed = 0;

		spikesSmashed = 0;

		elapsedTime = 0.0;

		points = 0;
	}
}