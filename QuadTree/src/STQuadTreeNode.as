package  
{
	import flash.geom.Rectangle;
	import STDisplayObject;
	import STRectangleUtil;
	
	/**
	 * @author Fournier Antoine
	 */
	public class STQuadTreeNode 
	{
		// Structure containing the tree
		private var mManager:STQuadTree;
		
		// Parent node
		private var mParentNode:STQuadTreeNode;
		
		// Child Node of this node
		private var mChild_TopRight:STQuadTreeNode;
		private var mChild_BottomRight:STQuadTreeNode;
		private var mChild_BottomLeft:STQuadTreeNode;
		private var mChild_TopLeft:STQuadTreeNode;
		
		// List of children STDisplayObject
		private var mChildList:Vector.<STDisplayObject>;
		
		// Size of the node
		private var mSize:int;
		
		// Bounds of the node
		private var mMinX:int;
		private var mMaxX:int;
		private var mMinY:int;
		private var mMaxY:int;
		
		
		/**
		 * Constructor.
		 * 
		 * @param	_manager Manager of the tree
		 * @param	_x		 Position of the left limit of the node, in pixel
		 * @param	_y		 Position of the top limit of the node, in pixel
		 * @param	_depth	 Depth of this node
		 */
		public function STQuadTreeNode(_manager:STQuadTree, _x:int, _y:int, _size:int) 
		{
			mManager 			= _manager;
			mParentNode 		= null;
			
			mChild_TopRight 	= null;
			mChild_BottomRight 	= null;
			mChild_BottomLeft 	= null;
			mChild_TopLeft 		= null;
			
			mChildList 			= new Vector.<STDisplayObject>();
			
			mSize 				= _size;
			mMinX 				= _x;
			mMaxX 				= _x + mSize;
			mMinY 				= _y;
			mMaxY 				= _y + mSize;
		}
		
		public function dispose():void
		{
			mManager = null;
			mParentNode = null;
			
			if (mChild_TopRight)
				mChild_TopRight.dispose();
			mChild_TopRight = null;
			
			if (mChild_BottomRight)
				mChild_BottomRight.dispose();
			mChild_BottomRight = null;
			
			if (mChild_BottomLeft)
				mChild_BottomLeft.dispose();
			mChild_BottomLeft = null;
			
			if (mChild_TopLeft)
				mChild_TopLeft.dispose();
			mChild_TopLeft = null;
			
			mChildList.length = 0;
			mChildList = null;
		}
		
		/**
		 * Add a child to the node.
		 * If possible the smaller node will be created and used.
		 * If the object cannot be contained in the node, null is returned.
		 * 
		 * @param	_child	STDisplayObject to add.
		 * @return The STQuadTreeNode that contains the child, or null.
		 */
		public function addChild(_child:STDisplayObject):STQuadTreeNode
		{
			var child_MinX:int = _child.Bound2D_MinX;
			var child_MinY:int = _child.Bound2D_MinY;
			var child_MaxX:int = _child.Bound2D_MaxX;
			var child_MaxY:int = _child.Bound2D_MaxY;
			
			// This node is not big enough to contain entirely the child
			if (!STRectangleUtil.contains(mMinX, mMinY, mMinX + mSize, mMinY + mSize,
										child_MinX, child_MinY, child_MaxX, child_MaxY))
				return null;
			
			// We are already in the the smallest node
			if (mSize == mManager.Size)
			{
				mChildList.push(_child);
				return this;
			}
			
			
			// Check if the child can be contained in one subnode
			
			// TopLeft
			if (STRectangleUtil.contains(mMinX, mMinY, mMinX + mSize / 2, mMinY + mSize / 2,
										child_MinX, child_MinY, child_MaxX, child_MaxY))
			{
				if (!mChild_TopLeft)
					mChild_TopLeft = new STQuadTreeNode(mManager, mMinX, mMinY, mSize / 2);
				return mChild_TopLeft.addChild(_child);
			}
			
			// TopRight
			if (STRectangleUtil.contains(mMinX + mSize / 2, mMinY, mMaxX, mMinY + mSize / 2,
										child_MinX, child_MinY, child_MaxX, child_MaxY))
			{
				if (!mChild_TopRight)
					mChild_TopRight = new STQuadTreeNode(mManager, mMinX + mSize / 2, mMinY, mSize / 2);
				return mChild_TopRight.addChild(_child);
			}
			
			// BottomRight
			if (STRectangleUtil.contains(mMinX + mSize / 2, mMinY + mSize / 2, mMaxX, mMaxY,
										child_MinX, child_MinY, child_MaxX, child_MaxY))
			{
				if (!mChild_BottomRight)
					mChild_BottomRight = new STQuadTreeNode(mManager, mMinX + mSize / 2, mMinY + mSize / 2, mSize / 2);
				return mChild_BottomRight.addChild(_child);
			}
			
			// BottomLeft
			if (STRectangleUtil.contains(mMinX, mMinY + mSize / 2, mMinX + mSize / 2, mMaxY,
										child_MinX, child_MinY, child_MaxX, child_MaxY))
			{
				if (!mChild_BottomLeft)
					mChild_BottomLeft = new STQuadTreeNode(mManager, mMinX, mMinY + mSize / 2, mSize / 2);
				return mChild_BottomLeft.addChild(_child);
			}
			
			// If we are here, it means that there is no subnode that can contains the child
			mChildList.push(_child);
			return this;
		}
		
		/**
		 * Remove the given STDisplayObject from the child list of the node.
		 * This method is not recursive, it will not check in the child node
		 * if the object exist.
		 * 
		 * @param	_child STDisplayObject to remove.
		 */
		public function removeChild(_child:STDisplayObject):void
		{
			var index:int = mChildList.indexOf(_child);
			if (index != -1)
				mChildList.splice(index, 1);
			
			// Clean the tree
			if (mChildList.length == 0)
				removeEmptyNode();
		}
		
		/**
		 * Clean the node by removing the empty child node.
		 * This method will recursively call itself with the parent
		 * node of this node if it need to be removed.
		 */
		public function removeEmptyNode():void
		{
			if (mChild_TopLeft && mChild_TopLeft.NumberChild == 0)
			{
				mChild_TopLeft.dispose();
				mChild_TopLeft = null;
			}
			if (mChild_TopRight && mChild_TopRight.NumberChild == 0)
			{
				mChild_TopRight.dispose();
				mChild_TopRight = null;
			}
			if (mChild_BottomRight && mChild_BottomRight.NumberChild == 0)
			{
				mChild_BottomRight.dispose();
				mChild_BottomRight = null;
			}
			if (mChild_BottomLeft && mChild_BottomLeft.NumberChild == 0)
			{
				mChild_BottomLeft.dispose();
				mChild_BottomLeft = null;
			}
			
			if (mChildList.length == 0)
			{
				if (mParentNode)
					mParentNode.removeEmptyNode();
				else
					mManager._removeRootNode();
			}
		}
		
		/**
		 * Return the list of every children of this node.
		 * This will test the intersection of the given area with
		 * each child node and return the objects of the ones
		 * that intersect.
		 * If the _getFullList flag is set, all the child node's objects
		 * will be returned.
		 * 
		 * If the node is not fully in the given area, each objects will be
		 * tested against this area and returned only if he intersect with it.
		 * 
		 * @param	_list	List that will contains the objects.
		 * @param	_getFullList	If set to true, the intersection test will not be done and all the objects will be returned.
		 */
		public function getVisibleDisplayObject(_minX:int, _minY:int, _maxX:int, _maxY:int, _getFullList:Boolean = false, _list:Vector.<STDisplayObject> = null):Vector.<STDisplayObject>
		{
			if (!_list)
				_list = new Vector.<STDisplayObject>();
			
			// If we are here, the node is intersecting with the given area
			// If the node is not entirely contained in the area, check each children object
			if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mMinX, mMinY, mMaxX, mMaxY))
				_list = _list.concat(mChildList);
			else
			{
				var len:int = mChildList.length;
				for (var n:int = 0; n < len; ++n)
				{
					var child:STDisplayObject = mChildList[n];
					if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY,
												child.Bound2D_MinX, child.Bound2D_MinY, child.Bound2D_MaxX, child.Bound2D_MaxY))
						_list.push(child);
				}
			}
			
			// If the node is entirely in the given area, we dont need to check the intersection for his quarter
			if (_getFullList)
			{
				if (mChild_TopLeft)
					_list = mChild_TopLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
				if (mChild_TopRight)
					_list = mChild_TopRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
				if (mChild_BottomRight)
					_list = mChild_BottomRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
				if (mChild_BottomLeft)
					_list = mChild_BottomLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
			}
			else
			{
				// For each quarter check if they are contained or intersect with the given area
				if (mChild_TopLeft)
				{
					if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mChild_TopLeft.MinX, mChild_TopLeft.MinY, mChild_TopLeft.MaxX, mChild_TopLeft.MaxY))
						_list = mChild_TopLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
					else if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY, mChild_TopLeft.MinX, mChild_TopLeft.MinY, mChild_TopLeft.MaxX, mChild_TopLeft.MaxY))
						_list = mChild_TopLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, false, _list);
				}
				if (mChild_TopRight)
				{
					if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mChild_TopRight.MinX, mChild_TopRight.MinY, mChild_TopRight.MaxX, mChild_TopRight.MaxY))
						_list = mChild_TopRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
					else if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY, mChild_TopRight.MinX, mChild_TopRight.MinY, mChild_TopRight.MaxX, mChild_TopRight.MaxY))
						_list = mChild_TopRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, false, _list);
				}
				if (mChild_BottomRight)
				{
					if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mChild_BottomRight.MinX, mChild_BottomRight.MinY, mChild_BottomRight.MaxX, mChild_BottomRight.MaxY))
						_list = mChild_BottomRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
					else if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY, mChild_BottomRight.MinX, mChild_BottomRight.MinY, mChild_BottomRight.MaxX, mChild_BottomRight.MaxY))
						_list = mChild_BottomRight.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, false, _list);
				}
				if (mChild_BottomLeft)
				{
					if (STRectangleUtil.contains(_minX, _minY, _maxX, _maxY, mChild_BottomLeft.MinX, mChild_BottomLeft.MinY, mChild_BottomLeft.MaxX, mChild_BottomLeft.MaxY))
						_list = mChild_BottomLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, true, _list);
					else if (STRectangleUtil.intersects(_minX, _minY, _maxX, _maxY, mChild_BottomLeft.MinX, mChild_BottomLeft.MinY, mChild_BottomLeft.MaxX, mChild_BottomLeft.MaxY))
						_list = mChild_BottomLeft.getVisibleDisplayObject(_minX, _minY, _maxX, _maxY, false, _list);
				}
			}
			
			return _list;
		}
		
		/**
		 * Return the number of object attached to this node.
		 */
		public function get NumberAttachedChild():int
		{
			return mChildList.length;
		}
		
		/**
		 * Return the number of object of this node and all his child node.
		 */
		public function get NumberChild():int
		{
			var num:int = mChildList.length;
			
			if (mChild_TopLeft)
				num += mChild_TopLeft.NumberChild;
			if (mChild_TopRight)
				num += mChild_TopRight.NumberChild;
			if (mChild_BottomRight)
				num += mChild_BottomRight.NumberChild;
			if (mChild_BottomLeft)
				num += mChild_BottomLeft.NumberChild;
			
			return num;
		}
		
		public function get Size():int
		{
			return mSize;
		}
		
		public function get MinX():int
		{
			return mMinX;
		}
		
		public function get MinY():int
		{
			return mMinY;
		}
		
		public function get MaxX():int
		{
			return mMaxX;
		}
		
		public function get MaxY():int
		{
			return mMaxY;
		}
		
		public function set ParentNode(_node:STQuadTreeNode):void
		{
			mParentNode = _node;
		}
		
		public function set TopLeftChild(_node:STQuadTreeNode):void
		{
			mChild_TopLeft = _node;
		}
		
		public function set TopRightChild(_node:STQuadTreeNode):void
		{
			mChild_TopRight = _node;
		}
		
		public function set BottomRightChild(_node:STQuadTreeNode):void
		{
			mChild_BottomRight = _node;
		}
		
		public function set BottomLeftChild(_node:STQuadTreeNode):void
		{
			mChild_BottomLeft = _node;
		}
		
		
		
		
		
		
		public function get TopLeftChild():STQuadTreeNode
		{
			return mChild_TopLeft;
		}
		
		public function get TopRightChild():STQuadTreeNode
		{
			return mChild_TopRight;
		}
		
		public function get BottomRightChild():STQuadTreeNode
		{
			return mChild_BottomRight;
		}
		
		public function get BottomLeftChild():STQuadTreeNode
		{
			return mChild_BottomLeft;
		}
	}

}