package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	
	public class creature extends MovieClip {
		private var thing:*;
		public var master:Main;
		
		public var mindState:String = "adventurous";// adventurous moving idle hungry
		public var physicalState:String = "idle"; // moving
		public var isBusy:Boolean = false; // no doing anything, can make decisions
		
		// stats
		public var size:int = 1;
		public var speed:int = 1;
		public var sightDis:int = 100;
		public var lazyness:int = 5;
		public var hungerlevel:int = 0;
		public var life:Number = 100;
		
		public var reproductionLevel:int = 0; // Once reaches 100 - Makes offspring
		public var reproductionLevelMax:int = 300;
		public var idleTime:int;
		public var starveLevel:int = 100;
		
		// movement
		public var tx:int;
		public var ty:int;
		
		// icons
		public var i_hunger:icon_hungry = new icon_hungry();
		
		
		public function creature(th:*):void {
			thing = th;
			master = Main.GetInstance();
			addChild(thing);
			
			thing.gotoAndStop("idle");
			addEventListener(Event.ENTER_FRAME, biologicalClock);
			
			growth();
		}
		
		private function animateCircle( pc:Number, rad:int, color:uint, thickness:Number):void {
			//master.graphics.clear();
			this.graphics.lineStyle(1, 0);
			this.graphics.drawCircle(0, 0, sightDis);
			
			this.graphics.lineStyle(thickness, color);
			drawArc(0, 0, 0, (pc * Math.PI * 2 ), rad, 1);
		}
		
		private function updateIcons():void {
			if (hungerlevel < starveLevel) {
				if (!contains(i_hunger) ) {
					addChild(i_hunger);
				}
			}else {
				if ( contains(i_hunger) ) {
					removeChild(i_hunger);
				}
			}
			
			//-----
			
			
			if (life < 0) {
				removeEventListener(Event.ENTER_FRAME, biologicalClock);
				master.remove(this);
			}		
		}
		
		private function growth():void {
			var scale:Number;
			
			if (size < 100) {
				scale = (((size) / 100) * 0.3) + 0.7;
			}else {
				scale = (Math.log(size)/Math.log(10) / 2 );
			}
			
			this.scaleX = this.scaleY = scale;
			
		}
		
		private function hunger() :void{
			this.life -= 0.1;
		}
		
		private function tryTake(num:int, take:int):int {
			if (num > take) {
				return take;
			}else {
				return num;
			}
		}
		public function biologicalClock(e:Event):void {
			
			
			//----- Show Status Icons
			updateIcons(); 
			
			
			// Draw Health Circles
			this.graphics.clear();

			var numHeathTanks:int = Math.ceil(life / 100);
			var hitpoints:int = life;
			for (var i:int = 0; i < numHeathTanks; i++) {
				var levelCap:int = 100 + (100 * i);
				var take:int = tryTake(hitpoints, levelCap );
				var hp:Number = take / levelCap;
				hitpoints -= take;
				if (hitpoints < 0) {
					break;
				}
				
				animateCircle(hp, 22 + (i * 2), 0x6bce45, 0.5); // Green
			}
			animateCircle((reproductionLevel / reproductionLevelMax), 20, 0xfe99ff, 2.0 ); // Pink
			
			//------ Check Special Life Events
			if (reproductionLevel > reproductionLevelMax) {
				reproductionLevel = 0;
				master.addCreature(this.x + 30, this.y);
			}
			
			
			//------ Growth			
			growth();
			hunger();
			
			//------ Personality
			
			if (!isBusy) {
				if (mindState == "adventurous" ) {
					setRandomMovementTarget();
				}else if (mindState == "idle") {
					thing.gotoAndStop("idle");
					idleTime--;
					
					if (idleTime < 0) {
						physicalState = "idle";
						reRollMindState();
					}
				}else if (mindState == "hungry") {
					scanForFood();
				}
			}else {
				// is busy doing something
				switch(physicalState) {
					case "moving":
						thing.gotoAndStop("move");
						
						if (mindState == "hungry") {
							lookForFood(sightDis);
						}
											
						var dx:Number = tx - x;
						var dy:Number = ty - y;
						var distance:Number = Math.sqrt(dx * dx + dy * dy);
						
						var toMovex:Number = speed * dx / distance;
						var toMovey:Number = speed * dy / distance;
						
						if (calc.canAddHere(x + toMovex, y + toMovey, master.physicalObjects,20, this)) {
							x += toMovex;
							y += toMovey;
						}else {
							dx = dy = 0;
						}

						if (Math.abs(dx) < 10 && Math.abs(dy) < 10) {
							if (lookForFood(25)) {// found food
								physicalState = "eating";
								thing.gotoAndStop("eat");
								isBusy = true;
								
								faceTar();
								return;
							}
							
							finishedTask();
						}
						break;
					case "eating":
						
						// check if touching food/enemy
						var ob:int = calc.ObstructedAddHere(x, y, master.physicalObjects, 25, this);
						if (ob>0) {
							master.physicalObjects[ob].life--;
							hungerlevel++;
							
							life += 1;
							size += 1;
							reproductionLevel++;
							//faceTar();
						}else {
							finishedTask();
						}
						break;
				}
				
			}
			
			
		}
		private function finishedTask():void {
			physicalState = "idle";
			isBusy = false;
			reRollMindState();
		}
		private function scanForFood():void {
			if (!lookForFood(sightDis)) {
				setRandomMovementTarget();
			}
		}
		public function lookForFood(dis:int):Boolean {
			var foundFood:Boolean = false;
			var ob:int = calc.ObstructedAddHere(x, y, master.plantArr, dis);
			if (ob>0) {
				tx = master.plantArr[ob].x;
				ty = master.plantArr[ob].y;
			
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
		public function faceTar():void {
			var deg:int = (180 * Math.atan( (tx - x) / (ty - y) )) / Math.PI;
			if (tx > x) {
				rotation = Math.abs(deg);
				
				if (ty > y) {
					rotation = -Math.abs(deg)+180;
				}
			}else {
				rotation = -Math.abs(deg);
				if (ty > y) {
					rotation = -(180-Math.abs(deg));
				}
			}
		}
		private function reRollMindState():void {
			var states:Array = ["adventurous","idle", "hungry"];
			mindState = states[Math.floor(Math.random() * states.length)];
			
			if (mindState == "idle") {
				idleTime = Math.random() * lazyness * 15;
			}
			
			if (hungerlevel < starveLevel) {
				mindState = "hungry";
			}
		}
		private function setRandomMovementTarget():void {
			var angle:int = 30 * Math.round(Math.random() * 12);
			var p:Point = calc.placementAngle(angle, sightDis);
			
			tx = x + p.x;
			ty = y + p.y;
			
			faceTar();
			
			isBusy = true;
			physicalState = "moving";
		}
		
		private function drawArc(centerX:Number, centerY:Number, startAngle:Number, endAngle:Number, radius:Number, direction:Number):void
		/* 
			centerX  -- the center X coordinate of the circle the arc is located on
			centerY  -- the center Y coordinate of the circle the arc is located on
			startAngle  -- the starting angle to draw the arc from
			endAngle    -- the ending angle for the arc
			radius    -- the radius of the circle the arc is located on
			direction   -- toggle for going clockwise/counter-clockwise
		*/
		{
			var g:Graphics = this.graphics;
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
		//
	}

}
