package {	
	import flash.geom.Point;
	public class calc {
		
		public static function removeItem(Arrayx:Array, item:*):void {
			for (var z:int = 0; z<Arrayx.length; z++) {
				if (Arrayx[z] == item) {
					Arrayx.splice(z, 1);
					z--;
					break;
				}
			}
		}
		
		public static function ObstructedAddHere(xx:int, yy:int, objs:Array, dis:int, exclude:*=null):int {		
			dis = (dis * dis);
			var k:int;
			var a:int;
			var b:int;
			
			if (xx <= 0) {
				return 0;
			}else if (xx >= 800) {
				return 0;
			}else if (yy <= 0) {
				return 0;
			}else if(yy >= 600){
				return 0;
			}
			
			
			for (var i:int; i < objs.length;i++ ) {
				if (exclude) {
					if (objs[i] == exclude) {
						continue;
					}
				}
				
				a = (xx - objs[i].x) * (xx - objs[i].x);
				b = (yy - objs[i].y) * (yy - objs[i].y);
				
				if (a + b < dis) {
					k = i;
					break;
				}
			}
			return k;
		}
		public static function canAddHere(xx:int, yy:int, objs:Array, dis:int, exclude:*=null):Boolean{		
			dis = (dis * dis);
			var k:Boolean = true;// object that is returned
			var a:int;
			var b:int;
			
			if (xx <= 0) {
				return false;
			}else if (xx >= 800) {
				return false;
			}else if (yy <= 0) {
				return false;
			}else if(yy >= 600){
				return false;
			}
			
			
			for (var i:* in objs) {
				if (exclude) {
					if (objs[i] == exclude) {
						continue;
					}
				}
				
				a = (xx - objs[i].x) * (xx - objs[i].x);
				b = (yy - objs[i].y) * (yy - objs[i].y);
				
				if (a + b < dis) {
					k = false;
					break;
				}
			}
			return k;
		}
		public static function placementAngle(angle:int, dis:int):Point {
			var p:Point = new Point()
			
			var radians:Number = angle * Math.PI / 180;
			
			var tx:int = Math.abs(Math.cos(radians)) * dis;
			var ty:int = Math.abs(Math.sin(radians)) * dis;
			
			if (angle == 90) {
				p.x = dis;
				p.y = 0;
			}else if (angle == 180) {
				p.y = dis;
			}else if (angle == 270) {
				p.x = -dis;
				p.y = 0;
			}else if (angle == 0) {
				p.x = 0;
				p.y = -dis;
			}else if (angle < 90) {
				p.x = tx;
				p.y = -ty;
			}else if (angle > 90 && angle<180) {
				p.x = tx;
				p.y = ty;
			}else if (angle > 180 && angle<270) {
				p.x = -tx;
				p.y = ty;
			}else if (angle > 270) {
				p.x = -tx;
				p.y = -ty;
			}
			return p;
		}
	
	}

}
