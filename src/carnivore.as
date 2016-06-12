package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class carnivore extends creature {
		private var thing:carni = new carni();
		
		public function carnivore():void {
			super(thing);
			foodPreference = master.animalsArr;
			//addChild(thing);
			
			thing.gotoAndStop("idle");
			//addEventListener(Event.ENTER_FRAME, biologicalClock);
		}
		

		
		override public function reproduction():void {
			if (reproductionLevel > reproductionLevelMax) {
				reproductionLevel = 0;
				master.addCarnivore(this.x + 30, this.y);
			}
		}
		
		override public function eat():void {
			var ob:int = Omni.FindFirstObject(x, y, master.animalsArr, 20, this);
			if (ob>0) {
				master.physicalObjects[ob].life--;
				life += 1;
				size += 1;
				reproductionLevel++;
				//faceTar();
			}else {
				finishedTask();
			}
		}
		
	}

}
