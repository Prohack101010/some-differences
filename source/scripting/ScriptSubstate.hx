package scripting;

#if SCRIPTING_ALLOWED
class ScriptSubstate extends MusicBeatSubstate
{
	public static var targetFileName:String; 

	public function new(scriptName:String) 
	{
		super();

		targetFileName = scriptName;
	}

	public static var instance:ScriptSubstate;

	override public function create()
	{
		instance = this;
		Paths.clearUnusedMemory();
		super.create();
		loadScript('custom_substates/${targetFileName}');
	}

	override public function close()
	{
		super.close();
		instance = null;
		call("close");
	}

	public function resetScriptState(?doTransition:Bool = false)
	{
		FlxTransitionableState.skipNextTransIn = !doTransition;
		FlxTransitionableState.skipNextTransOut = !doTransition;
		MusicBeatState.switchState(new ScriptState(targetFileName));
	}
}
#end