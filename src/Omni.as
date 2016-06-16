package {	
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class Omni {
		
		public static function removeItem(Arrayx:Array, item:*):void {
			for (var z:int = 0; z<Arrayx.length; z++) {
				if (Arrayx[z] == item) {
					Arrayx.splice(z, 1);
					z--;
					break;
				}
			}
		}
		
		public static function FindClosestObject(xx:int, yy:int, objs:Array, dis:int, exclude:PrimordialOrganism=null):PrimordialOrganism {		
			var k:PrimordialOrganism;
			var a:int;
			var b:int;
						
			var closest:int = int.MAX_VALUE;
			var obDis:int;
			for (var i:int; i < objs.length;i++ ) {
				if (exclude) {
					if (objs[i] == exclude) {
						continue;
					}
				}
				
				a = (xx - objs[i].x) * (xx - objs[i].x);
				b = (yy - objs[i].y) * (yy - objs[i].y);
				obDis = Math.sqrt(a + b);
				
				if (obDis < dis && obDis < closest) {
					k = objs[i];
					closest = obDis;
				}
				//trace(Math.sqrt(a + b), dis, objs[i]);
			}
			return k;
		}
		
		public static function FindFirstObject(xx:int, yy:int, objs:Array, dis:int, exclude:*=null):PrimordialOrganism {		
			//dis = (dis * dis);
			var k:PrimordialOrganism = null;
			var a:int;
			var b:int;
						
			for (var i:int; i < objs.length;i++ ) {
				if (exclude) {
					if (objs[i] == exclude) {
						continue;
					}
				}
				
				a = (xx - objs[i].x) * (xx - objs[i].x);
				b = (yy - objs[i].y) * (yy - objs[i].y);
				
				if (Math.sqrt(a + b) < dis) {
					k = objs[i]
					break;
				}
				
				//trace(Math.sqrt(a + b), dis, objs[i]);
			}
			return k;
		}
		public static function spaceIsFree(xx:int, yy:int, objs:Array, dis:int, exclude:*=null):Boolean{		
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
		
		public static function drawArc(displayOb:Sprite, centerX:Number, centerY:Number, startAngle:Number, endAngle:Number, radius:Number, direction:Number):void
		/* 
			centerX  -- the center X coordinate of the circle the arc is located on
			centerY  -- the center Y coordinate of the circle the arc is located on
			startAngle  -- the starting angle to draw the arc from
			endAngle    -- the ending angle for the arc
			radius    -- the radius of the circle the arc is located on
			direction   -- toggle for going clockwise/counter-clockwise
		*/
		{
			var g:Graphics = displayOb.graphics;
			var difference:Number = Math.abs(endAngle - startAngle);
			/* How "far" around we actually have to draw */
			
			var divisions:Number = Math.floor(difference / (Math.PI / 4))+1;
			/* The number of arcs we are going to use to simulate our simulated arc */
			
			var span:Number    = direction * difference / (2 * divisions);
			var controlRadius:Number    = radius / Math.cos(span);
			
			g.moveTo(centerX + (Math.cos(startAngle)*radius), centerY + Math.sin(startAngle)*radius);
			var controlPoint:Point;
			var anchorPoint:Point;
			for(var i:Number=0; i<divisions; ++i)
			{
				endAngle    = startAngle + span;
				startAngle  = endAngle + span;
				
				controlPoint = new Point(centerX+Math.cos(endAngle)*controlRadius, centerY+Math.sin(endAngle)*controlRadius);
				anchorPoint = new Point(centerX+Math.cos(startAngle)*radius, centerY+Math.sin(startAngle)*radius);
				g.curveTo(
					controlPoint.x,
					controlPoint.y,
					anchorPoint.x,
					anchorPoint.y
				);
			}
		}
	
	}

}
