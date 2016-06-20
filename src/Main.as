package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.greensock.*; 
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.demonsters.debugger.MonsterDebugger;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/*
	 Bugs
	 
	 
	 To Dos
	 - Memory bank of last known location with food
	 
	 - some kind of pathfinding based on sight
		- tasked packets - eg. search with sight sends out ray beam to surrounding area
			segments of sight is processed in parts, not all at once (helps performance and is more realistic)
	 
			- some kind of genetic tasked process : ==> Genetic Algorithm
		- Search: can be made up of [FindClosest, Move, FindClosest, Move, ]
	 
	 [ Can randomise: life, hungerLimit, speed, signtDis ]
	 
	*/
	 
	public class Main extends Sprite {
		private static var _mainInstance:Main;
		
		public var physicalObjects:Array = []; // all objects[ Algae, Herbi, Carni ] 
		public var plantArr:Array = [];		// Algae
		public var animalsArr:Array = []; // Herbivores & Carnivores
		public var herbiArr:Array = []; // Herbivores
		public var carniArr:Array = []; // Carnivores
		
		private var GodAction:String = "";
		private var txt_spr:TextField;
		
		public function Main():void {
			_mainInstance = this;
			
			if (stage){
				init();
				
			}else{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		public static function GetInstance():Main {
			return _mainInstance;
		}
			
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			MonsterDebugger.initialize(this);
			MonsterDebugger.trace(this, "Hello World!");
			// entry point
			
			// ----- Add Food/Monsters
			var xx:int;
			var yy:int;
				
			for (var i:int = 0; i < 5; i++) {
				xx = Math.random() * stage.stageWidth;
				yy = Math.random() * stage.stageHeight;
				addAlgae(xx,yy);
			}
			
			//for (i = 0; i < 10; i++) {
				//xx = Math.random() * stage.stageWidth;
				//yy = Math.random() * stage.stageHeight;
				//addCreature(xx,yy);
					//
			//}
			//addCreature(400, 300);
			
			//addCarnivore(500, 300);
			// ----- Add Food/Monsters
			
			
			
			// ----- Stats Clock
			txt_spr = new TextField();
			addChild(txt_spr);
			
			var fps:FpsCounter = new FpsCounter();
			fps.x = stage.stageWidth - 50;
			addChild(fps);
			
			// ----- Admin Buttons
			var btns:Array = ["Selector", "Algae", "Carnivore", "Herbivore", "Omnivore", "Lamb", "Cripple"];
			for (var bn:* in btns) {
				var bt:BasicButton = new BasicButton(btns[bn]);
				bt.x = stage.stageWidth - ((bn + 1) * 110)
				bt.y = stage.stageHeight - 20;
				bt.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
					GodAction = e.currentTarget.ActionMode;
				} );
				addChild(bt);
			}
			
			// ----- Start Time
			addEventListener(Event.ENTER_FRAME, universal_clock);
			stage.addEventListener(MouseEvent.CLICK, clickofGod);
			// ----- Start Time
		}
		private function universal_clock(e:Event):void {
			this.graphics.clear();
			
			var txt:String 	 = "Herbivores: " + herbiArr.length +"\n";
			txt 			+= "Carnivores: " + carniArr.length +"\n";
			txt 			+= "All Animals -- " + animalsArr.length +"\n";
			txt_spr.text = txt;
			
			for (var cre:* in animalsArr) {
				drawSightDistance(animalsArr[cre]);
			}
			
			for (var organism:* in physicalObjects) {
					physicalObjects[organism].biologicalClock();
			}
			
		}
		
		
		private var polys:Array = [];

		private function clickofGod(e:MouseEvent):void {

			
			
			if (stage.mouseY < stage.stageHeight - 20) {
				switch(GodAction) {
					case "Algae":
						addAlgae(stage.mouseX, stage.mouseY);
						break;
					case "Carnivore":
						addCarnivore(stage.mouseX, stage.mouseY);
						break;
					case "Herbivore":
						addCreature(stage.mouseX, stage.mouseY);
						break;
					case "Lamb":
						addLamb(stage.mouseX, stage.mouseY).putAsleep();
						break;
					case "Cripple":
						var c:Carnivore = addCarnivore(stage.mouseX, stage.mouseY);
						c.speed = 0;
						c.lookForFood();
						break;
					case "Omnivore":
		
						break;
				}
			}

		}
		
		public function remove(food:*):void {
			Omni.removeItem(plantArr, food);
			Omni.removeItem(animalsArr, food);
			Omni.removeItem(physicalObjects, food);
			Omni.removeItem(carniArr, food);
			Omni.removeItem(herbiArr, food);
			removeChild(food);
		}
		public function addAlgae(xx:int, yy:int):Algae {
			var ok:Boolean = Omni.spaceIsFree(xx, yy, physicalObjects, 19);
			var mc:Algae;
			if (ok) {
				mc = new Algae(this);
				mc.x = xx;
				mc.y = yy;
				addChild(mc);
				
				plantArr.push(mc);
				physicalObjects.push(mc);
			}
			return mc;
		}
		
		public function addCreature(xx:int,yy:int):Herbivore {
			var mc:Herbivore = new Herbivore();
			mc.x = xx;
			mc.y = yy;
			addChild(mc);
			
			animalsArr.push(mc);
			physicalObjects.push(mc);
			herbiArr.push(mc);
			return mc;
		}
		
		public function addLamb(xx:int,yy:int):Herbivore {
			var mc:Herbivore = new Herbivore();
			mc.x = xx;
			mc.y = yy;
			mc.speed = 0;
			addChild(mc);
			
			animalsArr.push(mc);
			physicalObjects.push(mc);
			herbiArr.push(mc);
			return mc;
		}
		
		public function addCarnivore(xx:int,yy:int):Carnivore {
			var mc:Carnivore = new Carnivore();
			mc.x = xx;
			mc.y = yy;
			addChild(mc);
			
			animalsArr.push(mc);
			physicalObjects.push(mc);		
			carniArr.push(mc);
			
			return mc;
		}
		
		private function drawSightDistance(obj:Creature):void {
			this.graphics.lineStyle(1, 0);
			this.graphics.drawCircle(obj.x, obj.y, obj.sightDis);
		}
		
		public function setTarget(xx:int, yy:int, col:uint):void {
			//return;
			
			var n:TargetCross = new TargetCross(col);
			n.x = xx;
			n.y = yy;
			addChild(n);
		}
	
	}

}