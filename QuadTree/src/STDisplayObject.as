package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Fournier Antoine
	 */
	public class STDisplayObject extends Sprite
	{
		private var mSpeed:int;
		private var mDirectionX:int;
		private var mDirectionY:int;
		private var mTimeLastFrame:int;
		private var mVisible:Boolean;
		
		private var mVisibleBitmap:Bitmap;
		private var mUnvisibleBitmap:Bitmap;
		
		
		public function STDisplayObject() 
		{
			addEventListener(Event.ENTER_FRAME, update);
			
			var w:int = Math.random() * 20 + 5;
			var h:int = Math.random() * 20 + 5;
			
			mVisibleBitmap = new Bitmap(new BitmapData(w, h, true, 0xffff0000));
			addChild(mVisibleBitmap);
			mUnvisibleBitmap = new Bitmap(new BitmapData(w, h, true, 0xff0000ff));
			addChild(mUnvisibleBitmap);
			
			mSpeed = (Math.random() * 60 + 20) * 2;
			mDirectionX = (int(Math.random() * 2) % 2 == 0) ? 1 : -1;
			mDirectionY = (int(Math.random() * 2) % 2 == 0) ? 1 : -1;
			
			mTimeLastFrame = getTimer();
			
			mVisible = true;
			mVisibleBitmap.visible = true;
		}
		
		private function update(_e:Event):void
		{
			var newTime:int = getTimer();
			var elapsed:int = newTime - mTimeLastFrame;
			mTimeLastFrame = newTime;
			
			x += (elapsed / 1000.0) * mSpeed * mDirectionX;
			y += (elapsed / 1000.0) * mSpeed * mDirectionY;
			
			if (mDirectionX == 1 && x + width > Main.SCREEN_WIDTH)
			{
				x = Main.SCREEN_WIDTH - width;
				mDirectionX = -1
			}
			if (mDirectionX == -1 && x < 0)
			{
				x = 0;
				mDirectionX = 1
			}
			if (mDirectionY == 1 && y + height > Main.SCREEN_HEIGHT)
			{
				y = Main.SCREEN_HEIGHT - height;
				mDirectionY = -1
			}
			if (mDirectionY == -1 && y < 0)
			{
				y = 0;
				mDirectionY = 1
			}
		}
		
		override public function get visible():Boolean 
		{
			return mVisible;
		}
		
		override public function set visible(_value:Boolean):void 
		{
			mVisible = _value;
			
			mVisibleBitmap.visible = mVisible;
			mUnvisibleBitmap.visible = !mVisible;
		}
		
		public function get Bound2D_MinX():int
		{
			return x;
		}
		
		public function get Bound2D_MaxX():int
		{
			return x + width;
		}
		
		public function get Bound2D_MinY():int
		{
			return y;
		}
		
		public function get Bound2D_MaxY():int
		{
			return y + height;
		}
	}

}