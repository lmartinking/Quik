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
		var fast = new haxe.xml.Fast(xml.firstElement());

		return Context.makeExpr(fast.node.app.att.version, Context.currentPos());
	}
}

class Obfuscate
{
	private static function transform(str:String, xor:Array<Int>):String
	{
		var bytes = Bytes.ofString(str);

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

		return bytes.toString();
	}

	// 
	// import random
	// [ hex(random.randint(0, 255)) for n in range(8) ]
	//
	private static var PATTERN = ['0xe', '0x8d', '0x83', '0xf2', '0x43', '0x60', '0x6f', '0x27'];

	public static function deobfuscateStr(str:String):String
	{
		return transform(str, PATTERN);
	}

	macro public static function obfuscateStr(str:String):Expr
	{
		var obfuscated = transform(str, PATTERN);
		return {expr: EConst(CString(obfuscated)) , pos : Context.currentPos()};
	}
}
