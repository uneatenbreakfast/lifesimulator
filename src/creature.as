package {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	
	public class creature extends PrimordialOrganism {
	
		
		private var thing:*;
		public var master:Main;
		
		public var mindState:String = "adventurous";// adventurous, moving, idle, hungry
		public var physicalState:String = "idle"; // moving,
		public var isBusy:Boolean = false; // not doing anything, can make decisions
		
		//Herbi/Carni
		public var foodPreference:Array = [];
		
		// stats
		public var size:int = 1;
		public var touchRadius:int = 10; // Radius of hitArea
		public var speed:int = 1;
		public var sightDis:int = 200;
		public var lazyness:int = 5;
		
		private var hungerLimit:int = 100; 
		
		public var reproductionLevel:int = 0; // Once reaches 100 - Makes offspring
		public var reproductionLevelMax:int = 300;
		public var idleTime:int;
		
		// movement
		public var tx:int;
		public var ty:int;
		private var stuckLimit:int = 50;
		
		// icons
		public var i_hunger:icon_hungry = new icon_hungry();
		
		
		public function creature(th:*):void {
			thing = th;
			master = Main.GetInstance();
			addChild(thing);
			
			thing.gotoAndStop("idle");
			
			growth();
		}
		
		private function animateCircle( pc:Number, rad:int, color:uint, thickness:Number):void {

			
			this.graphics.lineStyle(thickness, color);
			Omni.drawArc(this, 0, 0, 0, (pc * Math.PI * 2 ), rad, 1);
		}
		
		private function updateIcons():void {
			if (life < hungerLimit) {
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
		private function checkStuckStatus():void {
			if (stuckLimit < 0) {
				stuckLimit = 50;
				finishedTask();// character can't reach target location, so do something else
			}
			stuckLimit--;
		}
		public function biologicalClock():void {
			
			
			//----- Show Status Icons
			updateIcons(); 
			
			
			//  Health Circles
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
			reproduction();
			
			
			
			//------ Growth			
			growth(); // change scaleXY
			hunger(); // minus life slowly
			
			//------ Personality
			
			if (!isBusy) {
				switch(mindState) {
					case "adventurous":
						setRandomMovementTarget();
						break;
					case "idle":
						thing.gotoAndStop("idle");
						idleTime--;
						
						if (idleTime < 0) {
							physicalState = "idle";
							reRollMindState();
						}
						break;
					case "hungry":
						scanForFood();
						break;
				}
			}else {
				// is busy doing something
				switch(physicalState) {
					case "moving":
						thing.gotoAndStop("move");
						
						if (mindState == "hungry") {
							lookForFood();
						}
											
						var dx:Number = tx - x;
						var dy:Number = ty - y;
						var distance:Number = Math.sqrt(dx * dx + dy * dy);
						
						var toMovex:Number = speed * dx / distance;
						var toMovey:Number = speed * dy / distance;
						
						if (Omni.spaceIsFree(x + toMovex, y + toMovey, master.physicalObjects,touchRadius, this)) {
							x += toMovex;
							y += toMovey;
						}else {
							dx = dy = 0;
							checkStuckStatus();
						}

						if (distance < touchRadius + 5) {
							if (lookForFood()) {// found food
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
						eat();
						break;
				}
			}
		}
		public function finishedTask():void {
			trace("[Finished Task]");
			physicalState = "idle";
			isBusy = false;
			reRollMindState();
		}
		private function scanForFood():void {
			if (!lookForFood()) {
				setRandomMovementTarget();
			}
		}
		public function lookForFood():Boolean {
			var foundFood:Boolean = false;
			var ob:PrimordialOrganism = Omni.FindClosestObject(x, y, foodPreference, sightDis, this);
			if (ob != null) {
				tx = ob.x;
				ty = ob.y;
			
				//rotation = angle;
				// face food
				faceTar();
				master.setTarget(tx, ty, 0xFF0000);
				
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
			
			if (life < hungerLimit) {
				mindState = "hungry";
			}
			
			trace("[MindState: "+ mindState +"]");
		}
		private function setRandomMovementTarget():void {
			var angle:int = 30 * Math.round(Math.random() * 12);
			var p:Point = Omni.placementAngle(angle, sightDis);
			
			tx = x + p.x;
			ty = y + p.y;
			
			faceTar();
			master.setTarget(tx, ty, 0x00FFFF);
			
			isBusy = true;
			physicalState = "moving";
		}
		
		// Overrides
		public function eat():void {
			var ob:PrimordialOrganism = Omni.FindClosestObject(x, y, foodPreference, 20, this);
			if (ob != null) {
				ob.life--;
				
				life += 1;
				size += 1;
				reproductionLevel++;
				//faceTar();
			}else {
				finishedTask();
			}
		}
		
		public function reproduction():void {
			if (reproductionLevel > reproductionLevelMax) {
				reproductionLevel = 0;
				master.addCreature(this.x + 30, this.y);
			}
		}
		//
	}

}
