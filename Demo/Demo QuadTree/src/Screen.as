package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Fournier Antoine
	 */
	public class Screen extends Sprite
	{
		private var mQuadTree:STQuadTree;
		
		private var mNodeBitmap:Bitmap;
		private var mNodeChild:Sprite;
		private var mNodeTree:Sprite;
		
		private var mChildrenList:Vector.<STDisplayObject>;
		
		private var mScreenView:Rectangle;
		private var mVisibleChildren:Vector.<STDisplayObject>;
		
		
		public function Screen() 
		{
			addEventListener(Event.ENTER_FRAME, update);
			
			mNodeTree = new Sprite();
			addChild(mNodeTree);
			mNodeChild = new Sprite();
			addChild(mNodeChild);
			
			mVisibleChildren = new Vector.<STDisplayObject>();
			
			mQuadTree = new STQuadTree(20);
			
			mChildrenList = new Vector.<STDisplayObject>();
			var child:STDisplayObject;
			for (var n:int = 0; n < 200; ++n)
			{
				child = new STDisplayObject();
				child.x = Math.random() * (Main.SCREEN_WIDTH - child.width);
				child.y = Math.random() * (Main.SCREEN_HEIGHT - child.height);
				mQuadTree.add(child);
				mChildrenList.push(child);
				mNodeChild.addChild(child);
			}
			
			mScreenView = new Rectangle(50, 50, Main.SCREEN_WIDTH / 2, Main.SCREEN_HEIGHT / 2);
			var bmp:BitmapData = new BitmapData(Main.SCREEN_WIDTH, Main.SCREEN_HEIGHT, true, 0x22000000);
			bmp.fillRect(mScreenView, 0x00ffffff);
			addChild(new Bitmap(bmp));
		}
		
		private function update(_e:Event):void
		{
			// Update the children in the QuadTree
			for (var n:int = 0; n < mChildrenList.length; ++n)
			{
				mQuadTree.remove(mChildrenList[n]);
				mQuadTree.add(mChildrenList[n]);
			}
			
			// Draw the QuadTree
			drawQuadTree();
			
			// Hide the last drawn children
			for (n = 0; n < mVisibleChildren.length; ++n)
				mVisibleChildren[n].visible = false;
			
			mVisibleChildren = mQuadTree.getVisibleDisplayObject(mScreenView.left, mScreenView.top, mScreenView.right, mScreenView.bottom);
			
			// Show the visible children
			for (n = 0; n < mVisibleChildren.length; ++n)
				mVisibleChildren[n].visible = true;
		}
		
		private function drawQuadTree():void
		{
			if (mNodeBitmap)
				mNodeTree.removeChild(mNodeBitmap);
			
			mNodeBitmap = new Bitmap(new BitmapData(Main.SCREEN_WIDTH, Main.SCREEN_HEIGHT, false, 0xffffffff));
			mNodeTree.addChild(mNodeBitmap);
			
			var nodeList:Vector.<STQuadTreeNode> = getListNode(mQuadTree.mRootNode);
			for (var n:int = 0; n < nodeList.length; ++n)
				drawRectangle(mNodeBitmap.bitmapData, nodeList[n].MinX, nodeList[n].MaxX, nodeList[n].MinY, nodeList[n].MaxY);
		}
		
		private function getListNode(_node:STQuadTreeNode, _listNode:Vector.<STQuadTreeNode> = null):Vector.<STQuadTreeNode>
		{
			if (!_listNode)
				_listNode = new Vector.<STQuadTreeNode>();
			
			if (!_node)
				return _listNode;
			
			if (_node.NumberAttachedChild)
				_listNode.push(_node);
			
			if (_node.TopLeftChild)
				getListNode(_node.TopLeftChild, _listNode);
			if (_node.TopRightChild)
				getListNode(_node.TopRightChild, _listNode);
			if (_node.BottomRightChild)
				getListNode(_node.BottomRightChild, _listNode);
			if (_node.BottomLeftChild)
				getListNode(_node.BottomLeftChild, _listNode);
			
			return _listNode;
		}
		
		private function drawRectangle(_bmp:BitmapData, _minX:int, _maxX:int, _minY:int, _maxY:int):void
		{
			for (var n:int = 0; n < _maxX - _minX; ++n)
			{
				_bmp.setPixel(_minX + n, _minY, 0x000000);
				_bmp.setPixel(_minX + n, _maxY, 0x000000);
			}
			
			for (n = 0; n < _maxY - _minY; ++n)
			{
				_bmp.setPixel(_minX, _minY + n, 0x000000);
				_bmp.setPixel(_maxX, _minY + n, 0x000000);
			}
		}
		
	}

}