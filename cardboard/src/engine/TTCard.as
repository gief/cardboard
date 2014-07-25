package engine 	
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import mx.core.FlexGlobals;
	import flash.display.Shape;
	import mx.core.FlexTextField;
	import flash.display.GradientType;
	import mx.effects.Rotate;
	import net.houen.cactuskev.CactusArrays;
	

	/**
	 * A card element. This has been used to represent playing cards, player token (e.g. red dealer chip), and chips with monetary value.
	 * 
	 * @author Gifford Cheung
	 */
	public class TTCard extends Sprite
	{
		public var selectionIndicator:Shape;
		
		public var posX:int; // mouse position during a drag
		public var posY:int;
		
		public var relativeX:int; // for dragging multiple cards
		public var relativeY:int;
		
		public var w:int;// = 50;
		public var halfw:int;// = 25;
		public var h:int;// = 70;
		public var halfh:int;// = 35;
		public var origin:Point;

		public var card_id:int;
		
		public var face:Sprite = new Sprite;
		public var face_up:Boolean = true;
		public var front:String;
		public var back:String;
		public var data:String;
		public var decor:Object;
		public var dragging_face:TTCard; // picture of dragged car that floats around....
		public var isDraggingFace:Boolean = false; //sorry for the confusion, a TTCard can have a TTCard that contains similar information but is used just to draw the card a little differently for dragging
		static public var tt:TT = FlexGlobals.topLevelApplication.tt;
		public var cactusKevEncoding:uint; // this is not transmitted, it is used to calculate the poker value of a card using the cactusKev library
		
		public var area:TTArea; // owning area
		
		public var isChip:Boolean = false; // for chips
		
		/**
		 * Is this a cash chip? Determined by whether or not this.data is a Number
		 * @return <code>true</code> if a cash chip, <code>false</code> otherwise.
		 */
		public function isCashChip():Boolean { 
			return isChip && 
				!isNaN(parseInt(data)); 
		} 
		public var chipColor:uint; // for chips
		
		public var lights:Shape;
		
		public function TTCard( _front:String = "AS",	_back:String = "", card_id:int = 0, dragging_face:Boolean = false, isChip:Boolean = false, w:int = 50, h:int = 70 )
		{	
			this.isChip = isChip;
			this.isDraggingFace = dragging_face;
			this.w = w;
			this.halfw = Math.round(w / 2);
			this.h = h;
			this.halfh = Math.round(h / 2);
			
			if (isDraggingFace) {
				this.buttonMode = true;
				this.mouseChildren = false;
				this.useHandCursor = true;	
			} else {
				face.x = 0 - halfw;
				face.y = 0 - halfh;
				addChild(face);
				
				this.front = _front;
				this.back = _back;
				this.card_id = card_id;
							
				this.doubleClickEnabled = true;
				
				this.buttonMode = true;
				this.mouseChildren = false;
				this.useHandCursor = true;
				this.enableListeners();
			}
			//origin
			if (isChip) {
				origin = new Point(0, 0);
			} else {
				origin = new Point( -halfw, -halfh);
			}
			
			if (!isChip) {
				calculateCactusKev();
			}

		}
		
		/**
		 * TTCard listens for double click, mousedown, and mouseup 
		 */
		public function enableListeners():void {
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);	
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);	
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);	
		}
		
		/**
		 * Disable listeners
		 */
		public function disableListeners():void {
			this.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);	
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);	
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);			
		}
		
		/**
		 * Calculate the Cactus Kev pokerhand value of this card.
		 */
		public function calculateCactusKev():void {
			var rank:int;
			switch (front.substr(0, 1)) {
				case "A":
					rank = 12;
					break;
				case "2":
					rank = 0;
					break;
				case "3":
					rank = 1;
					break;
				case "4":
					rank = 2;
					break;
				case "5":
					rank = 3;
					break;
				case "6":
					rank = 4;
					break;
				case "7":
					rank = 5;
					break;
				case "8":
					rank = 6;
					break;
				case "9":
					rank = 7;
					break;
				case "T":
					rank = 8;
					break;
				case "J":
					rank = 9;
					break;
				case "Q":
					rank = 10;
					break;
				case "K":
					rank = 11;
					break;
			}
			var suit:int;
			switch (front.substr(1, 1)) {
				case "C":
					suit = 0x8000;
					break;
				case "D":
					suit = 0x4000;
					break;
				case "H":
					suit = 0x2000;
					break;
				case "S":
					suit = 0x1000;
					break;
			}
			cactusKevEncoding = CactusArrays.primes[rank] | (rank << 8) | suit | (1 << (16 + rank));
			
		}
		
		/**
		 * Initialize a card that was generated from a snapshot
		 */
		public function initCardAfterSnapshot():void {
			if (isChip) {
				this.face.x = 0;// - Math.round(this.w / 2);
				this.face.y = 0;// - Math.round(this.h / 2);
				origin = new Point(0, 0);
			} else {
				origin = new Point( -halfw, -halfh);
				calculateCactusKev();
			}
		}
		
		/**
		 * Create a TTCard that can be used to drag this card around.
		 * @param	c - source TTCard
		 * @return TTCard for dragging around
		 */
		public static function newDraggingFace(c:TTCard):TTCard {
			var d:TTCard = new TTCard(c.front, c.back, c.card_id);
			d.isDraggingFace = true;
			d.w = c.w;
			d.halfw = c.halfw;
			d.h = c.h;
			d.halfh = c.halfh;
			d.origin = new Point(0, 0);
			d.area = c.area;
			return d;
		}
		
		/**
		 * Create a TTCard for a cash chip for dragging around. The difference between this as newDraggingFace is that the origin point has different values.
		 * @param	c
		 * @return TTCard chip for dragging
		 */
		public static function newChipDraggingFace(c:TTCard):TTCard {
			var chip:TTCard = new TTCard(c.front, c.back, c.card_id);
			chip.isDraggingFace = true;
			chip.isChip = true;
			chip.w = c.w;
			chip.halfw = c.halfw;
			chip.h = c.h;
			chip.halfh = c.halfh;
			chip.face.x = -chip.halfw;
			chip.face.y = -chip.halfh;
			chip.chipColor = c.chipColor;
			chip.origin = new Point(c.halfw, c.halfh); 
			chip.area = c.area;
			return chip;
		}

		/**
		 * Draw the sprite for this card. This is sensitive to the viewing rights of the containing area.
		 * @param	sprite - what sprite to draw on
		 * @param	offx - x offset for drawing the sprite
		 * @param	offy - y offset for drawing the sprite
		 */
		public function drawFace(sprite:Sprite, offx:int = 0, offy:int = 0):void {
			sprite.graphics.clear();
			sprite.graphics.lineStyle(1.0, 0x000000, 1.0);	
			// debug by drawing a square around the sprite itself.
			//sprite.graphics.drawRect(0, 0, w, h);
			if (this.isChip) {
				sprite.graphics.lineStyle(2);
				sprite.graphics.beginFill(chipColor);
				//sprite.graphics.drawRect(0+offx , 0+offy , w - 1, h - 1);
				sprite.graphics.drawCircle(0+this.halfw+offx , 0+this.halfh+offy, this.halfh-1);
				return;
			}
			
			if ( this.area.canView(tt.myself_id) || 
				//this.area.owner_id == 
				//tt.myself_id || 
				this.area.owner_id == "-1") {
				// I have viewing rights!
				if (this.face_up) {
					TTCardImages.drawCard("CARD_" + this.front, sprite, this.w, this.h, offx, offy);
				} else {
					sprite.graphics.beginGradientFill(GradientType.LINEAR, 
										[0xFFFFFF, 0x000055], 
										[100, 100], 
										[0, 0xFF]);
					sprite.graphics.drawRect(0 + offx , 0 + offy , w - 1, h - 1);
				}
			} else {
				// I have no viewing rights!!!
				if (this.face_up) {
					sprite.graphics.lineStyle(1, 0xDDDDDD);
					sprite.graphics.beginGradientFill(GradientType.LINEAR, 
										[0xFFFFFF, 0x000000], 
										[100, 100], 
										[127, 255]);
					sprite.graphics.drawRect(0+offx , 0+offy , w - 1, h - 1);
				} else {
					sprite.graphics.beginGradientFill(GradientType.LINEAR, 
										[0xFFFFFF, 	0x000055], 
										[100, 100], 
										[0, 0xFF]);
					sprite.graphics.drawRect(0+offx , 0+offy , w - 1, h - 1);
				}
			}			
		}		
		
		/**
		 * Fired by double click event. Will flip the card.
		 * @param	evt
		 */
		private function onDoubleClick(evt:MouseEvent):void {
			tt.selectedCards.readyToDrag = false;
			tt.selectedCards.isDragging = false;
			this.flip();
			this.sendFlip();
		}
		
		/**
		 * Flip this card. Triggers Flipped Card Listeners
		 */
		public function flip():void {
			// do it
			this.face_up = !this.face_up;

			drawFace(this.face);
			
			triggerFlippedCardListeners(this);
		}
		
		/**
		 * Mouse down. For selecting cards.
		 * @param	evt
		 */
		private function onMouseDown(evt:MouseEvent):void {
			//trace("Card.downM [[" + front + "]]" + evt.toString());
			evt.stopPropagation();
			// LATER a special option for Ctrl-MouseDown or Shift-MouseDown
			
			if (TT.ctrlDown) { 
				// Ctrl Key was Down, don't resetSelection
			} else {
				if (tt.selectedCards.cards.indexOf(this) == -1) {
					tt.selectedCards.resetSelection();
				}
			}
			
			tt.selectedCards.readyToDrag = true;
			this.showSelected();
			tt.selectedCards.addCard(this);
			tt.selectedCards.onMouseDown(evt);
		}
		
		/**
		 * Mouse up: For deselecting cards.
		 * @param	evt
		 */
		private function onMouseUp(evt:MouseEvent):void {
			if (!tt.selectedCards.wasDragged && 
				 (tt.selectedCards.justAddedAMomentAgo == null ||
				tt.selectedCards.justAddedAMomentAgo.card_id != card_id)) {
				tt.selectedCards.removeCard(this);
				this.hideSelected();
			}
			tt.selectedCards.justAddedAMomentAgo = null;
		}
		
		/**
		 * Move to dragged face is for moving a card to a new location after it has been dragged to a new area and a new x,y position. These new 
		 * positions need to be determined and an animation needs to be queued up. Unless the animate parameter is false
		 * @param	animate <code>false</code> if no animation.
		 */
		public function moveToDraggedFace(animate:Boolean = true):void {
			var last_x:int = this.x; 
			var last_y:int = this.y;
			var last_area:TTArea = this.area; // unused so far?
			//last_rotation = this.rotation; // unlikely to happen here?
			var new_x:int; // = area.mouseX - this.posX;
			var new_y:int; // = area.mouseY - this.posY;
			var new_area_id:int = last_area.area_id;
			
			// use dragging_face as a reference
			new_area_id = dragging_face.area != null ? dragging_face.area.area_id : new_area_id;
			var new_p:Point = dragging_face.parent.globalToLocal(dragging_face.localToGlobal(new Point(
							halfw, halfh)));
			new_x = new_p.x;
			new_y = new_p.y;
			
			// disable the card until move is processed
			this.mouseEnabled = false; 
				
			// start the animation for the local.
			var a:TTArea = dragging_face.area; //(dragging_face.parent as TTArea);
			enqueueAndSendMove(a, new_x, new_y, /*animate=*/animate, /*quiet=*/false, /*processit=*/true);
		}
		
		/**
		 * Send move and enqueue. This helper function pairs the Card Mover enqueue with a sendmove command. These are almost always used together.
		 * @param	new_area
		 * @param	new_x
		 * @param	new_y
		 * @param	quiet
		 */
		public function enqueueAndSendMove(new_area:TTArea, new_x:int, new_y:int, animate:Boolean, quiet:Boolean, processit:Boolean):void {
			var gp:Point = new_area.localToGlobal(	new Point(new_x, new_y));
			var op:Point = this.area.localToGlobal( new Point(this.x, this.y));
			
			TTCardMover.enqueue(
						this, 
						this.area.area_id, op.x, op.y, (this.rotation + this.area.rotation) % 360, 
						new_area.area_id, gp.x, gp.y, new_area.rotation + this.rotation,
						true, true, animate, quiet, processit);
			this.sendMove(this.area.area_id, this.x, this.y, new_area.area_id, new_x, new_y, quiet);
		}
		
		/**
		 * Send a MOVECARD message to the network. 
		 * @param	old_area_id
		 * @param	old_x
		 * @param	old_y
		 * @param	new_area_id
		 * @param	new_x
		 * @param	new_y
		 * @param	quiet - see CardMover
		 */
		public function sendMove(old_area_id:int, old_x:int, old_y:int, new_area_id:int, new_x:int, new_y:int, quiet:Boolean = false):void {
			var message:Object = new Object();
			message.action = "MOVECARD";
			message.person_id = tt.myself_id;
			message.game_id = tt.game_id;
			message.card_id = this.card_id;
			message.area_id_orig = old_area_id;
			message.x_orig = old_x;
			message.y_orig = old_y;
			message.area_id_dest = new_area_id;
			message.x_dest = new_x;
			message.y_dest = new_y;
			message.quiet = quiet;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();

			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
		}
		

		/**
		 * process a MOVECARD message from the network
		 * @param	new_x
		 * @param	new_y
		 * @param	area_id
		 * @param	myself
		 * @param	quiet
		 */
		public function processMovedCard(new_x:int, new_y:int, area_id:int = -1, myself:Boolean = true, quiet:Boolean = false):void {
			var origin:Point = new Point(this.x, this.y);
			var original_area: TTArea = this.area;//tt.getArea(this.area.area_id);

			if (area_id != -1) {
				var a:TTArea = tt.getArea(area_id);
				if (a) {
					this.area.removeCard(this);
					this.area = a;
				}
			}
			
			if (myself && this.dragging_face) this.dragging_face.visible = false; 
			
			this.x = new_x; // if the card container is the mover this is not necessary?
			this.y = new_y;
			this.area.bringToFront(); // do we need this? yes, but somewhere else? on mouse up?
			drawFace(this.face);
			this.alpha = 1;
			// reenable the card until move is processed
			this.mouseEnabled = true;
			this.area.addChild(this);
			this.area.addCard(this);

			if (!quiet) {
				//trace("triggered");
				triggerMovedCardListeners(this, origin, original_area);
			}
		}
		
		/**
		 * For every listener for a moved card, trigger the event. E.g. components in TTComponentManager that are watching cards.
		 * @param	moved_card
		 * @param	origin
		 * @param	original_area
		 */
		public function triggerMovedCardListeners(moved_card:TTCard, origin:Point, original_area:TTArea):void {
			for each (var component_manager:TTComponentManager in tt.game_components) {
				for each (var component:Object in component_manager.components) {
					//TTSideConsole.write( String(component_manager.components.length));
					if (component.movedCardListener) {
						component.movedCardListener(moved_card, origin, original_area);
						//TTSideConsole.write(component.owner_id + "\n");
						//TTSideConsole.write("[[[");
					}
				}
			}	
		}
		
		/**
		 * For every listener of a flipped card, trigger the event. E.g. components in the TTComponentManager 
		 * @param	flipped_card
		 */
		public function triggerFlippedCardListeners(flipped_card:TTCard):void {
			// No quiet mode implemented because we do not have
			// any automatic processess that will trigger a card flip (e.g. If TTCommunityZone decided
			// to flip a card because another card was flipped.)
			for each (var component_manager:TTComponentManager in tt.game_components) {
				for each (var component:Object in component_manager.components) {
					if (component.flippedCardListener) {
						component.flippedCardListener(flipped_card);
					}
				}
			}
		}
		
		/**
		 * Send a ROTATECARD message to the network
		 * @param	old_rotation
		 * @param	new_rotation
		 */
		public function sendRotate(old_rotation:int, new_rotation:int):void {
			var message:Object = new Object();
			message.action = "ROTATECARD";
			message.person_id = tt.myself_id;
			message.game_id = tt.game_id;
			message.area_id = this.area.area_id;
			message.card_id = this.card_id;
			message.old_rotation = old_rotation;
			message.new_rotation = new_rotation;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
		}
		
		/**
		 * Process a ROTATECARD message
		 * @param	new_rotation
		 */
		public function processRotatedCard(new_rotation:int):void {
			this.rotation = new_rotation;
		}
		
		/**
		 * Collision detection, card.
		 * @param	card
		 * @return
		 */
		public function collidesWith(card:TTCard):Boolean {
			var a:Point = this.localToGlobal(new Point(0, 0));
			var b:Point = this.localToGlobal(new Point(this.w, 0));
			var c:Point = this.localToGlobal(new Point(0, this.h));
			var d:Point = this.localToGlobal(new Point(this.w, this.h));
			
			var card_a:Point = card.localToGlobal(new Point(0, 0));
			var card_b:Point = card.localToGlobal(new Point(card.w, 0));
			var card_c:Point = card.localToGlobal(new Point(0, card.h));
			var card_d:Point = card.localToGlobal(new Point(card.w, card.h));
			
			// a-b
			// | |
			// c-d
			var collide:Boolean = false;

			collide = collide || card.pointInside(a);
			collide = collide || card.pointInside(b);
			collide = collide || card.pointInside(c);
			collide = collide || card.pointInside(d);
			collide = collide || this.pointInside(card_a);
			collide = collide || this.pointInside(card_b);
			collide = collide || this.pointInside(card_c);
			collide = collide || this.pointInside(card_d);
			
			return collide;
		}
		
		/**
		 * Collision detection: point (convex only)
		 * @param	p
		 * @return
		 */
		public function pointInside(p:Point):Boolean {
			var a:Point = this.localToGlobal(new Point(0, 0));
			var b:Point = this.localToGlobal(new Point(this.w, 0));
			var c:Point = this.localToGlobal(new Point(0, this.h));
			var d:Point = this.localToGlobal(new Point(this.w, this.h));
			var collide:Boolean = true;
			
			collide = collide && TTMath.lineCross(a.x, a.y, b.x, b.y, p.x, p.y);
			collide = collide && TTMath.lineCross(b.x, b.y, d.x, d.y, p.x, p.y);
			collide = collide && TTMath.lineCross(d.x, d.y, c.x, c.y, p.x, p.y);
			collide = collide && TTMath.lineCross(c.x, c.y, a.x, a.y, p.x, p.y);
			return collide;
		}
		
		public function sendFlip():void {
			// communicate it's done-ness
			// this need to change to a new status rather than a toggle
			var message:Object = new Object();
			message.card_id = this.card_id;
			message.action = "FLIPCARD";
			message.game_id = tt.game_id;
			message.area_id = this.area.area_id;
			message.person_id = tt.myself_id; 
			var now:Date = new Date();
			message.timestamp = "" + Math.floor((new Date()).valueOf() / 1000);
			
			//tt.comm.xPoll(new Array(message));// XMPP
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);
		}
		
		/**
		 * Create the dragging face
		 */
		public function initiateDraggingFace():void {
			
			if (dragging_face == null) {
				if (this.isChip) {
					dragging_face = newChipDraggingFace(this);
				} else {
					dragging_face = newDraggingFace(this);
				}
			}
			
			if (!isChip) {
				drawFace(this.dragging_face);
			} else {
				// it's a chip. notice we are off by halfw halfh
				drawFace(this.dragging_face, halfw, halfh);
			}
			
			/* DRAW THE dragtext */
			if (decor != null && decor.dragtext != null && decor.dragtext != "") {
				if (decor.dragtextsprite == null) {
					//TTSideConsole.write(".");
					var tx_container:Sprite = new Sprite;
					var tx:TextField = new TextField();
					tx.embedFonts = true;
					tx.defaultTextFormat = tt.global_text_format; //global
					tx.defaultTextFormat.align = "center"
					tx.antiAliasType = "advanced";
					tx.filters = [new GlowFilter(0x000000, 1, 4, 4, 4)];	
					tx_container.addChild(tx);
					decor.dragtextsprite = tx;
					decor.dragtextsprite_container = tx_container;
					
					tx.x -= Math.round(tx.width / 4);
					tx.y -= Math.round(tx.height / 4);
					tx_container.x += Math.round(tx.width / 2);
					tx_container.y += Math.round(tx.width / 2);

				}
				
				decor.dragtextsprite_container.rotation = 360 - tt.rotation;
				dragging_face.removeChildren(); // removes ALL of dragging_face's children.
				decor.dragtextsprite.text = decor.dragtext;
				decor.dragtextsprite.textColor = decor.dragcolor;
				this.dragging_face.addChild(decor.dragtextsprite_container);

			
			}
			/* end DRAW THE dragtext */
			
			dragging_face.visible = true;
			dragging_face.rotation = this.rotation;
			var new_p:Point = this.localToGlobal(new Point(0-halfw,0-halfh));
			new_p = this.area.globalToLocal(new_p);
			dragging_face.x = new_p.x;
			dragging_face.y = new_p.y;
			
			this.area.addChild(dragging_face);
		}
		
		/**
		 * Update the sprite for the dragging face, attending to collisions with new areas
		 * @param	isDraggingOne
		 */
		public function updateDraggingFace(isDraggingOne:Boolean):void {
			if (tt.selectedCards.isDragging) {
				var new_p:Point; 
				
				//check for collision with a new area
				var card_updated:Boolean = false;
				//var mid_p:Point = dragging_face.localToGlobal(new Point(halfw, halfh));	
				for (var i:int = 0; i < tt.areas.length ; i += 1 ) {
					var a:TTArea = tt.areas[i];
					if ( a.collidesWith(this.stage.mouseX, this.stage.mouseY) 
						 && (isDraggingOne || a.area_id != dragging_face.area.area_id )) {		
						card_updated = true;
						//a.addChild(dragging_face);
						a.bringToFront();
						/*DRAGTEXTSPECIALTY*/
						if (decor != null && decor.dragtextsprite != null) {
							if (a.owner_id == "-1") {
								decor.dragtextsprite.visible = true; 
							} else {
								decor.dragtextsprite.visible = false;
							}
						}
						
						
						
						new_p = dragging_face.localToGlobal(new Point(dragging_face.mouseX -halfw - posX, 
																	dragging_face.mouseY -halfh - posY));
						
						new_p = a.globalToLocal(new_p);
						dragging_face.x = new_p.x;
						dragging_face.y = new_p.y;
						
						if (dragging_face.x < 2 - dragging_face.origin.x) dragging_face.x = 2 - dragging_face.origin.x;
						if (dragging_face.y < 2 - dragging_face.origin.y) dragging_face.y = 2 - dragging_face.origin.y;
						if (dragging_face.x + dragging_face.w + dragging_face.origin.x > a.w - 2) dragging_face.x = a.w - dragging_face.w - 2 - dragging_face.origin.x;
						if (dragging_face.y + dragging_face.h + dragging_face.origin.y > a.h - 2) dragging_face.y = a.h - dragging_face.h - 2 - dragging_face.origin.y;

						dragging_face.area = a;
						a.addAreaCardsInOrderAnd(dragging_face); 
						
						
						break; // you've now changed things, time to stop shifting things around?
					}
				}
				if (!card_updated) { 
					new_p = dragging_face.localToGlobal(new Point(dragging_face.mouseX - halfw - posX, 
																  dragging_face.mouseY - halfh - posY));	
					new_p = dragging_face.parent.globalToLocal(new_p);

					if (new_p.x + dragging_face.origin.x < 2) {
						new_p.x = 2 - dragging_face.origin.x;
					} else if (new_p.x + dragging_face.origin.x + this.w > dragging_face.area.w - 2) {
						new_p.x = dragging_face.area.w - this.w -2 - dragging_face.origin.x;
					}

					if (new_p.y + dragging_face.origin.y < 2) {
						new_p.y = 2 - dragging_face.origin.y;
					} else if (new_p.y + dragging_face.origin.y + this.h > dragging_face.area.h - 2) {
						new_p.y = dragging_face.area.h - this.h -2 - dragging_face.origin.y;					
					} 
					dragging_face.x = new_p.x;
					dragging_face.y = new_p.y;
				}

				
			} else {
				this.dragging_face.visible = false;
			}
		}
		
		/**
		 * Draw a visual indicator of a card being selected (e.g. a blue box around the card)
		 */
		public function showSelected():void
		{
			// DRAWING STUFF
		    if (this.selectionIndicator == null)
		    {
		        // draws a rectangle around the selected shape
		        this.selectionIndicator = new Shape();
		        this.selectionIndicator.graphics.lineStyle(6.0, 0xaaaaff);
			    this.selectionIndicator.graphics.drawRect(0, 0, this.w - 1, this.h - 1);
				if (!this.isChip) {
					selectionIndicator.x = 0 - halfw;
					selectionIndicator.y = 0 - halfh;
				}
			    this.addChild(this.selectionIndicator);
		    }
		    else
		    {
		        this.selectionIndicator.visible = true;
		    }
		}
		
		/**
		 * Hide the indicator of a selection
		 */
		public function hideSelected():void
		{
		    if (this.selectionIndicator != null)
		    {		    
		        this.selectionIndicator.visible = false;
		    }
		}
		
		
		/**
		 * Instruct everyone to load new cards into the game.
		 * @param	json_card_array - Array - a json array comprised of card objects
		 */
		public static function sendLoadCardsMessage(cards:Array):void {
			var message:Object = new Object();
			message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
			message.action = "LOADCARDS";
			message.cards = cards;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.send(message);
		}
		
		/**
		 * Send a CARDDECOR message to the network 
		 * @param	d - the decor string
		 */
		public function sendCardDecor(d:String):void {
			var message:Object = new Object();
			message.action = "CARDDECOR";
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();

			message.area_id = this.area.area_id;
			message.card_id = this.card_id;
			message.carddecor = d;
			
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
			
		}
		
		/**
		 * Process a CARDDECOR message, setting the text to be m.carddecor
		 * @param	m
		 */
		public function processCardDecor(m:Object):void {
			// we expect carddecor to be temporary so we don't save it anywhere.
			// this needs to be generalized in the future TODO
			
			if (decor == null) decor = new Object();
			this.decor.dragtext = (JSON.parse(m.carddecor) as Object).dragtext;
			this.decor.dragcolor = (JSON.parse(m.carddecor) as Object).dragcolor;
			
			// the decor will show up during the dragging phase
		}
		
		/**
		 * Write the decor text on the card
		 * @param	text
		 * @param	color
		 */
		public function setDragDecorText(text:String, color:Number):void {
			this.sendCardDecor(JSON.stringify( { dragtext:text, dragcolor:color } ));
		}
	}
}