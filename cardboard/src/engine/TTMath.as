
package engine 
{
	/**
	 * Helper class of math functions, e.g. for collision detection
	 * @author Gifford Cheung
	 */
	public class TTMath
	{
		/**
		 * custom math function, sorry for the lack of details. For a line segment, determines if pxpy is "inside" the line segment. 
		 *  This is with regards to a convex shape. where, in clockwise order, the points go a->b
		 * @param	a_x
		 * @param	a_y
		 * @param	b_x
		 * @param	b_y
		 * @param	px
		 * @param	py
		 * @return
		 */
		public static function lineCross(a_x:Number, a_y:Number, b_x:Number, b_y:Number, px:Number, py:Number):Boolean {
			
			var crossed:Boolean = true;
			var ab_y:Number = TTMath.lineY(a_x, a_y, b_x, b_y, px, py);
			if (!isNaN(ab_y)) {
				if (a_x < b_x) {
					crossed = crossed && py > ab_y;
				} else {
					crossed = crossed && py < ab_y;
				}
			} else {
				if (a_y < b_y) {
					crossed = crossed && px < a_x;
				} else {
					crossed = crossed && px > a_x;
				}
			}
			return crossed;
		}
		
		/**
		 * line math
		 * @param	lx1
		 * @param	ly1
		 * @param	lx2
		 * @param	ly2
		 * @param	px
		 * @param	py
		 * @return
		 */
		public static function lineY(lx1:Number, ly1:Number, lx2: Number, ly2: Number, px: Number, py:Number):Number {
			if ((lx1 - lx2) == 0)
				if (lx1 == px) return px
				else return NaN;

			var m:Number = (ly2 - ly1 ) / (lx2 - lx1); // what if there are negatives?
			return m * px +    // m * x +
				ly1 - m * lx1; // b
		}

		
	}

}