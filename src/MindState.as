package 
{
	/**
	 * ...
	 * @author ...
	 */
	public class MindState 
	{
		
		public static const ADVENTUROUS:int = 0;
		public static const MOVING:int 		= 1;
		public static const IDLE:int 		= 2;
		public static const HUNGRY:int 		= 3;
		public static const ASLEEP:int 		= 4;
		//
		
		
		public function MindState() 
		{
		
		}
		
		public static function GetNewMindState():int {
			return Math.round(Math.random() * 4)
		}
		
	}

}