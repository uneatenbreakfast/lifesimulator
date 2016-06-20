package 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author ...
	 */
	public class Pathfinder 
	{
		
		public function Pathfinder() 
		{
		
		}
		
		public static function scanStep(wantTarget:Point, cre:Creature):void {
			var plants:Array = Main.GetInstance().plantArr;
			var tarB:Point = new Point();
			
			var angle:Number = Math.atan( (wantTarget.x - cre.x) / (wantTarget.y - cre.y) ); // radians
			trace(angle, wantTarget.y < cre.y);
			if (wantTarget.y < cre.y) {
				if (angle > 0) {
					tarB.x = cre.x - (Math.sin(angle) * cre.sightDis);
					tarB.y = cre.y - (Math.cos(angle) * cre.sightDis);
				}else {
					tarB.x = cre.x - (Math.sin(angle) * cre.sightDis);
					tarB.y = cre.y - (Math.cos(angle) * cre.sightDis);
				}
			}else {
				if (angle > 0) {
					tarB.x = cre.x + (Math.sin(angle) * cre.sightDis);
					tarB.y = cre.y + (Math.cos(angle) * cre.sightDis);
				}else {
					tarB.x = cre.x - Math.abs(Math.sin(angle) * cre.sightDis);
					tarB.y = cre.y + Math.abs(Math.cos(angle) * cre.sightDis);
				}
			}
			
			var someIsInTheWay:Boolean = false;
			for (var i:* in plants) {
				if ( intersect(new Point(cre.x, cre.y), tarB, plants[i].getHorPoint()[0], plants[i].getHorPoint()[1])) {
					someIsInTheWay = true;
					break;
				}
			}
			
			if (someIsInTheWay) {
				trace("Something is in the way");
			}else {
				// free to move forward
				trace("All clear");
				
				cre.setTargetCoordinates(tarB.x, tarB.y);
			}
			
		
		}
		
		public static function degFromRad( p_radInput:Number ):Number
		{
			var degOutput:Number = ( 180 / Math.PI ) * p_radInput;
			return degOutput;
		}
		 
		public static function radFromDeg( p_degInput:Number ):Number
		{
			var radOutput:Number = ( Math.PI / 180 ) * p_degInput;
			return radOutput;
		}
		
		private static function intersect(a:Point, b:Point, c:Point, d:Point):Boolean {
			// AB - is a segment
			// CD - is a segment
			return ((ccw(a, c, d) != ccw(b, c, d)) && (ccw(a, b, c) != ccw(a, b, d)));
		}
		
		private static function ccw(a:Point, b:Point, c:Point):Boolean {
			return (((c.y - a.y) * (b.x - a.x)) > ((b.y - a.y) * (c.x - a.x)));
		}
	}

}