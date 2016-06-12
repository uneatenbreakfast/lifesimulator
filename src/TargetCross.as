package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author ...
	 */
	public class TargetCross extends Sprite
	{
		
		public function TargetCross(col:uint) 
		{
			this.graphics.lineStyle(2, col);
			this.graphics.moveTo( -10, 0);
			this.graphics.lineTo(10, 0);
			this.graphics.moveTo(0, -10);
			this.graphics.lineTo(0, 10);
			
		}
		
	}

}