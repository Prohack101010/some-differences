package backend;

#if sys
import sys.FileSystem;
import sys.io.File;
#else
import lime.utils.Assets;
#end
import haxe.Json;

typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

class Mods
{
	static public var enabledMods:Array<String> = [];
	static public var currentModDirectory:String = '';
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	inline public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack != null && pack.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	inline public static function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		#if MODS_ALLOWED
		var modsFolder:String = Paths.mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder))
			{
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
					list.push(folder);
			}
		}
		#end
		return list;
	}
	
	inline public static function mergeAllTextsNamed(path:String, ?defaultDirectory:String = null, allowDuplicates:Bool = false)
	{
		if(defaultDirectory == null) defaultDirectory = Paths.getSharedPath();
		defaultDirectory = defaultDirectory.trim();
		if(!defaultDirectory.endsWith('/')) defaultDirectory += '/';
		if(!defaultDirectory.startsWith('assets/')) defaultDirectory = 'assets/$defaultDirectory';
		var mergedList:Array<String> = [];
		var paths:Array<String> = directoriesWithFile(defaultDirectory, path);
		var defaultPath:String = defaultDirectory + path;
		if(paths.contains(defaultPath))
		{
			paths.remove(defaultPath);
			paths.insert(0, defaultPath);
		}
		for (file in paths)
		{
			var list:Array<String> = CoolUtil.coolTextFile(file);
			for (value in list)
				if((allowDuplicates || !mergedList.contains(value)) && value.length > 0)
					mergedList.push(value);
		}
		return mergedList;
	}
	
	inline public static function directoriesWithFile(path:String, fileToFind:String, mods:Bool = true)
	{
		var foldersToCheck:Array<String> = [];
		if(FileSystem.exists(path + fileToFind)) foldersToCheck.push(path + fileToFind);
		#if MODS_ALLOWED
		if(mods)
		{
			// Global mods first
			for(mod in Mods.getGlobalMods())
			{
				var folder:String = Paths.mods(mod + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.push(folder);
			}
			// Then "PsychEngine/mods/" main folder
			var folder:String = Paths.mods(fileToFind);
			if(FileSystem.exists(folder)) foldersToCheck.push(Paths.mods(fileToFind));
			
			// And lastly, the loaded mod's folder
			if(Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0)
			{
				var folder:String = Paths.mods(Mods.currentModDirectory + '/' + fileToFind);
				if(FileSystem.exists(folder)) foldersToCheck.push(folder);
			}
		}
		#end
		return foldersToCheck;
	}
	
	public static function getPack(?folder:String = null):Dynamic
	{
		#if MODS_ALLOWED
		if(folder == null) folder = Mods.currentModDirectory;

		var path = Paths.mods(folder + '/pack.json');
		if(FileSystem.exists(path)) {
			try {
				var rawJson:String = File.getContent(path);
				if(rawJson != null && rawJson.length > 0) return Json.parse(rawJson);
			} catch(e:Dynamic) {
				trace(e);
			}
		}
		#end
		return null;
	}

	public static var updatedOnState:Bool = false;
	inline public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		#if MODS_ALLOWED
		try {
			if (ClientPrefs.data.Modpack)
			{
				for (mod in CoolUtil.coolTextFile('modpackList.txt'))
				{
					//trace('Mod: $mod');
					var dat = mod.split("|");
					list.all.push(dat[0]);
					if (dat[1] == "1")
						list.enabled.push(dat[0]);
					else
						list.disabled.push(dat[0]);
				}
			}
			else
			{
				for (mod in CoolUtil.coolTextFile('modsList.txt'))
				{
					//trace('Mod: $mod');
					var dat = mod.split("|");
					list.all.push(dat[0]);
					if (dat[1] == "1")
						list.enabled.push(dat[0]);
					else
						list.disabled.push(dat[0]);
				}
			}
		} catch(e) {
			trace(e);
		}
		#end
		enabledMods = list.enabled; //for CustomMenuModSwitch
		return list;
	}
	
	public static function getSelectedMenuMod():Array<String>
	{
		#if MODS_ALLOWED
		var enabledMod:Array<String> = [];
		var modsList:String = 'modsList.txt';
		if (ClientPrefs.data.Modpack) modsList = 'modpackList.txt';
		else modsList = 'modsList.txt';

		for (mod in CoolUtil.coolTextFile(modsList))
		{
			var dat:Array<String> = mod.split("|");
			if (dat[2] == "1") enabledMod = [dat[0] + "|" + dat[2]];
		}

		return enabledMod;
		#end
	}
	
	public static function selectMenuMod(modFolder:String)
	{
		#if MODS_ALLOWED
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			if (ClientPrefs.data.Modpack)
			{
				for (mod in CoolUtil.coolTextFile('modpackList.txt'))
				{
					var dat:Array<String> = mod.split("|");
					var folder:String = dat[0];
					if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
					{
						added.push(folder);
						if (folder == modFolder) dat[2] = "2";
						list.push([folder, (dat[1] == "1"), (dat[2] == "2")]);
					}
				}
			}
			else
			{
				for (mod in CoolUtil.coolTextFile('modsList.txt'))
				{
					var dat:Array<String> = mod.split("|");
					var folder:String = dat[0];
					if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
					{
						added.push(folder);
						if (folder == modFolder) dat[2] = "2";
						list.push([folder, (dat[1] == "1"), (dat[2] == "2")]);
					}
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true, false]);
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0') + '|' + (values[2] ? '1' : '0');
		}
		//trace(fileStr);

		if (ClientPrefs.data.Modpack) File.saveContent('modpackList.txt', fileStr);
		else File.saveContent('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');
		#end
	}
	
	private static function updateModList()
	{
		#if MODS_ALLOWED
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		try {
			if (ClientPrefs.data.Modpack)
			{
				for (mod in CoolUtil.coolTextFile('modpackList.txt'))
				{
					var dat:Array<String> = mod.split("|");
					var folder:String = dat[0];
					if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
					{
						added.push(folder);
						list.push([folder, (dat[1] == "1"), (dat[2] == "1")]);
					}
				}
			}
			else
			{
				for (mod in CoolUtil.coolTextFile('modsList.txt'))
				{
					var dat:Array<String> = mod.split("|");
					var folder:String = dat[0];
					if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) && !added.contains(folder))
					{
						added.push(folder);
						list.push([folder, (dat[1] == "1"), (dat[2] == "1")]);
					}
				}
			}
		} catch(e) {
			trace(e);
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(FileSystem.exists(Paths.mods(folder)) && FileSystem.isDirectory(Paths.mods(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
				//Shadow Mario (2023): What the fuck was bb thinking
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0') + '|' + (values[2] ? '1' : '0');
		}
		//trace(fileStr);

		if (ClientPrefs.data.Modpack) File.saveContent('modpackList.txt', fileStr);
		else File.saveContent('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');
		#end
	}

	public static function loadTopMod()
	{
		Mods.currentModDirectory = '';
		
		#if MODS_ALLOWED
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			Mods.currentModDirectory = list[0];
		#end
	}

	public static function getTopMod()
	{
		var modDirectory:String = '';
		
		#if MODS_ALLOWED
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			modDirectory = list[0];
		#end
		return modDirectory;
	}
}