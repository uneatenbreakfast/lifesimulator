package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class carnivore extends creature {
		private var thing:carni = new carni();
		
		public function carnivore():void {
			super(thing);
			
			//addChild(thing);
			
			thing.gotoAndStop("idle");
			//addEventListener(Event.ENTER_FRAME, biologicalClock);
		}
		
		override public function lookForFood(dis:int):Boolean {
			var foundFood:Boolean = false;
			var ob:int = calc.ObstructedAddHere(x, y, this.master.animalsArr, dis, this);
			if (ob>0) {
				tx = this.master.animalsArr[ob].x;
				ty = this.master.animalsArr[ob].y;
			
				//rotation = angle;
				// face food
				faceTar();
				//
			
				isBusy = true;
				physicalState = "moving";
				foundFood = true;				
			}
			return foundFood;
		}
		
	}

}
