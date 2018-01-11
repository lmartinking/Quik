package ;


import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.addons.display.FlxBackdrop;

import de.polygonal.core.fmt.NumberFormat;

import ui.Button;

using flixel.util.FlxSpriteUtil;

class EnterNameState extends FlxSubState {
	private static var NAME_LENGTH = 3;
	private static var CHARS = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ];

	private var points:Int;

	private var characters:Array<Int>;
	private var texts:Array<FlxText>;
	private var position:Int;

	public var finished:FlxTypedSignal<String->Void>;

	public override function new(pointsValue:Int) {
		super();

		points = pointsValue;
		finished = new FlxTypedSignal<String->Void>();
	}

	public override function create():Void
	{
		characters = new Array<Int>();
		texts = new Array<FlxText>();
		position = 0;

		for (n in 0...NAME_LENGTH)
		{
			texts.push(new FlxText(0, 0));
			characters.push(0);
		}

		var title = new FlxText(0, 0, 0, "NEW HIGH SCORE!");
		title.centerOffsets();
		title.scale.set(2.0, 2.0);
		title.borderStyle = FlxTextBorderStyle.SHADOW;
		title.screenCenter(FlxAxes.X);
		title.y = 30;

		var pointsTxt = null;
		if (points > 0)
		{
			pointsTxt = new FlxText(0, 0, 0, '${NumberFormat.groupDigits(points, ",")} POINTS');
			pointsTxt.centerOffsets();
			pointsTxt.borderStyle = FlxTextBorderStyle.SHADOW;
			pointsTxt.scale.set(1.5, 1.5);
			pointsTxt.screenCenter(FlxAxes.X);
			pointsTxt.y = title.y + title.height + 15;
		}

		var btnUp = new Button(0, 0, "-", downChar);
		var btnDown = new Button(0, 20, "+", upChar);
		var btnStore = new Button(10, 5, "Enter", storeChar);

		var xPos:Int = 10;
		var yPos = FlxG.height - btnUp.height - 10;

		btnDown.y = yPos;
		btnDown.centerOffsets();
		btnDown.screenCenter(FlxAxes.X);

		btnUp.centerOffsets();
		btnUp.x = btnDown.x - btnUp.width - 10;
		btnUp.y = yPos;

		btnStore.centerOffsets();
		btnStore.y = yPos;
		btnStore.x = btnDown.x + btnDown.width + 10;

		var backdrop = new FlxBackdrop("assets/images/backdrop.png");
		backdrop.velocity.set(-10, -10);

		add(backdrop);

		add(title);
		if (pointsTxt != null)
			add(pointsTxt);

		add(btnUp);
		add(btnDown);
		add(btnStore);

		xPos = Math.floor(FlxG.width / 2);
		yPos = FlxG.height / 2;

		xPos -= 50;
		for (txt in texts)
		{
			txt.x = xPos;
			txt.y = yPos;

			txt.centerOffsets();
			txt.scale.set(3.0, 3.0);

			xPos += 50;

			add(txt);
		}

		updateTexts();
	}

	private function upChar():Void
	{
		if (position >= NAME_LENGTH)
			return;

		var val = characters[position];
		val++;
		if (val >= CHARS.length)
			val = 0;
		characters[position] = val;

		updateTexts();
	}

	private function downChar():Void
	{
		if (position >= NAME_LENGTH)
			return;

		var val = characters[position];
		val--;
		if (val < 0)
			val = CHARS.length - 1;
		characters[position] = val;

		updateTexts();
	}

	private function storeChar():Void
	{
		position++;

		updateTexts();

		if (position >= NAME_LENGTH)
		{
			var name = "";
			for (char in characters)
			{
				name += CHARS[char];
			}
			finished.dispatch(name);
		}
	}

	private function updateTexts():Void
	{
		for (idx in 0...characters.length)
		{
			var txt = texts[idx];

			txt.text = CHARS[characters[idx]];

			if (idx == position)
			{
				txt.borderStyle = FlxTextBorderStyle.OUTLINE;
				txt.borderColor = FlxColor.BLACK;
			}
			else
			{
				txt.borderStyle = FlxTextBorderStyle.NONE;
			}
		}
	}

	public override function destroy():Void
	{
		characters = null;
		texts = null;

		super.destroy();
	}
}
