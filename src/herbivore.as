package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Herbivore extends Creature {
		private var thing:blob = new blob();
		
		public function Herbivore():void {
			super(thing);
			foodPreference = master.plantArr;
			
			//addChild(thing);
			
			thing.gotoAndStop("idle");
			//addEventListener(Event.ENTER_FRAME, biologicalClock);
		}
		
	}

}
