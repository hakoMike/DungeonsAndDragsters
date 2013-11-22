package;


import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.Lib;
import openfl.Assets;
import pgr.gconsole.GameConsole;


class Main extends Sprite {
	
	private var Game:DungeonsAndDragsters; 
	inline static var UPSHIFT = 38;
	inline static var DOWNSHIFT = 40;
	inline static var CLUTCH=90;
	// left arrow=37, right=39
	inline static var ACCEL = 32;

	public function new () {
		

		super ();
		
		Game = new DungeonsAndDragsters ();
		addChild (Game);
		



		stage.addEventListener (KeyboardEvent.KEY_UP, stage_onKeyUp);
		stage.addEventListener (KeyboardEvent.KEY_DOWN, stage_onKeyDown);

		GameConsole.init();
		
	}
	private function stage_onKeyUp (event:KeyboardEvent):Void {
		if (event.keyCode == 38) {
			// up arrow
			Game.setkeystate(UPSHIFT,false);	
		}
		else if (event.keyCode == 40) {
			// down arrow
			Game.setkeystate(DOWNSHIFT,false);
		}
		else if (event.keyCode == 32) {
			// space bar
			Game.setkeystate(ACCEL,false);
		}	
		else if (event.keyCode == 90) {
			// space bar
			Game.setkeystate(CLUTCH,false);
		}			
	}
	
	private function stage_onKeyDown (event:KeyboardEvent):Void {
		if (event.keyCode == 38) {
			// up arrow
			Game.setkeystate(UPSHIFT,true);	
		}
		else if (event.keyCode == 40) {
			// down arrow
			Game.setkeystate(DOWNSHIFT,true);
		}
		else if (event.keyCode == 32) {
			// space bar
			Game.setkeystate(ACCEL,true);
		}	
		else if (event.keyCode == 90) {
			// space bar
			Game.setkeystate(CLUTCH,true);
		}		
	}
}