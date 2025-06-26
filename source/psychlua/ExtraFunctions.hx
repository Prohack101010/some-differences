package psychlua;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import flixel.util.FlxSave;
import openfl.utils.Assets;


//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//

class ExtraFunctions
{
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;

		// Keyboard & Gamepads
		Lua_helper.add_callback(lua, "keyboardJustPressed", function(name:String)
		{
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justPressed) return true;
			}
			#end
			return Reflect.getProperty(FlxG.keys.justPressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardPressed", function(name:String)
		{
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.pressed) return true;
			}
			#end
			return Reflect.getProperty(FlxG.keys.pressed, name);
		});
		Lua_helper.add_callback(lua, "keyboardReleased", function(name:String)
		{
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justReleased) return true;
			}
			#end
			return Reflect.getProperty(FlxG.keys.justReleased, name);
		});

		Lua_helper.add_callback(lua, "anyGamepadJustPressed", function(name:String)
		{
			return FlxG.gamepads.anyJustPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadPressed", function(name:String)
		{
			return FlxG.gamepads.anyPressed(name);
		});
		Lua_helper.add_callback(lua, "anyGamepadReleased", function(name:String)
		{
			return FlxG.gamepads.anyJustReleased(name);
		});

		Lua_helper.add_callback(lua, "gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return 0.0;
			}
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		Lua_helper.add_callback(lua, "gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.pressed, name) == true;
		});
		Lua_helper.add_callback(lua, "gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null)
			{
				return false;
			}
			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_P');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_P');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_P');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_P');
				case 'accept': key = PlayState.instance.getControl('ACCEPT');
				case 'back': key = PlayState.instance.getControl('BACK');
				case 'pause': key = PlayState.instance.getControl('PAUSE');
				case 'reset': key = PlayState.instance.getControl('RESET');
				case 'space': key = FlxG.keys.justPressed.SPACE;
				case 'ui_left': key = PlayState.instance.getControl('UI_LEFT_P');
				case 'ui_down': key = PlayState.instance.getControl('UI_DOWN_P');
				case 'ui_up': key = PlayState.instance.getControl('UI_UP_P');
				case 'ui_right': key = PlayState.instance.getControl('UI_RIGHT_P');
			}
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justPressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justPressed) return true;
			}
			#end
			return key;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN');
				case 'up': key = PlayState.instance.getControl('NOTE_UP');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT');
				case 'space': key = FlxG.keys.pressed.SPACE;
				case 'ui_left': key = PlayState.instance.getControl('UI_LEFT');
				case 'ui_down': key = PlayState.instance.getControl('UI_DOWN');
				case 'ui_up': key = PlayState.instance.getControl('UI_UP');
				case 'ui_right': key = PlayState.instance.getControl('UI_RIGHT');
			}
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.pressed) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.pressed) return true;
			}
			#end
			return key;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = PlayState.instance.getControl('NOTE_LEFT_R');
				case 'down': key = PlayState.instance.getControl('NOTE_DOWN_R');
				case 'up': key = PlayState.instance.getControl('NOTE_UP_R');
				case 'right': key = PlayState.instance.getControl('NOTE_RIGHT_R');
				case 'space': key = FlxG.keys.justReleased.SPACE;
				case 'ui_left': key = PlayState.instance.getControl('UI_LEFT_R');
				case 'ui_down': key = PlayState.instance.getControl('UI_DOWN_R');
				case 'ui_up': key = PlayState.instance.getControl('UI_UP_R');
				case 'ui_right': key = PlayState.instance.getControl('UI_RIGHT_R');
			}
			#if TOUCH_CONTROLS
			if (MusicBeatState.mobilec != null){
				var extraControl = MusicBeatState.mobilec.current;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn1.toUpperCase() && extraControl.buttonExtra1 != null && extraControl.buttonExtra1.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn2.toUpperCase() && extraControl.buttonExtra2 != null && extraControl.buttonExtra2.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn3.toUpperCase() && extraControl.buttonExtra3 != null && extraControl.buttonExtra3.justReleased) return true;
				if (name.toUpperCase() == ClientPrefs.data.extraKeyReturn4.toUpperCase() && extraControl.buttonExtra4 != null && extraControl.buttonExtra4.justReleased) return true;
			}
			#end
			return key;
		});

		// Save data management
		Lua_helper.add_callback(lua, "initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!PlayState.instance.modchartSaves.exists(name))
			{
				var save:FlxSave = new FlxSave();
				// folder goes unused for flixel 5 users. @BeastlyGhost
				save.bind(name, CoolUtil.getSavePath() + '/' + folder);
				PlayState.instance.modchartSaves.set(name, save);
				return;
			}
			FunkinLua.luaTrace('initSaveData: Save file already initialized: ' + name);
		});
		Lua_helper.add_callback(lua, "flushSaveData", function(name:String) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				PlayState.instance.modchartSaves.get(name).flush();
				return;
			}
			FunkinLua.luaTrace('flushSaveData: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});
		Lua_helper.add_callback(lua, "getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				var saveData = PlayState.instance.modchartSaves.get(name).data;
				if(Reflect.hasField(saveData, field))
					return Reflect.field(saveData, field);
				else
					return defaultValue;
			}
			FunkinLua.luaTrace('getDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
			return defaultValue;
		});
		Lua_helper.add_callback(lua, "setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(PlayState.instance.modchartSaves.exists(name))
			{
				Reflect.setField(PlayState.instance.modchartSaves.get(name).data, field, value);
				return;
			}
			FunkinLua.luaTrace('setDataFromSave: Save file not initialized: ' + name, false, false, FlxColor.RED);
		});

		// File management
		Lua_helper.add_callback(lua, "checkFileExists", function(filename:String, ?absolute:Bool = false) {
			#if MODS_ALLOWED
			if(absolute)
			{
				return FileSystem.exists(filename);
			}

			var path:String = Paths.modFolders(filename);
			if(FileSystem.exists(path))
			{
				return true;
			}
			return FileSystem.exists(Paths.getPath('assets/$filename', TEXT));
			#else
			if(absolute)
			{
				return Assets.exists(filename);
			}
			return Assets.exists(Paths.getPath('assets/$filename', TEXT));
			#end
		});
		Lua_helper.add_callback(lua, "saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				if(!absolute)
					File.saveContent(Paths.mods(path), content);
				else
					File.saveContent(path, content);

				return true;
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("saveFile: Error trying to save " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "deleteFile", function(path:String, ?ignoreModFolders:Bool = false)
		{
			try {
				#if MODS_ALLOWED
				if(!ignoreModFolders)
				{
					var lePath:String = Paths.modFolders(path);
					if(FileSystem.exists(lePath))
					{
						FileSystem.deleteFile(lePath);
						return true;
					}
				}
				#end

				var lePath:String = Paths.getPath(path, TEXT);
				if(Assets.exists(lePath))
				{
					FileSystem.deleteFile(lePath);
					return true;
				}
			} catch (e:Dynamic) {
				FunkinLua.luaTrace("deleteFile: Error trying to delete " + path + ": " + e, false, false, FlxColor.RED);
			}
			return false;
		});
		Lua_helper.add_callback(lua, "getTextFromFile", function(path:String, ?ignoreModFolders:Bool = false) {
			return Paths.getTextFromFile(path, ignoreModFolders);
		});
		Lua_helper.add_callback(lua, "directoryFileList", function(folder:String) {
			var list:Array<String> = [];
			#if sys
			if(FileSystem.exists(folder)) {
				for (folder in FileSystem.readDirectory(folder)) {
					if (!list.contains(folder)) {
						list.push(folder);
					}
				}
			}
			#end
			return list;
		});

		// String tools
		Lua_helper.add_callback(lua, "stringStartsWith", function(str:String, start:String) {
			return str.startsWith(start);
		});
		Lua_helper.add_callback(lua, "stringEndsWith", function(str:String, end:String) {
			return str.endsWith(end);
		});
		Lua_helper.add_callback(lua, "stringSplit", function(str:String, split:String) {
			return str.split(split);
		});
		Lua_helper.add_callback(lua, "stringTrim", function(str:String) {
			return str.trim();
		});

		// Randomization
		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});
	}

	#if mobile
	public static function varCheck(className:Dynamic, variable:String):String{
		return variable;
	}

	public static function classCheck(className:String):Dynamic
	{
		return Type.resolveClass(className);
	}
	#end
}