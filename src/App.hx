
import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.DivElement;
import js.html.audio.AudioContext;
import om.audio.Metronome;

class App {

    static inline var COLOR_BG = "#000";
    static inline var COLOR_FG = "#fff";
    static inline var COLOR_ACC = "#ff0000";

    static var canvas : CanvasElement;
    static var audio : AudioContext;
    static var metronome : Metronome;
    static var last16thNoteDrawn = -1.0;

    static var elementBPM : DivElement;
    static var elementTime : DivElement;
    static var elementStep : DivElement;

    static function update( time : Float ) {

        window.requestAnimationFrame( update );

		elementTime.textContent = 'TIME '+(time/1000);

        var currentNote = last16thNoteDrawn;
        var currentTime = audio.currentTime;

        while( metronome.notesInQueue.length > 0 &&  metronome.notesInQueue[0].time < currentTime ) {
            currentNote =  metronome.notesInQueue[0].note;
            metronome.notesInQueue.splice( 0, 1 );
        }

        var ctx = canvas.getContext2d();
        if( last16thNoteDrawn != currentNote ) {
            var x = Math.floor( canvas.width / 18 );
            ctx.clearRect( 0, 0, canvas.width, canvas.height );
            for( i in 0...16 ) {
                ctx.fillStyle = (currentNote == i) ? ((currentNote%4 == 0)?COLOR_FG:COLOR_ACC) : COLOR_BG;
                ctx.fillRect( x * (i+1), x, x/2, x/2 );
            }
            last16thNoteDrawn = currentNote;
        }
    }

	static function setBPM( bpm : Float ) {
		elementBPM.textContent = 'BPM '+bpm;
		metronome.stop();
		metronome.tempo = bpm;
		metronome.start();
	}

    static function main() {

		elementBPM = cast document.getElementById( 'bpm' );
		elementTime = cast document.getElementById( 'time' );
		elementStep = cast document.getElementById( 'step' );

        canvas = cast document.getElementById( 'canvas' );
        canvas.width = 400;
        canvas.height = 50;

		var bpm = 120;

		elementBPM.textContent = 'BPM '+bpm;

        audio = new AudioContext();

        metronome = new Metronome( audio, bpm );
		metronome.onTick = function(beatNumber,time) {

			elementStep.textContent = 'STEP '+time;

			var osc = audio.createOscillator();
			osc.connect( audio.destination );
			osc.frequency.value = 0;
			osc.frequency.value = if( beatNumber % 16 == 0 ) 1760.0; // beat 0
			else if( beatNumber % 4 == 0 ) 880.0; // quarter notes
			else 440.0; // other 16th notes = high pitch

			osc.start( time );
			osc.stop( time + metronome.noteLength );
		}
        metronome.start();

        window.requestAnimationFrame( update );

        window.addEventListener( 'mousedown', function(e){
            //metronome.tempo = Std.int( e.clientX);
            //metronome.stop();
			setBPM( e.clientX );
        }, false );

    }
}
