package ;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;

import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledTile;

class LevelLoader
{
	public static var tileMapPath:String = "assets/tilemap_1.png";
	public static var spikeSpritePath = "assets/images/spike_1.png";

	public static function loadMap(tiledLevel:Dynamic, delegate:PlayState)
	{
		var m:TiledMap = new TiledMap(tiledLevel);

		delegate.handleLevelProperties(m.properties);

		for (layer in m.layers)
		{
			switch (layer.name)
			{
				case "map", "bounce", "decoration", "overlay":
					var autoTile = layer.name == "map" ? FlxTilemap.AUTO : FlxTilemap.OFF;
					var map = new FlxTilemap();
					map.widthInTiles = layer.width;
					map.heightInTiles = layer.height;
					map.loadMap(layer.tileArray, tileMapPath, m.tileWidth, m.tileHeight, autoTile, 1, 1, 1);
					delegate.handleLoadLayer(map, layer.name);

				case "spikes":
					var spikeGroup = spriteGroupFromLayer(layer, spikeSpritePath);
					delegate.handleLoadSpriteGroup(spikeGroup, layer.name);
			}
		}

		for (objGroup in m.objectGroups)
		{
			for (obj in objGroup.objects)
			{
				var x:Int = obj.x;
				var y:Int = obj.y;

				// objects in tiled are aligned bottom-left (top-left in flixel)
				if (obj.gid != -1)
					y -= objGroup.map.getGidOwner(obj.gid).tileHeight;

				delegate.handleLoadObject(obj, x, y, objGroup);
			}
		}
	}

	private static function applyTransformations(tile:TiledTile, sprite:FlxSprite)
	{
		var flipX = false;
		var flipY = false;
		var angle:Float = 0.0;

		// Tiled appears to rotate first, then apply flipping,
		// so we need to the swap the flip horiz/vert flags
		switch (tile.rotate)
		{
			case TiledTile.ROTATE_0:
				flipX = tile.isFlipHorizontally;
				flipY = tile.isFlipVertically;

			case TiledTile.ROTATE_90:
				angle = 90.0;
				flipX = tile.isFlipVertically;
				flipY = tile.isFlipHorizontally;

			case TiledTile.ROTATE_270:
				angle = 270.0;
				flipX = tile.isFlipVertically;
				flipY = tile.isFlipHorizontally;
		}

		sprite.flipX = flipX;
		sprite.flipY = flipY;
		sprite.angle = angle;
	}

	static private function spriteGroupFromLayer(layer:TiledLayer, image:Dynamic):FlxTypedGroup<FlxSprite>
	{
		var group = new FlxTypedGroup<FlxSprite>();

		// trigger load of data
		var _unused = layer.tileArray;

		for (row in 0 ... layer.height)
		{
			for (col in 0 ... layer.width)
			{
				var index = (row * layer.width) + col;
				var tile = layer.tiles[index];

				if (tile == null)
					continue;

				var x = col * layer.map.tileWidth;
				var y = row * layer.map.tileHeight;

				var sprite = new FlxSprite(x, y, image);

				applyTransformations(tile, sprite);

				sprite.moves = false;
				sprite.immovable = true;

				group.add(sprite);
			}
		}

		return group;
	}
}
