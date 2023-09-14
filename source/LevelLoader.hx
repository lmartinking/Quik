package ;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

import flixel.tile.FlxTilemap;
import flixel.tile.FlxBaseTilemap;

import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;


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
			if (Std.isOfType(layer, TiledTileLayer))
			{
				// Tile layers
				var tileLayer:TiledTileLayer = cast layer;

				switch (tileLayer.name)
				{
					case "map", "bounce", "decoration", "overlay":
						var autoTile = tileLayer.name == "map" ? FlxTilemapAutoTiling.AUTO : FlxTilemapAutoTiling.OFF;
						var map = new FlxTilemap();
						map.loadMapFromArray(tileLayer.tileArray,
						tileLayer.width, tileLayer.height,
						tileMapPath, m.tileWidth, m.tileHeight, autoTile, 1, 1, 1);
						delegate.handleLoadLayer(map, tileLayer.name);

					case "spikes":
						var spikeGroup = spriteGroupFromLayer(tileLayer, spikeSpritePath);
						delegate.handleLoadSpriteGroup(spikeGroup, tileLayer.name);
				}
			}
			else if (Std.isOfType(layer, TiledObjectLayer))
			{
				// Object layers
				var objLayer:TiledObjectLayer = cast layer;

				for (obj in objLayer.objects)
				{
					var x:Int = obj.x;
					var y:Int = obj.y;

					// objects in tiled are aligned bottom-left (top-left in flixel)
					if (obj.gid != -1)
						y -= objLayer.map.getGidOwner(obj.gid).tileHeight;

					delegate.handleLoadObject(obj, x, y, objLayer.objects);
				}
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

	static private function spriteGroupFromLayer(layer:TiledTileLayer, image:Dynamic):FlxTypedGroup<FlxSprite>
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
