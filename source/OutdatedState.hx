package;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		
		var buttonENTER:String = #if mobile "A" #else "ENTER" #end;
		var buttonESCAPE:String = #if mobile "B" #else "ESCAPE" #end;

		warnText = new FlxText(0, 0, FlxG.width,
			"Yo kid, looks like you're running an   \n
			outdated version of Psych Extended (" + MainMenuState.psychExtendedVersion + "),\n
			update it to " + TitleState.updateVersion + " because it's past your bedtime!\n
			Press " + buttonESCAPE + " to proceed anyway.\n
			\n
			Press " + buttonENTER + " to update the port.",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);

		#if TOUCH_CONTROLS addVirtualPad("NONE", "A_B"); #end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/28AloneDark53/Psych-Extended/releases");
			}
			else if(controls.BACK) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						CustomSwitchState.switchMenus('MainMenu');
					}
				});
			}
		}
		super.update(elapsed);
	}
}
