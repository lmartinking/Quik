package misc;

class Format {
    // Copied from de.polygonal.core.fmt NumberFormat.groupDigits
    // This code has been removed from newer versions and the old version of the package
    // does not work with newer versions of Haxe :-(
	public static function groupDigits(x:Int, thousandsSeparator = "."):String {
		var n:Float = x;
		var c = 0;
		while (n > 1) {
			n /= 10;
			c++;
		}

		c = cast c / 3;

		var source = Std.string(x);

		if (c == 0)
			return source;
		else {
			var target = "";

			var i = 0;
			var j = source.length - 1;
			while (j >= 0) {
				if (i == 3) {
					target = source.charAt(j--) + thousandsSeparator + target;
					i = 0;
					c--;
				} else
					target = source.charAt(j--) + target;
				i++;
			}

			return target;
		}
	}
}
