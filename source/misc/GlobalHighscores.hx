package misc;

import StringTools;
import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.crypto.Hmac;

import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.Event;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequestMethod;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

import Reg.HighScore;
import misc.MacroStuff;

class GlobalHighscores {
	static var POST_URL="http://127.0.0.1:1988/score/submit";
	static var TABLE_URL="http://127.0.0.1:1988/scores";

	#if demo
	static var USERAGENT = "Quik/" + MacroStuff.get_version() + "-DEMO";
	#else
	static var USERAGENT = "Quik/" + MacroStuff.get_version();
	#end

	static var SCORE_FIELD_NAME="s";
	static var NAME_FIELD_NAME="n";
	static var HASH_FIELD_NAME="h";

	static var TIMEOUT = 10;

	static var MAX_SCORES = 10;
	static var NAME_LEN = 3;

	#if demo
	static var SECRET = Obfuscate.obfuscateStr("CHANGE-ME-DEMO");
	#else
	static var SECRET = Obfuscate.obfuscateStr("CHANGE-ME-PRODUCTION");
	#end

	var hmac:Hmac;

	public function new() {
		hmac = new Hmac(HashMethod.SHA256);
	}

	public function postScore(score:HighScore, ?CallbackFn:Bool->Void)
	{
		var request = new URLRequest(POST_URL);
		request.method = URLRequestMethod.POST;
		request.userAgent = USERAGENT;

		var msg = '${score.name}|${score.points}';
		var hash = Base64.encode(hmac.make(Bytes.ofString(Obfuscate.deobfuscateStr(SECRET)), Bytes.ofString(msg)));
		var data = '${NAME_FIELD_NAME}=${score.name}&${SCORE_FIELD_NAME}=${score.points}&${HASH_FIELD_NAME}=${StringTools.urlEncode(hash)}';

		request.data = data;

		var loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;

		var onComplete = function(e:Event) {
			trace("submitted score:", score.name, "points:", score.points);
			if (CallbackFn != null)
				CallbackFn(true);
		};

		var onStatus = function (e:HTTPStatusEvent) {
			if (e.status != 200)
			{
				trace("error, code:", e.status);
				if (CallbackFn != null)
					CallbackFn(false);
			}
		};

		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);

		loader.load(request);
	}

	public function requestScores(callbackFn:Array<HighScore>->Void)
	{
		var request = new URLRequest(TABLE_URL);
		request.method = URLRequestMethod.GET;
		request.userAgent = USERAGENT;

		var loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.TEXT;

		var finished = false;

		var abort = function () {
			if (finished)
				return;
			callbackFn(null);
			finished = true;
		};

		var onComplete = function (e:Event) {
			if (finished)
				return;

			var scores = parseScoresData(loader.data);
			callbackFn(scores);

			finished = true;
		};

		var onStatus = function (e:HTTPStatusEvent) {
			if (e.status != 200)
			{
				trace("http status", e);
				abort();
				return;
			}
		};

		var onSecurityError = function(e:SecurityErrorEvent)
		{
			abort();
			trace("security error", e);
		};

		var onIOError = function(e:IOErrorEvent) {
			abort();
			trace("io error", e);
		};

		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onStatus);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);

		loader.load(request);
	}

	private function parseScoresData(data:Dynamic):Array<HighScore>
	{
		var d:String;

		try {
			d = Std.string(data);
		} catch (unknown : Dynamic)
		{
			trace("error converting data to String");
			return null;
		}

		if (d.length > 1024)
		{
			trace("response too long");
			return null;
		}

		var lines:Array<String> = d.split("\n");
		if (lines.length > MAX_SCORES + 1)
		{
			return null;
		}

		var result = new Array<HighScore>();

		var header = lines.shift().split(",");
		if (header.length != 2 || header[0] != "NAME" || header[1] != "SCORE")
			return null;

		for (line in lines)
		{
			var parts = line.split(",");

			if (parts.length != 2 || parts[0].length != NAME_LEN)
			{
				return null;
			}

			var value = Std.parseInt(parts[1]);
			if (value == null || value <= 0)
			{
				return null;
			}

			result.push(new HighScore(parts[0], value));
		}

		return result;
	}
}
