//NOTE: Use hxCodec 3.0.0

package backend;

#if (hxCodec >= "3.0.0" && VIDEOS_ALLOWED && !ios)
import hxcodec.flixel.FlxVideo as Video;
#end
import haxe.extern.EitherType;
import flixel.util.FlxSignal;
import haxe.io.Path;

#if (hxCodec >= "3.0.0" && VIDEOS_ALLOWED && !ios)
class VideoManager extends Video {
    public var playbackRate(get, set):EitherType<Single, Float>;
    public var paused(default, set):Bool = false;
    public var onVideoEnd:FlxSignal;
    public var onVideoStart:FlxSignal;

    public function new(?autoDispose:Bool = true) {

        super();
        onVideoEnd = new FlxSignal();
        onVideoStart = new FlxSignal();    
        
        if(autoDispose)
            onEndReached.add(function(){
                dispose();
            }, true);

        onOpening.add(onVideoStart.dispatch);
        onEndReached.add(onVideoEnd.dispatch);  
    }

    public function startVideo(path:String, loop:Bool = false) {
        play(path, loop);
    }

    @:noCompletion
    private function set_paused(shouldPause:Bool){
        if(shouldPause){
            pause();
            if(FlxG.autoPause) {
                if(FlxG.signals.focusGained.has(pause))
                    FlxG.signals.focusGained.remove(pause);
    
                if(FlxG.signals.focusLost.has(resume))
                    FlxG.signals.focusLost.remove(resume);
            }
        } else {
            resume();
            if(FlxG.autoPause) {
                FlxG.signals.focusGained.add(pause);
                FlxG.signals.focusLost.add(resume);
            }
        }
        return shouldPause;
    }

    @:noCompletion
    private function set_playbackRate(multi:EitherType<Single, Float>){
        rate = multi;
        return multi;
    }

    @:noCompletion
    private function get_playbackRate():Float {
        return rate;
    }
}
#end