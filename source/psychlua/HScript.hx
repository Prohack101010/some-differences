package psychlua;

import flixel.FlxBasic;
import psychlua.FunkinLua;
import psychlua.CustomSubstate;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

#if hscript
import hscript.Parser;
import hscript.Interp;
import hscript.Expr;
import haxe.Exception;
#end

#if (HSCRIPT_ALLOWED && SScript >= "3.0.0")
import tea.SScript;
class HScript extends SScript
{
	public var parentLua:FunkinLua;

	public function setParent(parent:Dynamic) {
		interp.allowPublicVariables = true;
		interp.scriptObject = parent;
		//interp.publicVariables = map;
	}
	
	public function setPublicMap(map:Map<String, Dynamic>) {
		interp.publicVariables = map;
	}
	
	public static function initHaxeModule(parent:FunkinLua)
	{
		#if (SScript >= "3.0.0")
		var hs:HScript = parent.hscript;
		if(hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
		#end
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e) null;
		#if (SScript >= "3.0.0")
		if(parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent, code, varsToBring);
		}
		else
		{
			hs.doString(code);
			@:privateAccess
			if(hs.parsingExceptions != null && hs.parsingExceptions.length > 0)
			{
				@:privateAccess
				for (e in hs.parsingExceptions)
					if(e != null)
						PlayState.instance.addTextToDebug('ERROR ON LOADING (${hs.origin}): ${e.message.substr(0, e.message.indexOf('\n'))}', FlxColor.RED);
			}
		}
		#end
	}
	public var origin:String;
	override public function new(?parent:FunkinLua, ?file:String, ?varsToBring:Any = null)
	{
		if (file == null)
			file = '';
			
		this.varsToBring = varsToBring;

		/*
		if (PlayState.publicVariables != [] && PlayState.publicVariables != null)
			interp.publicVariables = PlayState.publicVariables;
		*/
		super(file, false, false);

		parentLua = parent;
		if (parent != null)
			origin = parent.scriptName;
		if (scriptFile != null && scriptFile.length > 0)
			origin = scriptFile;
		preset();
		execute();
		/*
		if (PlayState.publicVariables == [] || PlayState.publicVariables == null) PlayState.publicVariables = interp.publicVariables;
		PlayState.instance.addTextToDebug('publicVariables in Parent: ' + PlayState.publicVariables, FlxColor.GREEN);
		PlayState.instance.addTextToDebug('publicVariables in Interp: ' + interp.publicVariables, FlxColor.YELLOW);
		*/
	}

	var varsToBring:Any = null;
	override function preset()
	{
		#if (SScript >= "3.0.0")
		super.preset();

		// Some very commonly used classes
		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.system.FlxSound);
		set('SwipeUtil', mobile.backend.SwipeUtil);
		set('FlxText', flixel.text.FlxText);
		set('FlxCamera', flixel.FlxCamera);
		set('PsychCamera', backend.PsychCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('Countdown', backend.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', Note);
		set('CustomSubstate', psychlua.CustomSubstate);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('CustomShader', funkin.backend.shaders.CustomShader); //CustomShader from CNE
		set('FunkinShader', funkin.backend.shaders.FunkinShader); //FunkinShader from CNE
		set('StringTools', StringTools);
		#if flxanimate
		set('FlxAnimate', FlxAnimate);
		#end

		// Functions & Variables
		//Originals
		set('setVar', function(name:String, value:Dynamic) {
			PlayState.instance.variables.set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});

		#if SCRIPTING_ALLOWED
		set('setGlobalVar', function(name:String, value:Dynamic) {
			ScriptingVars.globalVars.set(name, value);
			return value;
		});
		set('getGlobalVar', function(name:String) {
			var result:Dynamic = null;
			if(ScriptingVars.globalVars.exists(name)) result = ScriptingVars.globalVars.get(name);
			return result;
		});
		set('removeGlobalVar', function(name:String)
		{
			if(ScriptingVars.globalVars.exists(name))
			{
				ScriptingVars.globalVars.remove(name);
				return true;
			}
			return false;
		});
		#end

		//Others
		set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});

		// For adding your own callbacks
		#if LUAVPAD_ALLOWED
		//OMG
		set('virtualPadPressed', function(buttonPostfix:String):Bool
		{
			return PlayState.checkVPadPress(buttonPostfix, 'pressed');
		});
		
		set('virtualPadJustPressed', function(buttonPostfix:String):Bool
		{
			return PlayState.checkVPadPress(buttonPostfix, 'justPressed');
		});
		
		set('virtualPadReleased', function(buttonPostfix:String):Bool
		{
			return PlayState.checkVPadPress(buttonPostfix, 'released');
		});
		
		set('virtualPadJustReleased', function(buttonPostfix:String):Bool
		{
			return PlayState.checkVPadPress(buttonPostfix, 'justReleased');
		});
		
		set('addVirtualPad', function(DPad:String, Action:String, ?addToCustomSubstate:Bool = false, ?posAtCustomSubstate:Int = -1):Void
		{
			PlayState.instance.makeLuaVirtualPad(DPad, Action);
			if (addToCustomSubstate)
			{
				if (PlayState.instance.luaVirtualPad != null || !PlayState.instance.members.contains(PlayState.instance.luaVirtualPad))
					CustomSubstate.insertLuaVpad(posAtCustomSubstate);
			}
			else
				PlayState.instance.addLuaVirtualPad();
		});
		
		set('addVirtualPadCamera', function():Void
		{
			PlayState.instance.addLuaVirtualPadCamera();
		});
		
		set('removeVirtualPad', function():Void
		{
			PlayState.instance.removeLuaVirtualPad();
		});
		#end

		// not very tested but should work
		set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			#if LUA_ALLOWED
			for (script in PlayState.instance.luaArray)
				if(script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);
			#end
			FunkinLua.customFunctions.set(name, func);
		});

		// tested
		set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if(funk == null) funk = parentLua;
			
			if(parentLua != null) funk.addLocalCallback(name, func);
			else FunkinLua.luaTrace('createCallback ($name): 3rd argument is null', false, false, FlxColor.RED);
		});

		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				var msg:String = e.message.substr(0, e.message.indexOf('\n'));
				if(parentLua != null)
				{
					FunkinLua.lastCalledScript = parentLua;
					msg = origin + ":" + parentLua.lastCalledFunction + " - " + msg;
				}
				else msg = '$origin - $msg';
				FunkinLua.luaTrace(msg, parentLua == null, false, FlxColor.RED);
			}
		});
		#if LUA_ALLOWED
		set('parentLua', parentLua);
		#else
		set('parentLua', null);
		#end
		set('this', this);
		set('game', FlxG.state);
		set('state', FlxG.state);
		set('substate', FlxG.state.subState);
		set('controls', Controls);

		set('buildTarget', FunkinLua.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', FunkinLua.Function_Stop);
		set('Function_Continue', FunkinLua.Function_Continue);
		set('Function_StopLua', FunkinLua.Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', FunkinLua.Function_StopHScript);
		set('Function_StopAll', FunkinLua.Function_StopAll);
		
		set('add', function(obj:FlxBasic) PlayState.instance.add(obj));
		set('insert', function(pos:Int, obj:FlxBasic) PlayState.instance.insert(pos, obj));
		set('remove', function(obj:FlxBasic, ?splice:Bool = false) PlayState.instance.remove(obj, splice));
		
		set('addBehindGF', function(obj:FlxBasic) PlayState.instance.addBehindGF(obj));
		set('addBehindDad', function(obj:FlxBasic) PlayState.instance.addBehindDad(obj));
		set('addBehindBF', function(obj:FlxBasic) PlayState.instance.addBehindBF(obj));
		#end
		if(varsToBring != null) {
			for (key in Reflect.fields(varsToBring))
			{
				key = key.trim();
				var value = Reflect.field(varsToBring, key);
				//trace('Key $key: $value');
				set(key, Reflect.field(varsToBring, key));
			}
			varsToBring = null;
		}
	}

	public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):TeaCall
	{
		if (funcToRun == null) return null;
		
		if(!exists(funcToRun))
		{
			FunkinLua.luaTrace(origin + ' - No HScript function named: $funcToRun', false, false, FlxColor.RED);
			return null;
		}
		final callValue = call(funcToRun, funcArgs);
		if (!callValue.succeeded)
		{
			final e = callValue.exceptions[0];
			if (e != null) {
				var msg:String = e.toString();
				if(parentLua != null) msg = origin + ":" + parentLua.lastCalledFunction + " - " + msg;
				else msg = '$origin - $msg';
				FunkinLua.luaTrace(msg, parentLua == null, false, FlxColor.RED);
			}
			return null;
		}
		return callValue;
	}

	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>):TeaCall {
		if (funcToRun == null) return null;
		return call(funcToRun, funcArgs);
	}
	
	public static function implement(funk:FunkinLua) {
		#if LUA_ALLOWED
		var lua:State = funk.lua;
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			#if (SScript >= "3.0.0")
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			final retVal:TeaCall = funk.hscript.executeCode(funcToRun, funcArgs);
			if (retVal != null) {
				if(retVal.succeeded)
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
				final e = retVal.exceptions[0];
				final calledFunc:String = if(funk.hscript.origin == funk.lastCalledFunction) funcToRun else funk.lastCalledFunction;
				if (e != null)
					FunkinLua.luaTrace(funk.hscript.origin + ":" + calledFunc + " - " + e, false, false, FlxColor.RED);
				return null;
			}
			else if (funk.hscript.returnValue != null)
				return funk.hscript.returnValue;
			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end

			return null;
		});
		
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if (SScript >= "3.0.0")
			var callValue = funk.hscript.executeFunction(funcToRun, funcArgs);
			if (!callValue.succeeded)
			{
				var e = callValue.exceptions[0];
				if (e != null)
					FunkinLua.luaTrace('ERROR (${funk.hscript.origin}: ${callValue.calledFunction}) - ' + e.message.substr(0, e.message.indexOf('\n')), false, false, FlxColor.RED);
				return null;
			}
			else
				return callValue.returnValue;
			#else
			FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		// This function is unnecessary because import already exists in SScript as a native feature
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';
			else if(libName == null)
				libName = '';

			var c = Type.resolveClass(str + libName);
			#if (SScript >= "3.0.3")
			if (c != null)
				SScript.globalVariables[libName] = c;
			#end
			#if (SScript >= "3.0.0")
			if (funk.hscript != null)
			{
				try {
					if (c != null)
						funk.hscript.set(libName, c);
				}
				catch (e:Dynamic) {
					FunkinLua.luaTrace(funk.hscript.origin + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
			}
			#else
			FunkinLua.luaTrace("addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		#end
	}
	
	public static function implementForced(funk:FunkinLua) {
		#if LUA_ALLOWED
		var lua:State = funk.lua;
		funk.addLocalCallback("runSScriptCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			#if (SScript >= "3.0.0")
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			final retVal:TeaCall = funk.hscript.executeCode(funcToRun, funcArgs);
			if (retVal != null) {
				if(retVal.succeeded)
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
				final e = retVal.exceptions[0];
				final calledFunc:String = if(funk.hscript.origin == funk.lastCalledFunction) funcToRun else funk.lastCalledFunction;
				if (e != null)
					FunkinLua.luaTrace(funk.hscript.origin + ":" + calledFunc + " - " + e, false, false, FlxColor.RED);
				return null;
			}
			else if (funk.hscript.returnValue != null)
				return funk.hscript.returnValue;
			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end

			return null;
		});
		
		funk.addLocalCallback("runSScriptFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if (SScript >= "3.0.0")
			var callValue = funk.hscript.executeFunction(funcToRun, funcArgs);
			if (!callValue.succeeded)
			{
				var e = callValue.exceptions[0];
				if (e != null)
					FunkinLua.luaTrace('ERROR (${funk.hscript.origin}: ${callValue.calledFunction}) - ' + e.message.substr(0, e.message.indexOf('\n')), false, false, FlxColor.RED);
				return null;
			}
			else
				return callValue.returnValue;
			#else
			FunkinLua.luaTrace("runHaxeFunction: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		// This function is unnecessary because import already exists in SScript as a native feature
		funk.addLocalCallback("addSScriptLibrary", function(libName:String, ?libPackage:String = '') {
			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';
			else if(libName == null)
				libName = '';

			var c = Type.resolveClass(str + libName);
			#if (SScript >= "3.0.3")
			if (c != null)
				SScript.globalVariables[libName] = c;
			#end
			#if (SScript >= "3.0.0")
			if (funk.hscript != null)
			{
				try {
					if (c != null)
						funk.hscript.set(libName, c);
				}
				catch (e:Dynamic) {
					FunkinLua.luaTrace(funk.hscript.origin + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
			}
			#else
			FunkinLua.luaTrace("addHaxeLibrary: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
		});
		#end
	}
	
	#if (SScript >= "3.0.3" || HSCRIPT_ALLOWED)
	override public function destroy()
	{
		origin = null;
		parentLua = null;
		super.destroy();
		PlayState.publicVariables = [];
	}
	#else
	public function destroy()
	{
		active = false;
	}
	#end
}
#end

#if hscript
class HScriptOG
{
	#if hscript
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public var variables(get, never):Map<String, Dynamic>;
	public var parentLua:FunkinLua;

	public function get_variables()
	{
		return interp.variables;
	}
	
	public static function initHaxeModule(parent:FunkinLua)
	{
		#if (hscript && HSCRIPT_ALLOWED)
		if(parent.hscriptog == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscriptog = new HScriptOG(parent);
		}
		#end
	}

	public function new(parent:FunkinLua)
	{
		interp = new Interp();
		parentLua = parent;
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('ClientPrefs', ClientPrefs.data);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('CustomSubstate', CustomSubstate);
		#if (!flash && sys)
		interp.variables.set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		interp.variables.set('ShaderFilter', openfl.filters.ShaderFilter);
		interp.variables.set('CustomShader', funkin.backend.shaders.CustomShader); //CustomShader from CNE
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if(PlayState.instance.variables.exists(name)) result = PlayState.instance.variables.get(name);
			return result;
		});
		interp.variables.set('removeVar', function(name:String)
		{
			if(PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		interp.variables.set('debugPrint', function(text:String, ?color:FlxColor = null) {
			if(color == null) color = FlxColor.WHITE;
			FunkinLua.luaTrace(text, true, false, color);
		});
		// For adding your own callbacks
		
		// not very tested but should work
		interp.variables.set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			#if LUA_ALLOWED
			for (script in PlayState.instance.luaArray)
				if(script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);
			#end
			FunkinLua.customFunctions.set(name, func);
		});
		
		// tested
		interp.variables.set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			#if LUA_ALLOWED
			var lua:State = funk.lua;
			if(funk == null) funk = parentLua;
			funk.addLocalCallback(name, func);
			#end
		});
		
		interp.variables.set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';
				interp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
		});
		interp.variables.set('parentLua', parentLua);
	}

	public function execute(codeToRun:String, ?funcToRun:String = null, ?funcArgs:Array<Dynamic>):Dynamic
	{
		@:privateAccess
		#if HSCRIPT_ALLOWED
		HScriptOG.parser.line = 1;
		HScriptOG.parser.allowTypes = true;
		if (ClientPrefs.data.hscriptversion == 'HScript New')
		{
			var expr:Expr = HScriptOG.parser.parseString(codeToRun);
			try {
				var value:Dynamic = interp.execute(HScriptOG.parser.parseString(codeToRun));
				return (funcToRun != null) ? executeFunction(funcToRun, funcArgs) : value;
			}
			catch(e:Exception)
			{
				FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				return null;
			}
		}
		else if (ClientPrefs.data.hscriptversion == 'HScript Old')
			return interp.execute(HScriptOG.parser.parseString(codeToRun));
		else
			trace('HScript OG: Wrong HScript Option');
		#end
			
		return null;
	}
	
	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>)
	{
		if(funcToRun != null)
		{
			//trace('Executing $funcToRun');
			if(interp.variables.exists(funcToRun))
			{
				//trace('$funcToRun exists, executing...');
				if(funcArgs == null) funcArgs = [];
				try {
					return Reflect.callMethod(null, interp.variables.get(funcToRun), funcArgs);
				}
				catch(e) FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
		}
		return null;
	}
	
	public static function implement(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
			var retVal:Dynamic = null;
			initHaxeModule(funk);
			
			if (ClientPrefs.data.hscriptversion == 'HScript New')
			{
				#if (hscript && HSCRIPT_ALLOWED)
				try {
					if(varsToBring != null)
					{
						for (key in Reflect.fields(varsToBring))
						{
							//trace('Key $key: ' + Reflect.field(varsToBring, key));
							funk.hscriptog.interp.variables.set(key, Reflect.field(varsToBring, key));
						}
					}
					retVal = funk.hscriptog.execute(codeToRun, funcToRun, funcArgs);
				}
				catch (e:Dynamic) {
					FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
				#else
				FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
				#end
				if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
			}
			else if (ClientPrefs.data.hscriptversion == 'HScript Old')
			{
				#if (hscript && HSCRIPT_ALLOWED)
				try { retVal = funk.hscriptog.execute(codeToRun); }
				catch (e:Dynamic) { FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED); }
				#else
				FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
				#end
	
				if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
				if(retVal == null) Lua.pushnil(lua);
			}
			return retVal;
		});
		
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if HSCRIPT_ALLOWED
			try {
				return funk.hscriptog.executeFunction(funcToRun, funcArgs);
			}
			catch(e:Exception)
			{
				FunkinLua.luaTrace(Std.string(e));
				return null;
			}
			#end
		});
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			#if (hscript && HSCRIPT_ALLOWED)
			initHaxeModule(funk);
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';
				funk.hscriptog.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});
		#end
	}
	
	public function execute_forced(HScriptVersion:String, codeToRun:String, ?funcToRun:String = null, ?funcArgs:Array<Dynamic>):Dynamic
	{
		@:privateAccess
		#if HSCRIPT_ALLOWED
		HScriptOG.parser.line = 1;
		HScriptOG.parser.allowTypes = true;
		if (HScriptVersion == 'HScript New')
		{
			var expr:Expr = HScriptOG.parser.parseString(codeToRun);
			try {
				var value:Dynamic = interp.execute(HScriptOG.parser.parseString(codeToRun));
				return (funcToRun != null) ? executeFunction(funcToRun, funcArgs) : value;
			}
			catch(e:Exception)
			{
				FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				return null;
			}
		}
		else if (HScriptVersion == 'HScript Old')
			return interp.execute(HScriptOG.parser.parseString(codeToRun));
		else
			trace('HScript OG: Only HScript Old, HScript New Supported');
		#end
			
		return null;
	}
	
	public static function implementForced(funk:FunkinLua)
	{
		#if LUA_ALLOWED
		var lua:State = funk.lua;
		funk.addLocalCallback("runHScriptNewCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
			var retVal:Dynamic = null;
			initHaxeModule(funk);
			
			#if (hscript && HSCRIPT_ALLOWED)
			try {
				if(varsToBring != null)
				{
					for (key in Reflect.fields(varsToBring))
					{
						//trace('Key $key: ' + Reflect.field(varsToBring, key));
						funk.hscriptog.interp.variables.set(key, Reflect.field(varsToBring, key));
					}
				}
				retVal = funk.hscriptog.execute_forced('HScript New', codeToRun, funcToRun, funcArgs);
			}
			catch (e:Dynamic) {
				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
			if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
			return retVal;
		});
		
		funk.addLocalCallback("runHScriptOldCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null) {
			var retVal:Dynamic = null;
			initHaxeModule(funk);
			
			#if (hscript && HSCRIPT_ALLOWED)
			try { retVal = funk.hscriptog.execute_forced('HScript Old', codeToRun); }
			catch (e:Dynamic) { FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED); }
			#else
			FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
			#end
	
			if(retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array])) retVal = null;
			if(retVal == null) Lua.pushnil(lua);
			return retVal;
		});
		
		funk.addLocalCallback("runHScriptFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			#if HSCRIPT_ALLOWED
			try {
				return funk.hscriptog.executeFunction(funcToRun, funcArgs);
			}
			catch(e:Exception)
			{
				FunkinLua.luaTrace(Std.string(e));
				return null;
			}
			#end
		});
		funk.addLocalCallback("addHScriptLibrary", function(libName:String, ?libPackage:String = '') {
			#if (hscript && HSCRIPT_ALLOWED)
			initHaxeModule(funk);
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';
				funk.hscriptog.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});
		#end
	}
	#end
}
#end

class CustomFlxColor
{
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;
	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;
	
	public static function fromInt(Value:Int):Int 
	{
		return cast FlxColor.fromInt(Value);
	}
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}
	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}