package  
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class PrimordialOrganism extends MovieClip
	{
		public var life:Number = 100; // life < hungerLimit is hungry
		public var touchRadius:int = 10; // Radius of hitArea


		public function PrimordialOrganism() 
		{
			
		}
		
		public function getHorPoint():Array {
			var L:Point = new Point(x - touchRadius, y);
			var R:Point = new Point(x + touchRadius, y);
			return [L, R];
		}
		
	}

}