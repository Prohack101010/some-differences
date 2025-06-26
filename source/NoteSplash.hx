package;

import shaders.RGBPalette;

class NoteSplash extends FlxSprite
{
	public var rgbShader:RGBPalette = null;
	public var colorSwap:ColorSwap = null;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		animation = new PsychAnimationController(this);

		var skin:String = 'noteSplashes';
		if (PlayState.isPixelStage) skin = 'pixelUI/noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		if (!ClientPrefs.data.useRGB) {
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;
		}

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, ?texture:String, ?hueColor:Float = 0, ?satColor:Float = 0, ?brtColor:Float = 0, ?rgbNote:Note = null) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if(texture == null) {
			texture = 'noteSplashes';
			if (PlayState.isPixelStage) texture = 'pixelUI/noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		if (ClientPrefs.data.useRGB) {
			shader = null;
			if(rgbNote != null && !rgbNote.noteSplashGlobalShader)
				rgbShader = rgbNote.rgbShader.parent;
			else
				rgbShader = Note.globalRgbShaders[note];
			
			if(rgbShader != null) shader = rgbShader.shader;
		} else {
			colorSwap.hue = hueColor;
			colorSwap.saturation = satColor;
			colorSwap.brightness = brtColor;
		}
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
		textureLoaded = skin;
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null && animation.curAnim.finished) kill();
		super.update(elapsed);
	}
}