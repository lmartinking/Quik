package ui;

import flixel.ui.FlxTypedButton;
import flixel.FlxSprite;

import PlayState.PowerupType;
import PlayState.Powerup;

class PowerupButton extends FlxTypedButton<FlxSprite>
{
	private var type:PowerupType;

	public override function new (X:Int, Y:Int, Type:PowerupType)
	{
		type = Type;

		super(X, Y, null);

		loadGraphic("assets/ui/button_powerup.png", true, 30, 29);

		labelOffsets[0].set(5, 4.7);
		labelOffsets[1].set(5, 4.7);
		labelOffsets[2].set(8, 7);

		onDown.callback = onClicked;

		label = new FlxSprite(0, 0, Powerup.assetForType(Type));
	}

	private function onClicked():Void
	{
		trace("powerup button clicked");
	}
}
