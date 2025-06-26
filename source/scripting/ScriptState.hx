package scripting;

#if SCRIPTING_ALLOWED
class ScriptState extends MusicBeatState
{
	public static var targetFileName:String;

	public function new(scriptName:String)
	{
		super();

		targetFileName = scriptName;
	}

	public static var instance:ScriptState;

	public var camGame:FlxCamera;

	override public function create()
	{
		Paths.clearUnusedMemory();

		//this one needs to fix menu issue
		Mods.loadTopMod();

		camGame = initPsychCamera();

		instance = this;

		loadScript('custom_states/${targetFileName}');
		call("createPost");

		super.create();
	}

	var lastStepHit:Int = -1;

	override function destroy() {
		instance = null;
		super.destroy();
	}

	override function closeSubState() {
		super.closeSubState();
		persistentUpdate = true;
		closeSubStatePost();
	}
}
#end