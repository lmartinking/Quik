package;

import flixel.util.FlxDirectionFlags;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;

import flixel.sound.FlxSound;
import flixel.system.FlxQuadTree;

import flixel.group.FlxGroup;
//import flixel.group.FlxTypedGroup;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.path.FlxPath;
import flixel.util.FlxDestroyUtil;

import flixel.math.FlxPoint;

import flixel.tweens.FlxTween;
import flixel.effects.FlxFlicker;
import flixel.addons.effects.FlxTrail;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.effects.chainable.IFlxEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.effects.particles.FlxEmitter;

import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledPropertySet;

import Input;
import PlayStateHUD;
import LevelLoader;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var wallMap:FlxTilemap;
	private var bounceMap:FlxTilemap;
	private var decorationMap:FlxTilemap;
	private var overlayMap:FlxTilemapExt;
	private var spikeGroup:FlxTypedGroup<FlxSprite>;
	private var objectGroup:FlxTypedGroup<FlxObject>;
	private var powerupGroup:FlxTypedGroup<Powerup>;
	private var platformGroup:FlxTypedGroup<Platform>;
	private var collidableGroup:FlxGroup;
	private var endArea:FlxObject;
	private var explosion:FlxEmitter;

	private var player:FlxSprite;
	private var playerTrail:FlxTrail;
	private var midJumpCount:Int;
	private var flipCount:Int;
	private var bounceCount:Int;
	private var stopCount:Int;
	private var stopActive:Bool;
	private var preStopVelX:Float;
	private var smashTime:Float;
	private var timeLimit:Int;
	private var savePoint:SavePointState;

	private var sndJump:FlxSound;
	private var sndLand:FlxSound;
	private var sndDie:FlxSound;
	private var sndBounce:FlxSound;
	private var sndPowerupFlipHit:FlxSound;
	private var sndPowerupSmashHit:FlxSound;
	private var sndPowerupSavePoint:FlxSound;
	private var sndExplode:FlxSound;

	private var scanlines:FlxSprite;
	private var backdrop:FlxBackdrop;

	private var hud:PlayStateHUD;

	private var stats:Reg.LevelStats;

	private var pauseMenu:FlxSubState;

	static var OVERLAY_ALPHA = 0.3;
	static var fadeInColour:Int = FlxColor.BLACK;
	static var fadeOutColour:Int = FlxColor.BLACK;
	static var fadeDuration:Float = 1.0;

	override public function create():Void
	{
		super.create();

		FlxG.state.bgColor = FlxColor.BLACK;

		FlxG.signals.focusLost.add(Game.autoSave);
		FlxG.signals.focusLost.add(showPauseMenu);

		this.persistentDraw = true;

		// Load Sounds
		sndJump = FlxG.sound.load("assets/sounds/jump1.wav");
		sndLand = FlxG.sound.load("assets/sounds/hit1.wav");
		sndDie = FlxG.sound.load("assets/sounds/die1.wav");
		sndBounce = FlxG.sound.load("assets/sounds/bounce1.wav");
		sndPowerupFlipHit = FlxG.sound.load("assets/sounds/powerup_flip.wav");
		sndPowerupSmashHit = FlxG.sound.load("assets/sounds/powerup_smash.wav");
		sndPowerupSavePoint = FlxG.sound.load("assets/sounds/powerup_savepoint.wav");
		sndExplode = FlxG.sound.load("assets/sounds/smash.wav");

		// Load Sprites
		player = new FlxSprite(0, 0);
		player.loadGraphic("assets/images/player.png", true, 16, 16);
		player.animation.add("jump", [0], 1, true);
		player.animation.add("stop", [0], 1, true);
		player.animation.add("walk", [0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 2, 2, 2, 2], 1, true);

		player.animation.play("walk");

		player.width = 16;
		player.height = 16;

		playerTrail = new FlxTrail(player, null, 10, 2, 0.05, 0.005);

		// Player Handling
		player.acceleration.x = 100;
		player.acceleration.y = 500;
		player.maxVelocity.set(100, 200);
		player.facing = FlxDirectionFlags.RIGHT;

		// Player Variables
		midJumpCount = 1;
		flipCount = 0;
		bounceCount = 0;
		smashTime = 0.0;
		timeLimit = 0;

		stopActive = false;
		stopCount = 0;
		preStopVelX = 0;

		savePoint = Reg.savePoint;

		// Level Object Groups
		endArea = new FlxObject();
		objectGroup = new FlxTypedGroup<FlxObject>();
		powerupGroup = new FlxTypedGroup<Powerup>();
		platformGroup = new FlxTypedGroup<Platform>();
		collidableGroup = new FlxGroup();

		// Load the map
		var levelMap = Reg.levels[Reg.level];
		LevelLoader.loadMap(levelMap, this);

		// Camera Setup
		FlxG.camera.follow(player, FlxCameraFollowStyle.TOPDOWN_TIGHT, 5 / FlxG.updateFramerate);
		FlxG.camera.followLead.set(-10, -5);

		// HUD Setup
		stats = new Reg.LevelStats(Reg.level);

		if (timeLimit == 0) timeLimit = 300;
		stats.levelTimeLimit = timeLimit;

		hud = new PlayStateHUD();
		hud.setScore(0);
		hud.setTime(timeLimit);

		// Add things in draw order
		add(new FlxBackdrop("assets/images/backdrop.png"));

		if (wallMap != null)
			add(wallMap);
		if (bounceMap != null)
			add(bounceMap);
		if (spikeGroup != null)
			add(spikeGroup);
		if (decorationMap != null)
			add(decorationMap);

		explosion = createExplosion();

		collidableGroup.add(explosion);
		collidableGroup.add(player);

		// Scanlines Effect (overlayed)
		scanlines = new FlxSprite(0, 0);
		scanlines.loadGraphic("assets/images/scanlines.png", false, FlxG.width, FlxG.height);
		scanlines.scrollFactor.set(0, 0);
		scanlines.alpha = 0.1;

		add(explosion);

		add(powerupGroup);
		add(platformGroup);

		add(objectGroup);
		add(endArea);

		add(playerTrail);
		add(player);

		if (overlayMap != null)
			add(overlayMap);

		add(scanlines);

		add(hud);

		// Finally!
		Game.instance().playMusic();
		var restored = savePointRestore();

		var fadeInTime:Float = (restored ? fadeDuration * 0.25 : fadeDuration * 0.5);
		FlxG.camera.fade(fadeInColour, fadeInTime, true);

		FlxG.camera.focusOn(player.getMidpoint());

		if (Reg.resumed)
		{
			Reg.resumed = false;
			showPauseMenu();
		}
	}

	private function createExplosion():FlxEmitter
	{
		explosion = new FlxEmitter();
		explosion.color.set(FlxColor.WHITE, FlxColor.WHITE);
		explosion.elasticity.start.set(0.35, 0.35);
		explosion.elasticity.end.set(0.35, 0.35);
		explosion.setSize(2, 2);
		explosion.angle.set(0, 360, 0, 360);
		explosion.lifespan.set(0.2, 0.2 + 1.8);
		explosion.solid = true;
		explosion.acceleration.start.set(new FlxPoint(0.0, 100.0));
		explosion.acceleration.end.set(new FlxPoint(0.0, 100.0));
		explosion.loadParticles("assets/images/spike_gibs.png", 100, 0, true);
		return explosion;
	}

	override public function destroy():Void
	{
		FlxG.signals.focusLost.remove(showPauseMenu);
		FlxG.signals.focusLost.remove(Game.autoSave);

		stats = null;
		hud = FlxDestroyUtil.destroy(hud);
		backdrop = FlxDestroyUtil.destroy(backdrop);
		wallMap = FlxDestroyUtil.destroy(wallMap);
		decorationMap = FlxDestroyUtil.destroy(decorationMap);
		overlayMap = FlxDestroyUtil.destroy(overlayMap);
		spikeGroup = FlxDestroyUtil.destroy(spikeGroup);
		objectGroup = FlxDestroyUtil.destroy(objectGroup);
		powerupGroup = FlxDestroyUtil.destroy(objectGroup);
		platformGroup = FlxDestroyUtil.destroy(platformGroup);
		collidableGroup = FlxDestroyUtil.destroy(collidableGroup);
		endArea = FlxDestroyUtil.destroy(endArea);
		player = FlxDestroyUtil.destroy(player);
		scanlines = FlxDestroyUtil.destroy(scanlines);
		savePoint = null;
		playerTrail = null;
		explosion = null;

		sndJump = null;
		sndLand = null;
		sndDie = null;
		sndBounce = null;
		sndPowerupFlipHit = null;
		sndPowerupSmashHit = null;
		sndPowerupSavePoint = null;
		sndExplode = null;

		super.destroy();
	}

	private function savePointSave():Void
	{
		if (savePoint == null)
			savePoint = new SavePointState();

		savePoint.position.set(player.x, player.y);
		savePoint.velocity.set(player.velocity.x, player.velocity.y);
		savePoint.accelleration.set(player.acceleration.x, player.acceleration.y);
		savePoint.flipY = player.flipY;
		savePoint.facing = player.facing;
		savePoint.timeElapsed = stats.elapsedTime;
	}

	private function savePointRestore():Bool
	{
		if (savePoint == null)
			return false;

		player.facing = savePoint.facing;
		player.flipY = savePoint.flipY;
		player.acceleration.set(savePoint.accelleration.x, savePoint.accelleration.y);
		player.velocity.set(savePoint.velocity.x, savePoint.velocity.y);
		player.setPosition(savePoint.position.x, savePoint.position.y);

		stats.elapsedTime = savePoint.timeElapsed;

		return true;
	}

	private function playerBounce():Bool
	{
		if (player.alive == false)
			return false;

		var maxVel:Float = Math.abs(player.maxVelocity.x);

		if (player.facing == FlxDirectionFlags.RIGHT)
		{
			player.velocity.x = -maxVel;
			player.facing = FlxDirectionFlags.LEFT;
		}
		else if (player.facing == FlxDirectionFlags.LEFT)
		{
			player.velocity.x = maxVel;
			player.facing = FlxDirectionFlags.RIGHT;
		}

		player.acceleration.x = -player.acceleration.x;

		stats.bounces++;

		sndBounce.play(true);

		return true;
	}

	private function onBounceHit(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (obj1 != player && obj2 != player)
			return;

		playerBounce();
	}

	private function onSpikeHit(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (smashTime > 0.0)
		{
			// I am Invincible!
			if (obj1.alive)
			{
				obj1.kill();
				explosion.focusOn(obj1);
				explosion.start(true, 3, 10);
				stats.spikesSmashed++;
				sndExplode.play(true);
			}
		}
		else if (player.alive)
		{
			// Death
			doDie();

			remove(playerTrail);
			FlxFlicker.flicker(player, 1.0, 0.04, false, false);
			FlxTween.tween(player, { alpha: 0.0 }, 1.0);

			player.velocity.set(0, 0);
			player.acceleration.set(0, 0);
		}
	}

	private function onPlatformHit(obj1:FlxObject, obj2:FlxObject)
	{
		// TODO: Not yet implemented
	}

	private static function pixelPerfectProcess(obj1:FlxBasic, obj2:FlxBasic):Bool
	{
		if (Std.isOfType(obj1, FlxSprite) && Std.isOfType(obj2, FlxSprite))
		{
			var spr1:FlxSprite = cast obj1;
			var spr2:FlxSprite = cast obj2;
			if (FlxG.pixelPerfectOverlap(spr1, spr2))
				return true;
		}
		return false;
	}

	override public function update(elapsed:Float):Void
	{
		Input.update();

		if (stopCount > 0)
		{
			var stopHeld = Input.stopHeld();

			if (stopHeld && ! stopActive)
			{
				stopActive = true;
				trace("stop activated");
				preStopVelX = player.velocity.x;
				player.velocity.x = 0;
				player.acceleration.x = 0;
			}
			else if (! stopHeld && stopActive)
			{
				stopActive = false;
				trace("stop deactivated");

				stats.stopsUsed++;
				stopCount--;
				hud.setStopCount(stopCount);
				Input.setStopFlag(false);

				if (player.alive)
				{
					player.velocity.x = preStopVelX;
					player.acceleration.x = 100;
				}
			}
		}

		super.update(elapsed);

		// Collissions
		if (wallMap != null)
		{
			FlxG.collide(wallMap, collidableGroup);
		}

		if (bounceMap != null)
			FlxG.collide(bounceMap, player, onBounceHit);

		if (spikeGroup != null)
		{
			FlxG.overlap(spikeGroup, player, function (obj1:FlxBasic, obj2:FlxBasic) {
				var spike:FlxSprite = cast obj1;
				onSpikeHit(spike, player);
			}, pixelPerfectProcess);
		}

		if (powerupGroup != null)
			FlxG.overlap(powerupGroup, player, onPowerupHit);

		if (platformGroup != null)
		{
			FlxG.collide(platformGroup, player);
		}

		if (overlayMap != null)
		{
			var under = FlxG.overlap(overlayMap, player, null, function (Obj1:FlxObject, Obj2:FlxObject):Bool {
				return overlayMap.overlapsWithCallback(player);
			});

			overlayMap.alpha = (under ? OVERLAY_ALPHA : 1.0);
		}

		FlxG.collide(endArea, player, onEndAreaHit);

		// Player Handling
		player.flipX = (player.facing != FlxDirectionFlags.RIGHT);

		var prevTouchingSurface = (player.wasTouching & (FlxDirectionFlags.UP | FlxDirectionFlags.DOWN)) != 0;
		var nowTouchingSurface:Bool = (player.touching & (FlxDirectionFlags.UP | FlxDirectionFlags.DOWN)) != 0;
		var touchingSurface = prevTouchingSurface || nowTouchingSurface;

		if (nowTouchingSurface)
		{
			player.animation.play("walk");

			if (! prevTouchingSurface)
			{
				sndLand.play();
			}
		}
		else
		{
			player.animation.play("jump");
		}

		if (touchingSurface)
			midJumpCount = 1;

		var canJump:Bool = (touchingSurface || midJumpCount > 0);
		var canFlip:Bool = (flipCount > 0);

		if (player.alive && (canJump || canFlip) && Input.flipPressed())
		{
			if (! touchingSurface)
			{
				if (! canJump && canFlip)
				{
					flipCount--;
					stats.flipsUsed++;
					hud.setFlipCount(flipCount);
				}
				else
				{
					stats.airJumps++;
					midJumpCount--;
				}
			}
			else
			{
				stats.jumps++;
			}

			player.velocity.y = 0;

			player.flipY = !player.flipY;

			if (player.acceleration.y == 0)
			{
				var mult:Float = 1.0;
				if (player.flipY = true)
					mult = -mult;
				player.acceleration.y = 500 * mult;
			}
			else
			{
				player.acceleration.y *= -1.0;
			}

			player.animation.play("jump");
			sndJump.play(true);
		}

		var canBounce = (bounceCount > 0);
		if (canBounce && Input.bouncePressed())
		{
			if (playerBounce())
			{
				stats.bouncesUsed++;
				bounceCount--;
				hud.setBounceCount(bounceCount);
				Input.setBounceFlag(false);
			}
		}

		if (stopActive || (player.velocity.x == 0 && player.velocity.y == 0))
			player.animation.play("stop");

		// Warn player they can't do anything!
		hud.setCannotJumpOrFlip(midJumpCount == 0 && flipCount == 0);

		// Player death if they go off the map
		if (player.y <= -player.height || player.y >= wallMap.heightInTiles * 16)
		{
			doDie();
		}

		// Pause menu activation
		if (player.alive && Input.escapePressed())
		{
			showPauseMenu();
		}

		hud.setScore(Game.calculatePoints(stats));

		if (player.alive)
			stats.elapsedTime += FlxG.elapsed;

		// Time limit
		var remaining = timeLimit - stats.elapsedTime;
		if (remaining > 0)
		{
			hud.setTime(Std.int(timeLimit - Math.floor(stats.elapsedTime)));
		}
		else
		{
			hud.setTime(0);
			doDie();
		}

		if (smashTime > 0.0)
		{
			smashTime -= FlxG.elapsed;
			smashTime = Math.max(0.0, smashTime);

			if (smashTime == 0)
			{
				//FlxG.timeScale = 1.0;
			}
		}
	}

	public function handleLoadLayer(obj:FlxTilemap, name:String)
	{
		switch (name)
		{
			case "map":
				wallMap = obj;
				wallMap.follow();
				wallMap.solid = true;

			case "bounce":
				bounceMap = obj;

			case "decoration":
				decorationMap = obj;

			case "overlay":
				// Convert to a FlxTilemapExt since we need alpha support
				overlayMap = new FlxTilemapExt();
				var tileWidth = Math.floor(obj.width / obj.widthInTiles);
				var tileHeight = Math.floor(obj.height / obj.heightInTiles);
				overlayMap.loadMapFromArray(obj.getData(),
				                            obj.widthInTiles, obj.heightInTiles,
				                            LevelLoader.tileMapPath, tileWidth, tileHeight, FlxTilemapAutoTiling.OFF, 1);
		}
	}

	public function handleLoadSpriteGroup(grp:FlxTypedGroup<FlxSprite>, name:String)
	{
		switch (name)
		{
			case "spikes":
				spikeGroup = grp;
		}
	}

	public function handleLoadObject(obj:TiledObject, x:Int, y:Int, group:Array<TiledObject>)
	{
		switch (obj.name)
		{
			case "player":
				player.setPosition(x, y);

			case "end_zone":
				endArea.width = obj.width;
				endArea.height = obj.height;
				endArea.x = obj.x;
				endArea.y = obj.y;
				endArea.immovable = true;
		}

		switch (obj.type)
		{
			case "text":
				var text = createTextFromObject(obj);
				if (text != null)
					objectGroup.add(text);

			case "powerup_flip":
				powerupGroup.add(new Powerup(x, y, PowerupType.Flip));

			case "powerup_bounce":
				powerupGroup.add(new Powerup(x, y, PowerupType.Bounce));

			case "powerup_smash":
				powerupGroup.add(new Powerup(x, y, PowerupType.Smash));

			case "powerup_save":
				powerupGroup.add(new Powerup(x, y, PowerupType.SavePoint));

			case "powerup_stop":
				powerupGroup.add(new Powerup(x, y, PowerupType.Stop));

			case "platform_normal":
				var platform = createPlatformFromObject(obj, x, y);
				if (platform != null)
					platformGroup.add(platform);
		}
	}

	public function handleLevelProperties(prop:TiledPropertySet):Void
	{
		if (prop.contains("time_limit"))
		{
			timeLimit = Std.parseInt(prop.get("time_limit"));
		}
	}

	private function createPlatformFromObject(obj:TiledObject, x:Float, y:Float):Platform
	{
		var platform:Platform = null;

		if (obj.objectType == TiledObject.POLYLINE || obj.objectType == TiledObject.POLYGON)
		{
			var size = 2;
			if (obj.properties.contains("size"))
				size = Std.parseInt(obj.properties.get("size"));

			var typ = switch (obj.type)
			{
				case _: PlatformType.Normal;
			}

			platform = new Platform(x, y, typ, size);

			if (obj.properties.contains("speed"))
				platform.speed = Std.parseInt(obj.properties.get("speed"));

			platform.setPath(obj.points);
		}
		else
		{
			trace("unknown platform object?");
		}

		return platform;
	}

	private function createTextFromObject(obj:TiledObject):FlxText
	{
		if (obj.properties.contains("value") == false)
			return null;

		var txt = GameText.apply(obj.properties.get("value"));

		var t = new FlxText(obj.x, obj.y, obj.width, txt);
		t.alignment = "center";

		return t;
	}

	function doDie():Void
	{
		if (player.alive)
		{
			sndDie.play(true);

			// Leave the player existant so that the camera keeps going during the fadeout...
			player.alive = false;
			player.velocity.set(0, 0);
			player.acceleration.set(0, 0);

			Reg.level_stats.push(stats);

			var fadeOutTime = (savePoint != null ? fadeDuration : fadeDuration * 2.0);
			FlxG.camera.fade(fadeOutColour, fadeOutTime, false, function () {
				// keep save point around so we can restore it
				Reg.savePoint = this.savePoint;
				FlxG.resetState();
			});
		}
	}

	function onRestart():Void
	{
		player.alive = false;
		Reg.savePoint = null; // invalidate

		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function () {
			FlxG.resetState();
		});
	}

	private function onPowerupHit(powerup:Powerup, p:FlxSprite)
	{
		powerup.kill();

		switch (powerup.type)
		{
			case Flip:
				stats.flipsCollected += 5;
				flipCount = flipCount + 5;
				hud.setFlipCount(flipCount);
				sndPowerupFlipHit.play(true);

			case Bounce:
				bounceCount++;
				stats.bouncesCollected++;
				hud.setBounceCount(bounceCount);
				sndPowerupFlipHit.play(true);

			case Smash:
				//FlxG.timeScale = 1.3;
				smashTime = 5.0;

				for (sprite in spikeGroup)
				{
					FlxFlicker.flicker(sprite, smashTime);
				}

				sndPowerupSmashHit.play(true);

			case SavePoint:
				savePointSave();
				sndPowerupSavePoint.play();

			case Stop:
				stopCount++;
				stats.stopsCollected++;
				hud.setStopCount(stopCount);
				sndPowerupSavePoint.play(); // TODO: sound
		}
	}

	private function onEndAreaHit(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (player.alive == false)
			return;

		player.alive = false;
		player.velocity.set(0, 0);

		var effects:Array<IFlxEffect> = [ new FlxGlitchEffect() ];
		var effect = new FlxEffectSprite(player, effects);
		effect.setPosition(player.x, player.y);
		remove(player);
		add(effect);

		finishLevel();
	}

	private function finishLevel():Void
	{
		stats.levelPassed = true;
		Reg.level_stats.push(stats);

		Reg.score += Game.calculatePoints(stats, true);
		Reg.level++;

		trace("finish level. new level:", Reg.level);
		Reg.savePoint = null;
		Game.autoSave();

		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function () {
			var state = new PlayStateStats(stats, function () {
				var end = Reg.level == Reg.levels.length;
				if (end)
				{
					FlxG.signals.focusLost.remove(Game.autoSave);
					Game.autoSaveClear();
				}
				FlxG.camera.fade(fadeOutColour, fadeDuration, false, function () {
					FlxG.switchState(end ? new MenuState() : new PlayState());
				});
			});
			FlxG.switchState(state);
		});
	}

	function onLeave():Void
	{
		player.active = false;
		Reg.savePoint = null; // invalidate

		FlxG.signals.focusLost.remove(Game.autoSave);
		Game.autoSaveClear();

		FlxG.camera.fade(fadeOutColour, fadeDuration, false, function () {
			FlxG.switchState(new MenuState());
		});
	}

	function showPauseMenu():Void
	{
		var menu = new PlayStateMenu();

		menu.resumeSignal.add(function() {
			closeSubState();
			Input.setMouseVisible(false);
		});

		menu.restartSignal.add(function() {
			closeSubState();
			onRestart();
		});

		menu.leaveSignal.add(function() {
			closeSubState();
			onLeave();
		});

		Input.setMouseVisible(true);
		openSubState(menu);
	}

	function onQuit():Void
	{

	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// POWERUPS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum PowerupType
{
	Flip;
	Bounce;
	Smash;
	SavePoint;
	Stop;
}

class Powerup extends FlxSprite
{
	public var type:PowerupType;

	override public function new(X:Int, Y:Int, Type:PowerupType)
	{
		type = Type;

		super(X, Y, assetForType(Type));

		this.immovable = true;
	}

	public static function assetForType(Type:PowerupType)
	{
		var assetPath = switch (Type)
		{
			case Flip: "assets/images/powerup_flip.png";
			case Bounce: "assets/images/powerup_bounce.png";
			case Smash:	"assets/images/powerup_smash.png";
			case SavePoint: "assets/images/powerup_savepoint.png";
			case Stop: "assets/images/powerup_stop.png";
		}
		return assetPath;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// PLATFORMS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


enum PlatformType
{
	Normal;
}

class Platform extends FlxSprite
{
	public var type:PlatformType;

	public var speed:Int;

	public function setPath(points:Array<FlxPoint>)
	{
		var newPath = new Array<FlxPoint>();

		for (p in points)
		{
			newPath.push(new FlxPoint(this.x + p.x, this.y + p.y));
		}

		if (points.length > 0)
		{
			this.x = points[0].x;
			this.y = points[0].y;
		}

		this.path = FlxDestroyUtil.destroy(this.path);
		this.path = new FlxPath();
		this.path.start(newPath, speed, FlxPathType.YOYO);
		this.path.setNode(0);

		this.immovable = true;
	}

	override public function new(xPos:Float, yPos:Float, Type:PlatformType, size = 2)
	{
		type = Type;
		speed = 50;

		var assetPath = switch (size)
		{
			case 4: "assets/images/platform_normal_4.png";
			case 3: "assets/images/platform_normal_3.png";
			case 2: "assets/images/platform_normal_2.png";

			case _: "assets/images/platform_normal_2.png";
		}

		super(xPos, yPos, assetPath);

		centerOrigin();
	}

	override public function destroy():Void
	{
		this.path = FlxDestroyUtil.destroy(this.path);
		super.destroy();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Save Point State
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class SavePointState
{
	public var position:FlxPoint;
	public var velocity:FlxPoint;
	public var accelleration:FlxPoint;
	public var flipY:Bool;
	public var facing:Int;

	public var timeElapsed:Float;

	public function new()
	{
		position = new FlxPoint();
		velocity = new FlxPoint();
		accelleration = new FlxPoint();
		facing = 0;
		flipY = false;
		timeElapsed = 0.0;
	}
}