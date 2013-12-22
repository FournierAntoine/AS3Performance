package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Fournier Antoine
	 */
	public class Main extends Sprite 
	{
		public static const SCREEN_WIDTH:int 	= 600;
		public static const SCREEN_HEIGHT:int 	= 450;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addChild(new Screen());
		}
		
	}
	
}