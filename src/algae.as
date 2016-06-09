package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class algae extends MovieClip {
		private var master:Main;
		private var thing:crop = new crop();
		
		private var timeToReproduce:int = 1000;
		private var timeLeft:int = 10;
		
		// stats
		public var life:int = 100;
		
		private var personalSpace:int = 20;

		public function algae(m:Main):void {
			master = m;
			addChild(thing);
			
			addEventListener(Event.ENTER_FRAME, biologicalClock);
		}
		public function biologicalClock(e:Event):void {
			timeLeft--;
			
			checkReproduction();
			checkLife();
		}
		private function checkLife():void {
			if (life < 0) {
				removeEventListener(Event.ENTER_FRAME, biologicalClock);
				master.remove(this);
			}
		}
		private function checkReproduction():void {
			if (timeLeft < 0) {// reproduce
				timeLeft = timeToReproduce;
				var angle:int = 30 * Math.round(Math.random() * 12);
				var p:Point = calc.placementAngle(angle, personalSpace);
				
				master.addAlgae(x + p.x, y + p.y);
			}
		}
		
	}
	
}
