package {
	import flash.display.Sprite;
	import flash.events.Event;
	import com.greensock.*; 
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.demonsters.debugger.MonsterDebugger;
	import flash.text.TextField;
	//---
	
	/**
	 * ...
	 * @author Nelson
	 */
	public class Main extends Sprite {
		private static var _mainInstance:Main;
		
		public var physicalObjects:Array = []; // all objects
		public var plantArr:Array = [];
		public var animalsArr:Array = []; // Herbivores & Carnivores
		public var herbiArr:Array = []; // Herbivores
		public var carniArr:Array = []; // Carnivores
		
		
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
			
			for (i = 0; i < 10; i++) {
				xx = Math.random() * stage.stageWidth;
				yy = Math.random() * stage.stageHeight;
				addCreature(xx,yy);
					
			}
			addCreature(400, 300);
			
			addCarnivore(500, 300);
			// ----- Add Food/Monsters
			
			
			
			// ----- Stats Clock
			txt_spr = new TextField();
			txt_spr.text = "Herbivores: ";
			addChild(txt_spr);
			
			addEventListener(Event.ENTER_FRAME, universal_clock);

			//TweenLite.to(tarMC, .2, {alpha:1, removeTint:true,glowFilter:{color:0xFFFFFF, alpha:1, blurX:0, blurY:0}, onComplete: finishedAnimation});	
		}
		private function universal_clock(e:Event):void {
			txt_spr.text = "Herbivores: "+herbiArr.length;
		}
		
		public function remove(food:*):void {
			calc.removeItem(plantArr, food);
			calc.removeItem(animalsArr, food);
			calc.removeItem(physicalObjects, food);
			calc.removeItem(carniArr, food);
			calc.removeItem(herbiArr, food);
			removeChild(food);
		}
		public function addAlgae(xx:int, yy:int):void {
			var ok:Boolean = calc.canAddHere(xx,yy, physicalObjects, 19);
			if (ok) {
				var mc:algae = new algae(this);
				mc.x = xx;
				mc.y = yy;
				addChild(mc);
				
				plantArr.push(mc);
				physicalObjects.push(mc);
			}
		}
		
		public function addCreature(xx:int,yy:int):void {
			var mc:herbivore = new herbivore();
			mc.x = xx;
			mc.y = yy;
			addChild(mc);
			
			animalsArr.push(mc);
			physicalObjects.push(mc);
			herbiArr.push(mc);
		}
		
		public function addCarnivore(xx:int,yy:int):void {
			var mc:carnivore = new carnivore();
			mc.x = xx;
			mc.y = yy;
			addChild(mc);
			
			animalsArr.push(mc);
			physicalObjects.push(mc);		
			carniArr.push(mc);
		}
	
	}

}