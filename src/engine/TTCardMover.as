package engine 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import mx.core.FlexGlobals;
	import flash.events.Event;
	import mx.core.UIComponent;
	/**
	 * Handles the moving animation of cards
	 * @author Gifford Cheung
	 */
	public class TTCardMover extends UIComponent 
	{
		public var concurrentMoveArrays:Array = new Array();
		public var calculatedMoveList:Array = new Array();
		public var currentMoveList:Array;
		public static var mover:TTCardMover;
		
		public function TTCardMover() 
		{
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Frame Handler for this class. Pops a move instruction off of the move_list and handles the move.
		 * @param	e
		 */
		private function enterFrameHandler(e:Event):void {
			var move:Object;
			var move_list:Array;

			for (var i:int = 0; i < concurrentMoveArrays.length; i += 1) { // concurrentMoveArrays) {
			//for (var i:int = concurrentMoveArrays.length -1; i > -1;  i -= 1) { // concurrentMoveArrays) {
				move_list = concurrentMoveArrays[i];
				move = move_list.pop();
				if (move) {
					handleMove(move);
				} else {
					//garbage collection
					concurrentMoveArrays.splice(i, 1);
				}
			}
			
			if ((FlexGlobals.topLevelApplication.tt as TT).visual_effect_layer) {
				(FlexGlobals.topLevelApplication.tt as TT).visual_effect_layer.enterFrameHandler(e);
			}
			return;
		}
		
		
		internal var handleMove_movedcard:TTCard = null;
		internal var handleMove_newarea:TTArea = null;
		internal var handleMove_lp:Point = null;
		/**
		 * Given a <code>move</code> object, update the location of the drift_face (to appear/move/disappear) or 
		 * process to new location of the card after it has been moved.
		 * @param	move
		 */
		public function handleMove(move:Object):void {
			if (!move) return;
			if (move.appear) {
				this.addChild(move.drift_face);
				if (FlexGlobals.topLevelApplication.tt.getChildIndex(this) != FlexGlobals.topLevelApplication.tt.numChildren - 1) {
					FlexGlobals.topLevelApplication.tt.addChild(this);
				}
			}
			
			move.drift_face.x = move.x;
			move.drift_face.y = move.y;
			move.drift_face.rotation = move.r;
			
			
			if (move.disappear) {
				this.removeChild(move.drift_face);
				stage.focus = FlexGlobals.topLevelApplication.tt;
			}
			
			if (move.processMove) {
				handleMove_movedcard = FlexGlobals.topLevelApplication.tt.getCard(move.original_area_id, move.card_id);
				if (handleMove_movedcard) {
					handleMove_newarea = FlexGlobals.topLevelApplication.tt.getArea(move.dest_area_id);
					handleMove_lp = handleMove_newarea.globalToLocal(this.localToGlobal(new Point(move.x, move.y)));
					handleMove_movedcard.processMovedCard(handleMove_lp.x, handleMove_lp.y, move.dest_area_id, move.myself, move.quiet);
				} else {
					trace ("ERROR: Couldn't find card : " + move.card_id);
				}
			}
			return;	
		}
		
		/**
		 * Given a card and its new destination, construct a series of intermediate animation frames for the handleMove function
		 * to draw. Then add these in-between frames and the starting and ending instructions into 
		 * the move list.
		 * 
		 * @param	card the card to move
		 * @param	orig_area_id original area id
		 * @param	global_orig_x original x position global
		 * @param	global_orig_y original y position global
		 * @param	global_orig_r original rotation
		 * @param	dest_area_id destination area id
		 * @param	global_dest_x destination x position global
		 * @param	global_dest_y destination y position global
		 * @param	global_dest_r destination rotation 
		 * @param	myself - legacy code 
		 * @param	remote - legacy code
		 * @param	animate - Boolean: Should we animate the card moving from orig to dest?
		 * @param	quiet - Quiet toggle
		 * @param	processit - should this move be processed at the end of the animation?
		 */
		public static function enqueue(card:TTCard, orig_area_id:int, global_orig_x:int, global_orig_y:int, global_orig_r:int, 
								dest_area_id:int, global_dest_x:int, global_dest_y:int, global_dest_r:int, 
								myself:Boolean = true, remote:Boolean = false, animate: Boolean = true, quiet:Boolean= false, processit:Boolean = true):void {
			// concurrence!
			if (animate || mover.currentMoveList == null) {
				mover.currentMoveList = new Array();
				mover.concurrentMoveArrays.push(mover.currentMoveList);
			}
			//create a drift_face for the card
			var drift_face:Sprite = new Sprite();
			
			if (!card.isChip) { 
				//card
				card.drawFace(drift_face, -Math.round(card.w / 2), -Math.round(card.h / 2));
			} else {
				//chip
				card.drawFace(drift_face); //, -Math.round(card.w / 2), -Math.round(card.h / 2));
			}
			
			var lorig:Point = mover.globalToLocal(new Point(global_orig_x, global_orig_y));
			drift_face.x = lorig.x; // should this be this.globalToLocal??
			drift_face.y = lorig.y;
			//drift_face.rotation = card.rotation + card.area.rotation % 360;
			drift_face.rotation = global_orig_r;
			global_dest_r = global_dest_r % 360; // make it spinny by changing this to + 360 for fun
			var ldest:Point = mover.globalToLocal(new Point(global_dest_x, global_dest_y));
			
			//var inputArray:Array= new Array();
			var inputArray:Array = mover.currentMoveList;
			
			if (processit) {
				inputArray.unshift ({
										"drift_face":drift_face,
										"x": ldest.x,
										"y": ldest.y,
										"r": global_dest_r,
										"appear": false,
										"processMove": processit, // this is the final move
										"original_area_id": orig_area_id,
										"card_id": card.card_id,
										"dest_area_id": dest_area_id,
										"myself": myself,
										"quiet": quiet
										} );
			}
			var ydrop:int = 7; // for fancy animation of card dropping into place
			var ypick:int = 3; // for fancy animation of card lifting up before moving
			if (animate) {// && ((myself && !remote) || (!myself && remote))) {
				inputArray.push ({
								"drift_face":drift_face,
								"x": ldest.x,
								"y": ldest.y,
								"r": global_dest_r,
								"card_id": card.card_id,
								"disappear": true
								} );	
				
					
				for (var i:int = 0; i < ydrop ; i += 1) {
					inputArray.push ({
											"drift_face":drift_face,
											"card_id": card.card_id,
											"x": ldest.x,
											"y": ldest.y  - i,
											"r": global_dest_r,
											"appear": false,
											"processMove": false
											} );
				}

				var n:int = 10;
				var m:Number = (ldest.y -lorig.y) / (ldest.x - lorig.x);
				var b:Number = lorig.y - m * lorig.x;
				var x:int;
				var y:int;
				var r:int = global_dest_r;
			
				if (Math.abs(drift_face.x - ldest.x) > n/2) {
					x = ldest.x;
					y = ldest.y - ydrop;
					lorig.y -= ypick;
					for (i = 0; i < n; i += 1) {
						x -= Math.round((ldest.x - lorig.x) / n);
						y = Math.floor(m * x + b);
						r -= Math.round((global_dest_r - drift_face.rotation) / n);
						inputArray.push ({
							"drift_face":drift_face,
							"card_id": card.card_id,
							"x": x,
							"y": y,
							"r": r,
							"appear": false,
							"processMove": false
							} );
					}
				} else {
					y = ldest.y -ydrop;
					lorig.y -= ypick;
					for (i = 0; i < n; i += 1) {
						x = ldest.x;
						y -= Math.round((ldest.y - lorig.y) / n);
						r -= Math.round((global_dest_r - drift_face.rotation) / n);
						inputArray.push ({
							"drift_face":drift_face,
							"card_id": card.card_id,
							"x": x,
							"y": y,
							"r": r,
							"appear": false,
							"processMove": false
							} );
					}
				}
				
				for (i = 0; i < 3 ; i += 1) {
					inputArray.push ({
											"drift_face":drift_face,
											"x": drift_face.x,
											"y": drift_face.y - ypick + i,
											"r": drift_face.rotation,
											"card_id": card.card_id,
											"appear": false,
											"processMove": false
											} );
				}
				inputArray.push ({
						"drift_face":drift_face,
						"x": drift_face.x,
						"y": drift_face.y,
						"r": drift_face.rotation,
						"card_id": card.card_id,
						"appear": true,
						"processMove": false
						} );
				
			}
		}
		
	}

}