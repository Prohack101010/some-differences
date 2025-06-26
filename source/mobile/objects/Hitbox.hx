package mobile.objects;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.geom.Matrix;

/**
 * A zone with 34 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 * @modifier KralOyuncu 2010x (ArkoseLabs)
 */
@:build(mobile.macros.ButtonMacro.createExtraHitboxButtons(30))
class Hitbox extends FlxSpriteGroup
{
	public var buttonLeft:MobileButton = new MobileButton(0, 0);
	public var buttonDown:MobileButton = new MobileButton(0, 0);
	public var buttonUp:MobileButton = new MobileButton(0, 0);
	public var buttonRight:MobileButton = new MobileButton(0, 0);

	public static var hitbox_hint:FlxSprite;

	/**
	 * Create the zone.
	 */
	public function new(?MobileCType:String):Void
	{
		super();
		if (ClientPrefs.data.hitboxhint){
			hitbox_hint = new FlxSprite(0, ClientPrefs.data.hitboxLocation == 'Bottom' ? -150 : 0).loadGraphic(Paths.image('mobile/Hitbox/hitbox_hint'));
			add(hitbox_hint);
		}
		if ((ClientPrefs.data.hitboxmode != 'New' && ClientPrefs.data.hitboxmode != 'Classic' && MobileCType == null) || MobileCType != null){
			var Custom:String = MobileCType != null ? MobileCType : ClientPrefs.data.hitboxmode;
			if (!MobileData.hitboxModes.exists(Custom))
				throw 'The Custom Hitbox File doesn\'t exists.';

			for (buttonData in MobileData.hitboxModes.get(Custom).buttons)
			{
				var location = ClientPrefs.data.hitboxLocation;
				var buttonX = buttonData.x;
				var buttonY = buttonData.y;
				var buttonWidth = buttonData.width;
				var buttonHeight = buttonData.height;
				switch (location) {
					case 'Top':
						if (buttonData.topX != null) buttonX = buttonData.topX;
						if (buttonData.topY != null) buttonY = buttonData.topY;
						if (buttonData.topWidth != null) buttonWidth = buttonData.topWidth;
						if (buttonData.topHeight != null) buttonHeight = buttonData.topHeight;
					case 'Middle':
						if (buttonData.middleX != null) buttonX = buttonData.middleX;
						if (buttonData.middleY != null) buttonY = buttonData.middleY;
						if (buttonData.middleWidth != null) buttonWidth = buttonData.middleWidth;
						if (buttonData.middleHeight != null) buttonHeight = buttonData.middleHeight;
					case 'Bottom':
						if (buttonData.bottomX != null) buttonX = buttonData.bottomX;
						if (buttonData.bottomY != null) buttonY = buttonData.bottomY;
						if (buttonData.bottomWidth != null) buttonWidth = buttonData.bottomWidth;
						if (buttonData.bottomHeight != null) buttonHeight = buttonData.bottomHeight;
				}

				Reflect.setField(this, buttonData.button,
					createHint(buttonX, buttonY, buttonWidth, buttonHeight, CoolUtil.colorFromString(buttonData.color)));
				add(Reflect.field(this, buttonData.button));
			}
		}
		else if (ClientPrefs.data.extraKeys == 0){
			add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), 0xFFC24B99));
			add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), 0xFF00FFFF));
			add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), 0xFF12FA05));
			add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 1), 0xFFF9393F));
		}else{
			if (ClientPrefs.data.hitboxLocation == 'Bottom') {
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFFC24B99));
				add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFF00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFFF9393F));

				switch (ClientPrefs.data.extraKeys) {
					case 1:
						add(buttonExtra1 = createHint(0, (FlxG.height / 5) * 4, FlxG.width, Std.int(FlxG.height / 5), 0xFFFF00));
					case 2:
						add(buttonExtra1 = createHint(0, (FlxG.height / 5) * 4, Std.int(FlxG.width / 2), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 2, (FlxG.height / 5) * 4, Std.int(FlxG.width / 2), Std.int(FlxG.height / 5), 0xFFFF00));
					case 3:
						add(buttonExtra1 = createHint(0, (FlxG.height / 5) * 4, Std.int(FlxG.width / 3), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 3 - 1, (FlxG.height / 5) * 4, Std.int(FlxG.width / 3 + 2), Std.int(FlxG.height / 5), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 3 * 2, (FlxG.height / 5) * 4, Std.int(FlxG.width / 3), Std.int(FlxG.height / 5), 0x0000FF));
					case 4:
						add(buttonExtra1 = createHint(0, (FlxG.height / 5) * 4, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 4, (FlxG.height / 5) * 4, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 4 * 2, (FlxG.height / 5) * 4, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0x0000FF));
						add(buttonExtra4 = createHint(FlxG.width / 4 * 3, (FlxG.height / 5) * 4, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0x00FF00));
				}
			}else if (ClientPrefs.data.hitboxLocation == 'Top'){// Top
				add(buttonLeft = createHint(0, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFFC24B99));
				add(buttonDown = createHint(FlxG.width / 4, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFF00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFF12FA05));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), (FlxG.height / 5) * 1, Std.int(FlxG.width / 4), Std.int(FlxG.height * 0.8), 0xFFF9393F));

				switch (ClientPrefs.data.extraKeys) {
					case 1:
						add(buttonExtra1 = createHint(0, 0, FlxG.width, Std.int(FlxG.height / 5), 0xFFFF00));
					case 2:
						add(buttonExtra1 = createHint(0, 0, Std.int(FlxG.width / 2), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 2), Std.int(FlxG.height / 5), 0xFFFF00));
					case 3:
						add(buttonExtra1 = createHint(0, 0, Std.int(FlxG.width / 3), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 3, 0, Std.int(FlxG.width / 3), Std.int(FlxG.height / 5), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 3 * 2, 0, Std.int(FlxG.width / 3), Std.int(FlxG.height / 5), 0x0000FF));
					case 4:
						add(buttonExtra1 = createHint(0, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 4 * 2, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0x0000FF));
						add(buttonExtra4 = createHint(FlxG.width / 4 * 3, 0, Std.int(FlxG.width / 4), Std.int(FlxG.height / 5), 0x00FF00));
				}
			}else{ //middle
				add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0xFF00FF));
				add(buttonDown = createHint(FlxG.width / 5 * 1, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0x00FFFF));
				add(buttonUp = createHint(FlxG.width / 5 * 3, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0x00FF00));
				add(buttonRight = createHint(FlxG.width / 5 * 4 , 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0xFF0000));

				switch (ClientPrefs.data.extraKeys) {
					case 1:
						add(buttonExtra1 = createHint(FlxG.width / 5 * 2, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 1), 0xFFFF00));
					case 2:
						add(buttonExtra1 = createHint(FlxG.width / 5 * 2, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.5), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 5 * 2, FlxG.height / 2, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.5), 0xFFFF00));
					case 3:
						add(buttonExtra1 = createHint(FlxG.width / 5 * 2, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height / 3), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 5 * 2, FlxG.height / 3, Std.int(FlxG.width / 5), Std.int(FlxG.height / 3), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 5 * 2, FlxG.height / 3 * 2, Std.int(FlxG.width / 5), Std.int(FlxG.height / 3), 0x0000FF));
					case 4:
						add(buttonExtra1 = createHint(FlxG.width / 5 * 2, 0, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.25), 0xFF0000));
						add(buttonExtra2 = createHint(FlxG.width / 5 * 2, FlxG.height / 4, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.25), 0xFFFF00));
						add(buttonExtra3 = createHint(FlxG.width / 5 * 2, FlxG.height / 4 * 2, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.25), 0x0000FF));
						add(buttonExtra4 = createHint(FlxG.width / 5 * 2, FlxG.height / 4 * 3, Std.int(FlxG.width / 5), Std.int(FlxG.height * 0.25), 0x00FF00));
				}
			}
		}
		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override function destroy():Void
	{
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
		
		buttonExtra1 = null;
		buttonExtra2 = null;
		buttonExtra3 = null;
		buttonExtra4 = null;
		
		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), MobileButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var guh:Float = ClientPrefs.data.hitboxalpha;
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		if (ClientPrefs.data.hitboxtype == "No Gradient")
		{
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(Width, Height, 0, 0, 0);

			shape.graphics.beginGradientFill(RADIAL, [Color, Color], [0, guh], [60, 255], matrix, PAD, RGB, 0);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else if (ClientPrefs.data.hitboxtype == "No Gradient (Old)")
		{
			shape.graphics.lineStyle(10, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.endFill();
		}
		else if (ClientPrefs.data.hitboxtype == "Gradient")
		{
			shape.graphics.lineStyle(3, Color, 1);
			shape.graphics.drawRect(0, 0, Width, Height);
			shape.graphics.lineStyle(0, 0, 0);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
			shape.graphics.beginGradientFill(RADIAL, [Color, FlxColor.TRANSPARENT], [guh, 0], [0, 255], null, null, null, 0.5);
			shape.graphics.drawRect(3, 3, Width - 6, Height - 6);
			shape.graphics.endFill();
		}

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):MobileButton
	{
		var hint:MobileButton = new MobileButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = hint.onOver.callback = function()
		{
			if (hint.alpha != ClientPrefs.data.hitboxalpha)
				hint.alpha = ClientPrefs.data.hitboxalpha;
		}
		hint.onUp.callback = hint.onOut.callback = function()
		{
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}

class HitboxOld extends FlxSpriteGroup {
	public var hitbox:FlxSpriteGroup;

	public var buttonLeft:MobileButton;
	public var buttonDown:MobileButton;
	public var buttonUp:MobileButton;
	public var buttonRight:MobileButton;

	public var orgAlpha:Float = 0.75;
	public var orgAntialiasing:Bool = true;
	
	public function new(?alphaAlt:Float = 0.75, ?antialiasingAlt:Bool = true) {
		super();

		orgAlpha = alphaAlt;
		orgAntialiasing = antialiasingAlt;

		buttonLeft = new MobileButton(0, 0);
		buttonDown = new MobileButton(0, 0);
		buttonUp = new MobileButton(0, 0);
		buttonRight = new MobileButton(0, 0);

		hitbox = new FlxSpriteGroup();
		hitbox.add(add(buttonLeft = createhitbox(0, 0, "left")));
		hitbox.add(add(buttonDown = createhitbox(320, 0, "down")));
		hitbox.add(add(buttonUp = createhitbox(640, 0, "up")));
		hitbox.add(add(buttonRight = createhitbox(960, 0, "right")));

		var hitbox_hint:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('mobile/Hitbox/hitbox_hint'));
		hitbox_hint.antialiasing = orgAntialiasing;
		hitbox_hint.alpha = orgAlpha;
		add(hitbox_hint);
	}

	public function createhitbox(x:Float = 0, y:Float = 0, frames:String) {
		var button = new MobileButton(x, y);
		button.loadGraphic(FlxGraphic.fromFrame(getFrames().getByName(frames)));
		button.antialiasing = orgAntialiasing;
		button.alpha = 0;// sorry but I can't hard lock the hitbox alpha
		button.onDown.callback = function (){ FlxTween.num(0, 0.75, 0.075, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;}); };
		button.onUp.callback = function (){ FlxTween.num(0.75, 0, 0.1, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;}); }
		button.onOut.callback = function (){ FlxTween.num(button.alpha, 0, 0.2, {ease:FlxEase.circInOut}, function(alpha:Float){ button.alpha = alpha;}); }
		return button;
	}

	public function getFrames():FlxAtlasFrames {
		return Paths.getSparrowAtlas('mobile/Hitbox/hitbox');
	}

	override public function destroy():Void {
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}
}
