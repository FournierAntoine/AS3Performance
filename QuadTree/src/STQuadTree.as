package  
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import STDisplayObject;
	import STRectangleUtil;
	
	/**
	 * Handle the QuadTree method.
	 * 
	 * The STQuadTree is an auto-expanding QuadTree. It means that there
	 * is no need to initialize it with a reactangular area.
	 * It will automaticaly create the nodes needed to contains every
	 * added STDisplayObject.
	 * 
	 * @author Fournier Antoine
	 */
	public class STQuadTree 
	{
		// Size of the smaller leaf node, in pixel
		private var mSize:int;
		
		// Root node of the tree
		public var mRootNode:STQuadTreeNode; /////
		
		// Associate each STDisplayObject with their STQuadTreeNode
		// This is a direct access to the node containing every STDisplayObject
		private var mObjectNodeDictionary:Dictionary;
		
		
		/**
		 * The STQuadTree is an auto-expanding QuadTree.
		 * 
		 * @param	_size	Size of the smallest node of the tree.
		 */
		public function STQuadTree(_size:int) 
		{
			mSize 					= _size;
			mRootNode 				= null;
			mObjectNodeDictionary 	= new Dictionary();
		}
		
		/**
		 * Dispose every allocated ressources.
		 */
		public function dispose():void
		{
			if (mRootNode)
				mRootNode.dispose();
			mRootNode = null;
			mObjectNodeDictionary = null;
		}
		
		/**
		 * Add the given STDisplayObject to the QuadTree.
		 * 
		 * @param	_child STDisplayObject to add.
		 */
		public function add(_child:STDisplayObject):void
		{
			// If the object is already in the tree, dont add it again
			if (mObjectNodeDictionary[_child] != undefined)
				return;
			
			// This is the first object we add, we have to find the
			// smallest node containing it entirely
			if (!mRootNode)
				createRootNode(_child);
			
			// If the child is too big for the root node, expand it
			var node:STQuadTreeNode = mRootNode.addChild(_child);
			while (!node)
			{
				expandRootNode(_child);
				node = mRootNode.addChild(_child);
			}
			
			// Add the child to the list of child
			mObjectNodeDictionary[_child] = node;
		}
		
		/**
		 * Remove the given STDisplayObject from the QuadTree.
		 * 
		 * If the containing node is empty after the removal,
		 * The node will be removed.
		 * The QuadTree actually don't keep his empty node.
		 * 
		 * @param	_child STDisplayObject to remove.
		 */
		public function remove(_child:STDisplayObject):void
		{
			var node:STQuadTreeNode = mObjectNodeDictionary[_child];
			if (!node)
				return;
			node.removeChild(_child);
			delete mObjectNodeDictionary[_child];
		}
		
		/**
		 * Return all the STDisplayObject in the QuadTree.
		 * @return Vector containing the list of every object in the QuadTree.
		 */
		public function getAllDisplayObject():Vector.<STDisplayObject>
		{
			if (!mRootNode)
				return new Vector.<STDisplayObject>();
			return mRootNode.getVisibleDisplayObject(0, 0, 0, 0, true);
		}
		
		/**
		 * Return the list of STDisplayObject contained in the
		 * node of the QuadTree which intersect with the given area.
		 * 
		 * Note that this may return objects that are not in the given area.
		 * This is because the intersection test is done with the node,
		 * not with every object.
		 * 
		 * @return Vector containing the list of every object in the given area.
		 */
		public function getVisibleDisplayObject(_minX:int, _minY:int, _maxX:int, _maxY:int):Vector.<STDisplayObject>
		{
			var list:Vector.<STDisplayObject> = new Vector.<STDisplayObject>();
			
			if (!mRootNode)
				return list;
			
			if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mRootNode.MinX, mRootNode.MinY, mRootNode.MaxX, mRootNode.MaxY))
				list = mRootNode.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, list);
			else if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY, mRootNode.MinX, mRootNode.MinY, mRootNode.MaxX, mRootNode.MaxY))
				list = mRootNode.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, false, list);
			
			return list;
		}
		
		public function get Size():int
		{
			return mSize;
		}
		
		// Helper function to create the first root node
		private function createRootNode(_child:STDisplayObject):void
		{
			if (mRootNode)
				return;
			
			// Get the position of the node that will contain the object
			var posX:int, posY:int;
			posX = int(_child.Bound2D_MinX / mSize) * mSize;
			if (posX > _child.Bound2D_MinX) posX -= mSize;
			posY = int(_child.Bound2D_MinY / mSize) * mSize;
			if (posY > _child.Bound2D_MinY) posY -= mSize;
			
			// Get the size of the smallest node we have to create
			var size:int = mSize;
			while ((posX + size < _child.Bound2D_MaxX) ||
				  (posY + size < _child.Bound2D_MaxY))
				size *= 2;
			
			mRootNode = new STQuadTreeNode(this, posX, posY, size);
		}
		
		// Helper function to expand the QuadTree root node.
		private function expandRootNode(_child:STDisplayObject):void
		{
			// We need to know which quarter of the new root node
			// the actual root node will be 
			// To know in which direction we will expand the QuadTree
			// we use the center point of the child to add
			
			var objCenterX:int = (_child.Bound2D_MaxX + _child.Bound2D_MinX) / 2;
			var objCenterY:int = (_child.Bound2D_MaxY + _child.Bound2D_MinY) / 2;
			var nodeCenterX:int = (mRootNode.MaxX + mRootNode.MinX) / 2;
			var nodeCenterY:int = (mRootNode.MaxY + mRootNode.MinY) / 2;
			var node:STQuadTreeNode;
			
			// The actual node will be the top left quarter
			if (objCenterX > nodeCenterX &&
				objCenterY > nodeCenterY)
			{
				node = new STQuadTreeNode(this, mRootNode.MinX, mRootNode.MinY, mRootNode.Size * 2);
				mRootNode.ParentNode = node;
				node.TopLeftChild = mRootNode;
				mRootNode = node;
				return;
			}
			
			// The actual node will be the top right quarter
			if (objCenterX <= nodeCenterX &&
				objCenterY > nodeCenterY)
			{
				node = new STQuadTreeNode(this, mRootNode.MinX - mRootNode.Size, mRootNode.MinY, mRootNode.Size * 2);
				mRootNode.ParentNode = node;
				node.TopRightChild = mRootNode;
				mRootNode = node;
				return;
			}
			
			// The actual node will be the bottom right quarter
			if (objCenterX <= nodeCenterX &&
				objCenterY <= nodeCenterY)
			{
				node = new STQuadTreeNode(this, mRootNode.MinX - mRootNode.Size, mRootNode.MinY - mRootNode.Size, mRootNode.Size * 2);
				mRootNode.ParentNode = node;
				node.BottomRightChild = mRootNode;
				mRootNode = node;
				return;
			}
			
			// The actual node will be the bottom left quarter
			if (objCenterX > nodeCenterX &&
				objCenterY <= nodeCenterY)
			{
				node = new STQuadTreeNode(this, mRootNode.MinX, mRootNode.MinY - mRootNode.Size, mRootNode.Size * 2);
				mRootNode.ParentNode = node;
				node.BottomLeftChild = mRootNode;
				mRootNode = node;
				return;
			}
		}
		
		/**
		 * Internal use.
		 */
		public function _removeRootNode():void
		{
			if (mRootNode.NumberChild == 0)
			{
				mRootNode.dispose();
				mRootNode = null;
			}
		}
		
		/**
		 * Return the list of objects in the QuadNode bellow the given point.
		 * 
		 * @param	_x Position to check.
		 * @param	_y Position to check.
		 * @param	_returnedList If set the result will be returned in this list.
		 * @return List of STDisplayObject.
		 */
		/*public function getObjectsAt(_x:int, _y:int, _returnedList:Vector.<STDisplayObject> = null):Vector.<STDisplayObject>
		{
			if (_returnedList == null)
				_returnedList = new Vector.<STDisplayObject>();
			
			// Check if the point is in the QuadTree
			if (!STRectangleUtil.containsPoint(mRootNode.MinX, mRootNode.MinY, mRootNode.MaxX, mRootNode.MaxY, _x, _y))
				return _returnedList;
			
			// Get the node at the given position
			var node:STQuadTreeNode = mRootNode;
			while (node.Size != mSize)
			{
				
			}
			
			// Test the collision of the point with every 
			return node;
		}*/
		
	}

}