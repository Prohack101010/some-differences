package;

import flixel.util.FlxGradient;
import flixel.FlxSubState;
import openfl.utils.Assets;
import flixel.FlxObject;

class CustomFadeTransitionNOVA extends FlxSubState {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var duration:Float;

	var loadLeft:FlxSprite;
	var loadRight:FlxSprite;
	var loadAlpha:FlxSprite;
	var WaterMark:FlxText;
	var EventText:FlxText;

	var loadLeftTween:FlxTween;
	var loadRightTween:FlxTween;
	var loadAlphaTween:FlxTween;
	var EventTextTween:FlxTween;
	var loadTextTween:FlxTween;


	public function new(duration:Float, isTransIn:Bool) {
		this.isTransIn = isTransIn;
		this.duration = duration;

		super();
	}

	override function create()
	{
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor = 0x00;
		FlxG.cameras.add(cam, false);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		loadRight = new FlxSprite(isTransIn ? 0 : 1280, 0).loadGraphic(Paths.image('menuExtend/CustomFadeTransition/loadingR'));
		loadRight.scrollFactor.set();
		loadRight.antialiasing = ClientPrefs.data.antialiasing;
		add(loadRight);
		loadRight.setGraphicSize(FlxG.width, FlxG.height);
		loadRight.updateHitbox();

		loadLeft = new FlxSprite(isTransIn ? 0 : -1280, 0).loadGraphic(Paths.image('menuExtend/CustomFadeTransition/loadingL'));
		loadLeft.scrollFactor.set();
		loadLeft.antialiasing = ClientPrefs.data.antialiasing;
		add(loadLeft);
		loadLeft.setGraphicSize(FlxG.width, FlxG.height);
		loadLeft.updateHitbox();

		WaterMark = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50 * 2, 0, 'PSYCH EXTENDED V1.0.2', 50);
		WaterMark.scrollFactor.set();
		WaterMark.setFormat(Assets.getFont("assets/fonts/loadText.ttf").fontName, 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		WaterMark.antialiasing = ClientPrefs.data.antialiasing;
		add(WaterMark);

		EventText= new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50, 0, 'LOADING . . . . . . ', 50);
		EventText.scrollFactor.set();
		EventText.setFormat(Assets.getFont("assets/fonts/loadText.ttf").fontName, 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		EventText.antialiasing = ClientPrefs.data.antialiasing;
		add(EventText);

		if(!isTransIn) {
			try{
			FlxG.sound.play(Paths.sound('loading_close_move'));
			}
			loadLeftTween = FlxTween.tween(loadLeft, {x: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoInOut});

			loadRightTween = FlxTween.tween(loadRight, {x: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoInOut});

			loadTextTween = FlxTween.tween(WaterMark, {x: 50}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoInOut});

			EventTextTween = FlxTween.tween(EventText, {x: 50}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.expoInOut});

		} else {
			try{
				FlxG.sound.play(Paths.sound('loading_open_move'));
			}
			EventText.text = 'COMPLETED !';
			loadLeftTween = FlxTween.tween(loadLeft, {x: -1280}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoInOut});

			loadRightTween = FlxTween.tween(loadRight, {x: 1280}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoInOut});

			loadTextTween = FlxTween.tween(WaterMark, {x: -1230}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoInOut});

			EventTextTween = FlxTween.tween(EventText, {x: -1230}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.expoInOut});


		}

		super.create();
	}
}