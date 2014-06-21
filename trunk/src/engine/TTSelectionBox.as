package engine 
{
	/**
	 * Selection box for drag selecting multiple TTCards
	 * @author Gifford Cheung
	 */
	import flash.geom.Point;
	import flash.text.TextField;
	import mx.core.UIComponent;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	 
	public class TTSelectionBox extends UIComponent
	{
		public var w:int = 0;
		public var h:int = 0;
		public var init:Boolean = false;
		
		public function TTSelectionBox() 
		{
		}
		
		/**
		 * Draw the box
		 */
		public function draw():void {
			this.graphics.clear();
			this.graphics.lineStyle(1.0, 0xFFFFFF, 1.0);
			this.graphics.drawRect(0, 0, this.w, this.h);
			if (FlexGlobals.topLevelApplication.tt.getChildIndex(this) != FlexGlobals.topLevelApplication.tt.numChildren -1) {
				FlexGlobals.topLevelApplication.tt.addChild(this);
			}
		}
		
		/**
		 * Collision detection: has a box been drawn around a card.
		 * @param	card
		 * @return
		 */
		public function hits(card:TTCard):Boolean {
			//var midw:Number = Math.round(card.w / 2);
			//var midh:Number = Math.round(card.h / 2);
			
			// card origin
			// card ending
			
			var p1:Point = card.localToGlobal(new Point(card.origin.x, card.origin.y));
			var p2:Point = card.localToGlobal(new Point(card.origin.x, card.origin.y+card.h));
			var p3:Point = card.localToGlobal(new Point(card.origin.y + card.w, card.origin.y));
			var p4:Point = card.localToGlobal(new Point(card.origin.y + card.w, card.origin.y + card.h));
			
			return this.hitTestPoint(p1.x, p1.y) 
				   && this.hitTestPoint(p2.x, p2.y) 
				   && this.hitTestPoint(p3.x, p3.y)
				   && this.hitTestPoint(p4.x, p4.y)
				   ;
		}
	}

}