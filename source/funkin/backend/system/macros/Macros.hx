package funkin.backend.system.macros;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;

/**
 * Macros containing additional help functions to expand HScript capabilities.
 */
class Macros {
	public static function addAdditionalClasses() {
		for(inc in ["shaders", "hxcodec", "improved"]) //Create Classes Inside of These Folders
			Compiler.include(inc);
		//Create These Classes
		Compiler.include("flixel.util.FlxColor");
		Compiler.include("flixel.util.FlxAxes");
		Compiler.include("flixel.math.FlxPoint");

		var isHl = Context.defined("hl");

		if(Context.defined("sys")) {
			for(inc in ["sys", "openfl.net"]) {
				if(!isHl)
					Compiler.include(inc);
				else {
					// TODO: Hashlink
					//Compiler.include(inc, ["sys.net.UdpSocket", "openfl.net.DatagramSocket"]); // fixes FATAL ERROR : Failed to load function std@socket_set_broadcast
				}
			}
		}
	}

	public static function initMacros() {
		if(Context.defined("hl"))
			HashLinkFixer.init();
	}
}
#end