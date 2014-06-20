package engine 
{
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import mx.core.FlexGlobals;
	import mx.core.FlexTextField;
		
	/**
	 * Keeps track of the currently selected TTCard.
	 * This is a static class, so there can only be one set of 
	 * selected cards at any given time. 
	 * @author Gifford Cheung
	 **/
	
	public class TTCardContainer extends Sprite
	{
		public var cards:Array = new Array();
		public var readyToDrag:Boolean = false;
		public var isDragging:Boolean = false;
		public var wasDragged:Boolean = false;
		public var justAddedAMomentAgo:TTCard;
		
		public static var FLIP_DOWN:int = 1;
		public static var FLIP_UP:int = 2;
		
		public function TTCardContainer() 
		{
			super();
		}
		
		/**
		 * Remove noncash chips from the current selection. 
		 * @param	andHideSelected if <code>true</code> remove the selection indicator for the filtered items
		 */
		public function filterContainerRemoveNonCashChips(andHideSelected:Boolean = false):void {
			// TODO a more general version of this function, someday in the future
			for (var i:int = 0 ; i < cards.length; i += 1) {
				if (!cards[i].isCashChip()) {
					if (andHideSelected) { (cards[i] as TTCard).hideSelected(); }
					cards.splice(i, 1);
					i -= 1;
				}
			}
		}
		/**
		 * Remove noncards from the current selection
		 * @param	andHideslected if <code>true</code> remove the selection indicator for the filtered items
		 */
		public function filterContainerRemoveNonCards(andHideSelected:Boolean = false):void {
			for (var i:int = 0; i < cards.length; i += 1) {
				if (cards[i].isChip) {
					if (andHideSelected) { (cards[i] as TTCard).hideSelected(); }
					cards.splice(i, 1);
					i -= 1;
				}
			}
		}
		
		/**
		 * mouse down: assign posX and posY, the relative position of the mouse cursor to the card. For use when dragging a card around
		 * @param	evt
		 */
		public function onMouseDown(evt:MouseEvent):void {
			for each (var c:TTCard in cards) {
				c.posX = c.mouseX;
				c.posY = c.mouseY;
			}
		}
		
		/**
		 * mouse up: means we have finished dragging and should move the cards to the new location. 
		 * Note that the yellow chip is moved last because it triggers special activities for component manager
		 * @param	evt
		 */
		public function onMouseUp(evt:MouseEvent):void {
			var animationThreshold:uint = 25; // this is a different style of threshold than in stackSelected...
			var animate:Boolean;
			var animatedOnce:Boolean = false;
			if (isDragging) {
				// I want to move the yellow chip last: always
				var yellowchip:TTCard = null;
				for each (var c:TTCard in cards) {
					animate = animationThreshold > cards.length;
					
					if (c.data == "current") {
						yellowchip = c;
					} else {
						c.drawFace(c.face);
						c.visible = true;
						c.dragging_face.visible = false;
						c.moveToDraggedFace(true/*!animatedOnce || animate*/);
						animatedOnce = true;
					}
				}
				if (yellowchip) {
					yellowchip.moveToDraggedFace(true /*always animate the yellow chip*/);
					yellowchip.drawFace(yellowchip.face);
					yellowchip.visible = true;
					yellowchip.dragging_face.visible = false;
				}
				//resetSelection();
			}
			
			readyToDrag = false;
			isDragging = false;
			wasDragged = false;
		}
		
		/**
		 * Flip selected cards
		 */
		public function flipCards():void {
			if (cards.length <= 0) return;
			for each (var c:TTCard in cards) {
				c.flip();
				c.sendFlip();
			}
		}
		
		/**
		 * Flip selected cards up
		 */
		public function flipUp():void {
			for each (var c:TTCard in cards) {
				if (!c.face_up) {
					c.flip();
					c.sendFlip();
				}
			}
		}
		
		/**
		 * Flip selected cards down
		 */
		public function flipDown():void {
			for each (var c:TTCard in cards) {
				if (c.face_up) {
					c.flip();
					c.sendFlip();
				}
			}			
		}
		
		/**
		 * Rotate selected cards
		 */
		public function rotateCards():void {
			if (cards.length <= 0) return;
			for each (var c:TTCard in cards) {
				var new_rotation:int = c.rotation + 45 - c.rotation % 45;
				c.processRotatedCard(new_rotation);
				c.rotation = new_rotation;
				c.sendRotate(c.rotation, new_rotation);
			}
		}

		/**
		 * Shuffle selected cards
		 */
		public function shuffle():void {
			var len:int = cards.length;
			var arr2:Array = new Array(len);
			for(var i:int = 0; i<len; i++)
			{
				arr2[i] = cards.splice(int(Math.random() * (len - i)), 1)[0];
			}
			
			cards = arr2;		
		}
		
		/**
		 * Stack selected cards according to the parameters
		 * @param	global_stackspot - where to stack the cards
		 * @param	dx - distance in X between each card
		 * @param	dy - distance in Y between each card
		 * @param	jitter - randomness to apply to the dx and dy for a more organic look
		 * @param	skipsort - if <code>true</code> then use the order of the array to stack the cards. Otherwise, the cards will be ordered according to their original x,y positions. This allows players to control the sort of the cards after they are stacked.
		 * @param	flip - flip the cards FLIP_UP or FLIP_DOWN
		 * @param	quiet - quiet sendmove or not
		 * @param	loopOnLast - if value greater than 0, then make stacks of size <code>loopOnLast</code>
		 */
		public function stackSelected(global_stackspot:Point, dx:int, dy:int, jitter:int = 0, skipsort:Boolean = false, flip:int = 0, quiet:Boolean = false, loopOnLast:int = 0):void {
			if (cards.length <= 0) return;

			var a:TTArea = FlexGlobals.topLevelApplication.tt.areas[0] as TTArea;
			
			//stack in what area?
			for each (var _a:TTArea in FlexGlobals.topLevelApplication.tt.areas) {
				if (_a.collidesWith(global_stackspot.x, global_stackspot.y)) {
					a = _a;
					break;
				}
			}
			if (!a) a = FlexGlobals.topLevelApplication.tt.areas[0] as TTArea;
			
			global_stackspot.x -= cards[0].origin.x;
			global_stackspot.y -= cards[0].origin.y;
			
			var local_stackspot:Point = a.globalToLocal(global_stackspot);
			var original_local_stackspot:Point = a.globalToLocal(global_stackspot);
			if (!skipsort) cards.sortOn(["x", "y"], Array.NUMERIC);
			var i:int = 0;
			var new_stackspot:Point;
			var origin:Point;
			var original_area:TTArea;
			var keepAnimating: Boolean = true;
			var animationThreshold:int = 25;
			for each (var c:TTCard in cards) {
				animationThreshold -= 1;
				keepAnimating = animationThreshold > 0;
				// reassign the stackspot location within the borders of the area.
				new_stackspot = a.borderedPoint(local_stackspot, c, i);
				
				if (flip) {
					if (flip == FLIP_DOWN && c.face_up) {
						// DOWN
						c.flip();
						c.sendFlip();
					} 
					if (flip == FLIP_UP && !c.face_up) {
						// UP
						c.flip();
						c.sendFlip();
					}
				}
				
				c.enqueueAndSendMove(a, new_stackspot.x, new_stackspot.y, true/*keepAnimating*/, false, true);
				
				local_stackspot.x += dx;
				local_stackspot.y += dy;
				if (jitter) {
					if (dy > 0) local_stackspot.x += Math.random()*jitter;
					if (dx > 0) local_stackspot.y += Math.random()*jitter;					
				}
				
				i += 1;
				
				if (loopOnLast > 0 && i % loopOnLast == 0) {
					if (dx > dy) {
						local_stackspot.y += c.w;
						local_stackspot.x = original_local_stackspot.x;
					} else {
						local_stackspot.x += c.h;
						local_stackspot.y = original_local_stackspot.y;
					}
				}
			}
		}
		
		public var c:TTCard;
		public var isDraggingOne:Boolean;
		
		public function onMouseMove(evt:MouseEvent):void {
			if (cards.length > 0 && (readyToDrag || isDragging)) {
				/* var c:TTCard;
				var isDraggingOne:Boolean = cards.length == 1;
				*/
				isDraggingOne = cards.length == 1;
				
				if (readyToDrag) { // inital runnin'
					readyToDrag = false;
					isDragging = true;
					wasDragged = true;
					// dragging face
					// here, there should only be one dragging face?
					cards.sortOn(['isChip','x','y'], Array.NUMERIC);
					for each (c in cards) {
						c.initiateDraggingFace();
					}
				}
				// bring this area to the front???
				// assumes the moved card(s) are only in one area
				//cards[0].area.bringToFront();
				cards[0].stage.focus = cards[0].area;
				
				
				for each (c in cards) {
					c.dragging_face.alpha = 1;
					c.mouseEnabled = false; 
					c.alpha = 0.35;
					c.updateDraggingFace(isDraggingOne);
				}
			}
		}
				
		public function addCard(c:TTCard):void {
			if (cards.indexOf(c) == -1) {
				cards.push(c);
				justAddedAMomentAgo = c;
			}
		}
		
		public function resetSelection():void {
			for each (var c:TTCard in cards) {
				c.hideSelected();
			}
			cards = new Array();
		}
		
		public function removeCard(c:TTCard):void {
			var i:int = cards.indexOf(c);
			if (i != -1) 
				cards.splice(i, 1);
		}
	}

}