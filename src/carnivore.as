package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Carnivore extends Creature {
		private var thing:carni = new carni();
		
		public function Carnivore():void {
			super(thing);
			foodPreference = master.animalsArr;
			
			thing.gotoAndStop("idle");
		}
		

		
		override public function reproduction():void {
			if (reproductionLevel > reproductionLevelMax) {
				reproductionLevel = 0;
				master.addCarnivore(this.x + 30, this.y);
			}
		}
		
		
		
	}

}
