package ;

class GameText
{
	static public var StringsTable:Array<Array<String>> = [
		#if mobile
		[ "{PRESS_FLIP_KEY}", "TAP the screen" ],
		#else
		[ "{PRESS_FLIP_KEY}", "Hit SPACE" ],
		#end
	];

	static public function apply(str:String):String
	{
		for (mapping in StringsTable)
		{
			str = StringTools.replace(str, mapping[0], mapping[1]);
		}

		return str;
	}
}