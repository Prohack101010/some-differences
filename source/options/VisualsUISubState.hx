package options;

#if desktop
import Discord.DiscordClient;
#end
import openfl.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import lime.utils.Assets;
import flixel.FlxSubState;
import openfl.text.TextField;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import haxe.Json;
import haxe.format.JsonParser;


class VisualsUISubState extends BaseOptionsMenu
{
	var noteOptionID:Int = -1;
	var noteSkins:Array<String>;
	var notes:FlxTypedGroup<StrumNote>;
	var notesTween:Array<FlxTween> = [];
	var noteSkinOption:Option; //Access noteSkin Option outside of new()
	var noteY:Float = 90;
	public function new()
	{
		title = 'Visuals and UI Settings';
		rpcTitle = 'Visuals and UI Settings Menu'; //for Discord Rich Presence

		noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		notes = new FlxTypedGroup<StrumNote>();

		// for note skins
		if (ClientPrefs.data.useRGB) noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		else noteSkins = Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt');
		generateStrumline();

		// options
		if(noteSkins.length > 0)
		{
			if(!noteSkins.contains(ClientPrefs.data.noteSkin))
				ClientPrefs.data.noteSkin = ClientPrefs.defaultData.noteSkin; //Reset to default if saved noteskin couldnt be found

			noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //Default skin always comes first
			noteSkinOption = new Option('Note Skins:',
				"Select your prefered Note skin.",
				'noteSkin',
				'string',
				noteSkins);
			addOption(noteSkinOption);
			noteSkinOption.onChange = onChangeNoteSkin;
			noteOptionID = optionsArray.length - 1;
		}

		var option:Option = new Option('use RGB Shader',
			"If checked, Notes will be use RBG Shader\n(THIS OPTION DISABLES THE OLD NOTE COLOR SCREEN)",
			'useRGB',
			'bool');
		addOption(option);
		option.onChange = onChangeRGBShader;

		#if PsychExtended_ExtraFreeplayMenus
		var option:Option = new Option('Freeplay Menu Style:',
			"Choose your Freeplay Menu Style",
			'FreeplayStyle',
			'string',
			['Psych', 'NovaFlare', 'NF']);
		addOption(option);
		#end

		#if PsychExtended_ExtraMainMenus
		var option:Option = new Option('Main Menu Style:',
			"Choose your Main Menu Style",
			'MainMenuStyle',
			'string',
			['1.0', 'NovaFlare', '0.6.3', 'Extended']);
		addOption(option);
		#end

		#if PsychExtended_ExtraPauseMenus
		var option:Option = new Option('Pause Menu Style:',
			"Choose your Pause Menu Style",
			'PauseMenuStyle',
			'string',
			['Psych', 'NovaFlare']);
		addOption(option);
		#end

		#if PsychExtended_ExtraTransitions
		var option:Option = new Option('Transition Style:',
			"Choose your Transition Style",
			'TransitionStyle',
			'string',
			['Psych', 'NovaFlare', 'Extended']);
		addOption(option);
		#end

		#if PsychExtended_ExtraFPSCounters
		var option:Option = new Option('FPS Counter Style:',
			"Choose your FPS Counter Style",
			'FPSCounter',
			'string',
			['Psych', 'NovaFlare', 'NF']);
		addOption(option);
		option.onChange = onChangeFPSCounterShit;

		var option:Option = new Option('FPS Rainbow',
			"If unchecked, FPS not change color",
			'rainbowFPS',
			'bool');
		addOption(option);
		#end

		#if VIDEOS_ALLOWED
		var option:Option = new Option('Disable Intro Video',
			"If checked, disables the Intro Video",
			'DisableIntroVideo',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool');
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool');
		addOption(option);

		var option:Option = new Option('Time Bar:',
			"What should the Time Bar display?",
			'timeBarType',
			'string',
			['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool');
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'scoreZoom',
			'bool');
		addOption(option);

		var option:Option = new Option('Health Bar Transparency',
			'How much transparent should the health bar and icons be.',
			'healthBarAlpha',
			'percent');
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool');
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Main Menu Song:',
			"What song do you prefer for the Main Menu?",
			'FreakyMenu',
			'string',
			['Extended', 'Psych']);
		addOption(option);
		option.onChange = onChangeMenuMusic;

		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool');
		addOption(option);
		#end

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read",
			'comboStacking',
			'bool');
		addOption(option);

		super();
		add(notes);
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);

		if(noteOptionID < 0) return;

		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = notes.members[i];
			if(notesTween[i] != null) notesTween[i].cancel();
			if(curSelected == noteOptionID)
				notesTween[i] = FlxTween.tween(note, {y: noteY}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
			else
				notesTween[i] = FlxTween.tween(note, {y: -200}, Math.abs(note.y / (200 + noteY)) / 3, {ease: FlxEase.quadInOut});
		}
	}

	function onChangeRGBShader() {
		ClientPrefs.saveSettings();
		if (ClientPrefs.data.useRGB) noteSkins = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		else noteSkins = Mods.mergeAllTextsNamed('images/NoteSkin/DataSet/noteSkinList.txt');

		noteSkinOption.options = noteSkins; //Change between NF's and Psych's Note Skin Folders
		noteSkins.insert(0, ClientPrefs.defaultData.noteSkin); //I forgot to add this, cuz I'm a idiot

		if(!noteSkins.contains(ClientPrefs.data.noteSkin))
		{
			noteSkinOption.defaultValue = noteSkinOption.options[0]; //Reset to default if saved noteskin couldnt be found in between folders

			//this one needs to be update text
			noteSkinOption.setValue(noteSkinOption.options[0]);
			updateTextFrom(noteSkinOption);
			noteSkinOption.change();
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.data.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)));

		changedMusic = true;
	}

	function onChangeMenuMusic()
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}

	function generateStrumline() {
		for (i in 0...Note.colArray.length)
		{
			var note:StrumNote = new StrumNote(370 + (560 / Note.colArray.length) * i, -200, i, 0);
			changeNoteSkin(note);
			note.disableShadersInOptions = true; //Null Object Reference Fix
			note.centerOffsets();
			note.centerOrigin();
			note.playAnim('static');
			notes.add(note);
		}
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	function onChangeFPSCounter()
	{
		#if PsychExtended_ExtraFPSCounters
		if(Main.fpsVarNova != null && ClientPrefs.data.FPSCounter == 'NovaFlare')
			Main.fpsVarNova.visible = ClientPrefs.data.showFPS;
		else if(Main.fpsVarNF != null && ClientPrefs.data.FPSCounter == 'NF')
			Main.fpsVarNF.visible = ClientPrefs.data.showFPS;
		else if(Main.fpsVar != null && ClientPrefs.data.FPSCounter == 'Psych')
		#end
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}

	#if PsychExtended_ExtraFPSCounters
	function onChangeFPSCounterShit()
	{
		Main.fpsVar.visible = false;
		Main.fpsVarNF.visible = false;
		Main.fpsVarNova.visible = false;

		if (ClientPrefs.data.FPSCounter == 'NovaFlare')
			Main.fpsVarNova.visible = ClientPrefs.data.showFPS;
		else if (ClientPrefs.data.FPSCounter == 'NF')
			Main.fpsVarNF.visible = ClientPrefs.data.showFPS;
		else if (ClientPrefs.data.FPSCounter == 'Psych')
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
	}
	#end

	function onChangeNoteSkin()
	{
		notes.forEachAlive(function(note:StrumNote) {
			changeNoteSkin(note);
			note.centerOffsets();
			note.centerOrigin();
		});
	}

	function changeNoteSkin(note:StrumNote)
	{
		var skin:String = 'noteSkins/NOTE_assets';
		if (ClientPrefs.data.noteSkin == 'Default' && !ClientPrefs.data.useRGB) skin = 'NOTE_assets';
		else if (ClientPrefs.data.noteSkin != 'Default' && !ClientPrefs.data.useRGB) skin = 'NoteSkin/';
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) {
			Note.defaultNoteSkin = customSkin;
			skin = customSkin;
		}
		else skin = 'NOTE_assets';

		note.texture = skin; //Load texture and anims
		note.playAnim('static');
	}
}
