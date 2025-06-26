package mobile.options;

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
import options.BaseOptionsMenu;
import options.Option;
import openfl.Lib;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import mobile.backend.StorageUtil;


class MobileOptionsSubState extends BaseOptionsMenu
{
	#if android
	var storageTypes:Array<String> = ["EXTERNAL_DATA", "EXTERNAL", "EXTERNAL_EX", "EXTERNAL_NF", "EXTERNAL_OBB", "EXTERNAL_MEDIA", "EXTERNAL_ONLINE"];
	var externalPaths:Array<String> = StorageUtil.checkExternalPaths(true);
	final lastStorageType:String = ClientPrefs.data.storageType;
	#end

	var MPadSkinOption:Option;
	var mobilePadTextures:Array<String> = ["VirtualPad", "TouchPad"];
	var MPadSkin:Array<String>;
	var HitboxTypes:Array<String>;

	public function new()
	{
		#if android
		storageTypes = storageTypes.concat(externalPaths); //SD Card
		#end
		title = 'Mobile Options';
		rpcTitle = 'Mobile Options Menu'; //hi, you can ask what is that, i will answer it's all what you needed lol.
		#if TOUCH_CONTROLS
		HitboxTypes = Mods.mergeAllTextsNamed('mobile/Hitbox/HitboxModes/hitboxModeList.txt');
		if(ClientPrefs.data.mobilePadTexture == 'TouchPad') MPadSkin = Mods.mergeAllTextsNamed('mobile/MobileButton/TouchPad/skinList.txt');
		else MPadSkin = Mods.mergeAllTextsNamed('mobile/MobileButton/VirtualPad/skinList.txt');
		#end

	#if TOUCH_CONTROLS
	MPadSkin.insert(0, "original"); //seperate the original skin from skinList.txt
	MPadSkinOption = new Option('MobilePad Skin',
		"Choose MobilePad Skin",
		'mobilePadSkin',
		'string',
		MPadSkin);

	addOption(MPadSkinOption);
	MPadSkinOption.onChange = resetMobilePad;

	var option:Option = new Option('MobilePad Alpha:',
		'Changes MobilePad Alpha -cool feature',
		'mobilePadAlpha',
		'percent');
	option.scrollSpeed = 1.6;
	option.minValue = 0;
	option.maxValue = 1;
	option.changeValue = 0.1;
	option.decimals = 1;
	option.onChange = () ->
	{
		_virtualpad.alpha = curOption.getValue();
	};
	addOption(option);
	super();

	var option:Option = new Option('Colored MobilePad',
		'If unchecked, disables MobilePad colors\n(can be used to make custom colored MobilePad)',
		'coloredvpad',
		'bool');
	addOption(option);
	option.onChange = resetMobilePad;

	var option:Option = new Option('MobilePad Texture',
		'Which MobilePad Texture should use??',
		'mobilePadTexture',
		'string',
		mobilePadTextures);
	addOption(option);
	option.onChange = onChangeTexture; //better way

	var option:Option = new Option('Extra Controls',
		"Allow Extra Controls",
		'extraKeys',
		'float');
	option.scrollSpeed = 1.6;
	option.minValue = 0;
	option.maxValue = 4;
	option.changeValue = 1;
	option.decimals = 1;
	addOption(option);

	var option:Option = new Option('Extra Control Location:',
		"Choose Extra Control Location",
		'hitboxLocation',
		'string',
		['Bottom', 'Top', 'Middle']);
	addOption(option);

	HitboxTypes.insert(0, "New");
	HitboxTypes.insert(0, "Classic");
	var option:Option = new Option('Hitbox Mode:',
		"Choose your Hitbox Style! -mariomaster",
		'hitboxmode',
		'string',
		HitboxTypes);
	addOption(option);

	var option:Option = new Option('Hitbox Design:',
		"Choose how your hitbox should look like.",
		'hitboxtype',
		'string',
		['Gradient', 'No Gradient' , 'No Gradient (Old)']);
	addOption(option);

	var option:Option = new Option('Hitbox Hint',
		'Hitbox Hint -I hate this',
		'hitboxhint',
		'bool');
	addOption(option);

	var option:Option = new Option('Hitbox Opacity', //mariomaster was here again -I won't remove this because... Y'know This is here on almost 1 year
		'Changes hitbox opacity -omg',
		'hitboxalpha',
		'float');
	option.scrollSpeed = 1.6;
	option.minValue = 0.0;
	option.maxValue = 1;
	option.changeValue = 0.1;
	option.decimals = 1;
	addOption(option);
	#end

	#if mobile
	var option:Option = new Option('Wide Screen Mode',
		'If checked, The game will stetch to fill your whole screen. (WARNING: Can result in bad visuals & break some mods that resizes the game/cameras)',
		'wideScreen',
		'bool');
	option.onChange = () -> FlxG.scaleMode = new MobileScaleMode();
	addOption(option);
	#end

	#if android
	var option:Option = new Option('Storage Type',
		'Which folder Psych Engine should use?',
		'storageType',
		'string',
		storageTypes);
		addOption(option);
	#end

		super();
	}

	#if android
	function onStorageChange():Void
	{
		File.saveContent(lime.system.System.applicationStorageDirectory + 'storagetype.txt', ClientPrefs.data.storageType);
	}
	#end

	override public function destroy() {
		super.destroy();

		#if android
		if (ClientPrefs.data.storageType != lastStorageType) {
			onStorageChange();
			ClientPrefs.saveSettings();
			CoolUtil.showPopUp('Storage Type has been changed and you needed restart the game!!\nPress OK to close the game.', 'Notice!');
			lime.system.System.exit(0);
		}
		#end
	}

	#if TOUCH_CONTROLS
	function onChangeTexture() {
		ClientPrefs.saveSettings();
		if(ClientPrefs.data.mobilePadTexture == 'TouchPad') MPadSkin = Mods.mergeAllTextsNamed('mobile/MobileButton/TouchPad/skinList.txt');
		else MPadSkin = Mods.mergeAllTextsNamed('mobile/MobileButton/VirtualPad/skinList.txt');

		MPadSkinOption.options = MPadSkin; //Change between TouchPad's and VirtualPad's Note Skin Folders
		MPadSkin.insert(0, "original");

		//Reset to default if saved noteskin couldnt be found in between folders
		if(!MPadSkin.contains(ClientPrefs.data.mobilePadSkin))
		{
			MPadSkinOption.defaultValue = MPadSkinOption.options[0];

			//these needs to be update the text
			MPadSkinOption.setValue(MPadSkinOption.options[0]);
			updateTextFrom(MPadSkinOption);
			MPadSkinOption.change();
		}
		resetMobilePad();
	}

	function resetMobilePad()
	{
		removeVirtualPad();
		addVirtualPad("FULL", "A_B_C");
	}
	#end
}
