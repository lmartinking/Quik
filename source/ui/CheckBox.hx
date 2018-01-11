package ui;

import flixel.addons.ui.FlxUICheckBox;

class CheckBox extends FlxUICheckBox {
	public function new(X:Float, Y:Float, Label:String) {
		super(X, Y, "assets/ui/check_box.png", "assets/ui/check_mark.png", Label, 200);
		textY = -1;
		textX = 5;
	}
}
