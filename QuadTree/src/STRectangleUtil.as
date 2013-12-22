package 
{
	/**
	 * ...
	 * @author Fournier Antoine
	 */
	public class STRectangleUtil 
	{
		/**
		 * Return true if the first rectangle area entirely
		 * contains the second.
		 * @return True if r2 is contained by r1.
		 */
		public static function contains(_minX1:int, _minY1:int, _maxX1:int, _maxY1:int, _minX2:int, _minY2:int, _maxX2:int, _maxY2:int):Boolean
		{
			return (_minX1 <= _minX2 &&
					_minY1 <= _minY2 &&
					_maxX1 >= _maxX2 &&
					_maxY1 >= _maxY2);
		}
		
		/**
		 * Return true if the two rectangle area intersect.
		 * @return True if there is an intersection.
		 */
		public static function intersects(_minX1:int, _minY1:int, _maxX1:int, _maxY1:int, _minX2:int, _minY2:int, _maxX2:int, _maxY2:int):Boolean
		{
			return !(_maxX1 < _minX2 ||
					_maxX2 < _minX1 ||
					_maxY1 < _minY2 ||
					_maxY2 < _minY1);
		}
		
		/**
		 * Return true if the point is contained in the rectangle.
		 * @return True is the point in the rectangle.
		 */
		public static function containsPoint(_minX:int, _minY:int, _maxX:int, _maxY:int, _pointX:int, _pointY:int):Boolean
		{
			return (_pointX >= _minX &&
					_pointX <= _maxX &&
					_pointY >= _minY &&
					_pointY <= _maxY);
		}
	}

}