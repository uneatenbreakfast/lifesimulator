package  
{
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.TextEvent;
	import flash.text.TextField;

		
	public class BasicButton extends Sprite
	{
		public var ActionMode:String;
		
		public function BasicButton(txt:String) 
		{
			ActionMode = txt;
			//
			
			var goButton:SimpleButton = new SimpleButton();
			
			var spr:Sprite = new Sprite();
			spr.graphics.lineStyle(1, 0x009999);
			spr.graphics.beginFill(0x66998f, 1);
			spr.graphics.drawRect(0,0,100,20);
			spr.graphics.endFill();
			
			var txtf:TextField = new TextField();
			txtf.text = txt;
			
			spr.addChild(txtf);
			
			goButton.overState = goButton.downState = goButton.upState = goButton.hitTestState = spr;
			addChild(goButton);
		}
		
	}

}