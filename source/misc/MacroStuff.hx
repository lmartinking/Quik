package misc;

import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Context;

import haxe.io.Bytes;

#if macro
import sys.io.File;
#end

class MacroStuff {
	macro static public function compilation_date():Expr {
		var now_str = DateTools.format(Date.now(), "%Y-%m-%d");
		// an "ExprDef" is just a piece of a syntax tree. Something the compiler
		// creates itself while parsing an a .hx file
		return {expr: EConst(CString(now_str)) , pos : Context.currentPos()};
	}

	macro public static function get_version():Expr
	{
		var xml = Xml.parse(File.getContent("./" + "Project.xml"));
		var fast = new haxe.xml.Access(xml.firstElement());

		return Context.makeExpr(fast.node.app.att.version, Context.currentPos());
	}
}

class Obfuscate
{
	private static function transformBytes(bytes:Bytes, xor:Array<Int>):Bytes
	{
		for (i in 0 ... xor.length)
		{
			xor[i] &= 0xff;
		}

		var xorIndex = 0;

		for (i in 0 ... bytes.length)
		{
			var b = bytes.get(i);
			b ^= xor[xorIndex];
			bytes.set(i, b);

			xorIndex++;
			if (xorIndex == xor.length)
				xorIndex = 0;
		}

		return bytes;
	}

	// 
	// import random
	// [ hex(random.randint(0, 255)) for n in range(8) ]
	//
	private static var PATTERN = [ 0x6b, 0x87, 0x52, 0xf5, 0x17, 0xb6, 0x62, 0x7f ];

	public static function deobfuscateStr(input:String):String
	{
		// The incoming string is hex encoded by `obfuscateStr`.
		var bytes = Bytes.ofHex(input);
		return transformBytes(bytes, PATTERN).toString();
	}

	macro public static function obfuscateStr(str:String):Expr
	{
		// NOTE: Haxe now validates the the resultant string when using Bytes.toString()
		//       so encode as a hex string.
		var bytes = Bytes.ofHex(str);
		var obfuscated = transformBytes(bytes, PATTERN).toHex();
		return Context.makeExpr(obfuscated, Context.currentPos());
	}
}