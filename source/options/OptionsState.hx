package options;

#if desktop
import Discord.DiscordClient;
#end
import flixel.addons.display.FlxGridOverlay;
import lime.utils.Assets;
import flixel.FlxSubState;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import options.OptionsState;
import Controls;


class OptionsState extends MusicBeatState
{
	#if TOUCH_CONTROLS
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mobile Options'];
	#else
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	#end
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var stateType:Int = 0;
	public static var onPlayState:Bool = false;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		persistentUpdate = false;
		#if TOUCH_CONTROLS if (label != "Adjust Delay and Combo") removeVirtualPad(); #end
		switch(label) {
			case 'Note Colors':
				if (ClientPrefs.data.useRGB) openSubState(new options.NotesColorSubState());
				else openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			#if TOUCH_CONTROLS 
			case 'Mobile Controls':
				openSubState(new MobileControlSelectSubState());
			#end
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			#if TOUCH_CONTROLS
			case 'Mobile Options':
				openSubState(new MobileOptionsSubState());
			#end
			case 'Adjust Delay and Combo':
				CustomSwitchState.switchMenus('NoteOffset');
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	public static var inOptionsMenu:Bool = false; //this one needs to fix notes

	override function create() {
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		inOptionsMenu = true;

		PlayState.isPixelStage = false; //Disable Pixel Stage Shit

		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		#if TOUCH_CONTROLS
		if (ClientPrefs.data.mobilePadAlpha != 0)
			options = ['Note Colors', 'Mobile Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mobile Options'];
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);
		
		var tipText:FlxText = new FlxText(10, 12, 0, 'Press E to Go In Extra Key Return Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);

		changeSelection();
		ClientPrefs.saveSettings();

		changeSelection();
		ClientPrefs.saveSettings();

		#if TOUCH_CONTROLS addVirtualPad("UP_DOWN", "A_B_E"); #end

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if TOUCH_CONTROLS
		removeVirtualPad();
		addVirtualPad("UP_DOWN", "A_B_E");
		if (ClientPrefs.data.mobilePadAlpha != 0) //pls work
			options = ['Note Colors', 'Mobile Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mobile Options'];
		else
			options = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Mobile Options'];
		#end
		persistentUpdate = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);
		
		if (controls.BACK) {
			inOptionsMenu = false;
			if (OptionsState.stateType == 2)
				MusicBeatState.switchState(new FreeplayStateNF());
			else if (OptionsState.stateType == 1)
				MusicBeatState.switchState(new FreeplayStateNOVA());
			else if (OptionsState.stateType == 3 || onPlayState) {
				StageData.loadDirectory(PlayState.SONG); //I forgot to add this -_-
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else
				CustomSwitchState.switchMenus('MainMenu');
			FlxG.sound.play(Paths.sound('cancelMenu'));
			onPlayState = false;
			stateType = 0;
		}

		#if TOUCH_CONTROLS 
		if (_virtualpad.buttonE.justPressed) {
			persistentUpdate = false;
			removeVirtualPad();
			openSubState(new MobileExtraControl());
		}
		#end

		if (controls.ACCEPT)
			openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
