package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class herbivore extends creature {
		private var thing:blob = new blob();
		
		public function herbivore():void {
			super(thing);
			//addChild(thing);
			
			thing.gotoAndStop("idle");
			//addEventListener(Event.ENTER_FRAME, biologicalClock);
		}
		
	}

}
