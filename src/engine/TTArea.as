package engine 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import mx.core.UIComponent;
	import flash.events.MouseEvent;
	import mx.controls.Alert;
	import flash.geom.Rectangle;
	import mx.core.FlexGlobals;
	import flash.events.KeyboardEvent
	import mx.utils.*;
	
	
	/**
	 * Areas hold card objects in a 2D space for players to see and manipulate. They can be public and private. They can be viewed by any number of users, but owned by only one user.
	 * @author Gifford Cheung
	 */
	public class TTArea extends UIComponent 
	{
		public var bounds:Rectangle;
		public var w:Number;
		public var h:Number;
		public var area_id:Number;
		public var owner_id:String = "-1"; // use -1 for no owner, public area
		public var viewers:Array = new Array(); // list of users who can view the cards in this private area;
		//public var cards:Array = new Array(); // cards.push(new TTCard());
		public var cards:Dictionary = new Dictionary(true);
		public var lights:Shape;
		public var upper_layer:Sprite = new Sprite();
		public var middle_layer:Sprite = new Sprite();
		public var lower_layer:Sprite = new Sprite();
		
		public function receive():Point { return Point.interpolate(new Point(0, 0), new Point(w, h), 0.5); }

		public function TTArea(_w:Number=700,_h:Number=400) {
		super();
				
		this.w = _w;
		this.h = _h;
		this.addChild(lower_layer);
		this.addChild(middle_layer);
		this.addChild(upper_layer);
		}
		
		/**
		 * Check if user can view and area.
		 * @param	user_id
		 * @return <code>true</code> if the user_id can view this area, <code>false</code> if no.
		 */
		public function canView(user_id:String):Boolean {
			return viewers.indexOf(user_id) != -1;
		}
		
		/**
		 * Adds a users to the permission list for viewing an area.
		 * @param	user_id
		 */
		public function addViewer(user_id:String):void {
			if (!canView(user_id)) {
				viewers.push(user_id);
				redrawAllCards();
			}
			
		}
		
		/**
		 * Get owner_id
		 * @param	
		 */
		public function getOwnerId():String {
			return owner_id
		}
	
		/**
		 * Assigns a new owner of an area
		 * @param	new_owner_id
		 */
		public function setOwnerId(new_owner_id:String):void {
			this.owner_id = new_owner_id;
			reRenderBackground();
		}
		
		/**
		 * Removes a user from the permission list for viewing an area.
		 * @param	user_id
		 */
		public function removeViewer(user_id:String):void {
			if (canView(user_id)) {
				viewers.splice(viewers.indexOf(user_id), 1);
				redrawAllCards();
			}
		}
		
		/**
		 * redraw all the cards in an area
		 */
		public function redrawAllCards():void {
			for each (var card:TTCard in cards) {
				card.drawFace(card.face);
			}
		}
		
		/**
		 * Make a public announcment about a new owner of an area.
		 * @param	owner_id
		 */
		public function sendNewAreaOwner(owner_id:String):void {
			var message:Object = new Object();
			message.action = "CONFIGAREA";
			message.owner_id = owner_id;
			message.area_id = area_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.send(message);
		}
		
		/**
		 * Sends a message to the network to change the accent color of an area.
		 * @param	c
		 * @param	area_id
		 */
		public static function sendAreaAccentColor(c:Number, area_id:Number):void {			
			var message:Object = new Object();
			message.action = "AREAACCENTCOLOR";
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();

			message.area_id = area_id;
			message.color = c;
			
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
			
		}
		
		/**
		 * Processes the AREAACCENTCOLOR message and updates an area's accent color.
		 * @param	msg
		 */
		public static function processAreaAccentColor(msg:Object):void {
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			
			(tt.getArea(msg.area_id) as TTArea).graphics.clear();
			(tt.getArea(msg.area_id) as TTArea).render(Number(msg.color));
		}
		
		/**
		 * draws an area. 
		 * @param	accent the accent color for the area: located at the top of the area, 15 pixels deep. If accent is -1, no accent rectangle is created
		 */
		public function render(accent:Number = -1):void {
			var fillColor:Number;
			if (FlexGlobals.topLevelApplication.tt.myself_id == this.owner_id) {
				fillColor = 0xD28B20; // mine
			} else if (this.owner_id == "-1") { 
				fillColor = 0xF2AB50; // public
			} else {
				fillColor = 0x865320; // someone else's
			}

			var lineColor:Number = 0x000000;
			this.bounds = new Rectangle(0, 0, w, h);			
			this.graphics.lineStyle(1.0, lineColor, 1.0);
			this.graphics.beginFill(fillColor, 1.0);
			this.graphics.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
			this.graphics.endFill();
			if (accent != -1) {
				this.graphics.lineStyle(0, 0, 0);
//				1.0, lineColor, 1.0);
				/* Accent color */
				this.graphics.beginFill(accent, .7);
				this.graphics.drawRect(bounds.left, bounds.top, bounds.width, 15);
				this.graphics.endFill();
			}
			
			//drawTestLine100100200200();
		}
		
		public function reRenderBackground(): void {
			this.graphics.clear();
			this.render();
		}
		
		public function addCard(c:TTCard):void {
			if (c.parent) {
				var p:Point = new Point(c.x, c.y);
				var newP:Point = this.globalToLocal(c.parent.localToGlobal(p));
				c.x = newP.x;
				c.y = newP.y;
			}

			c.area = this;
			this.cards[c.card_id] = c;
			//this.addChild(c);
			this.addAreaCardsInOrderAnd();
		}
		
		public function removeCard(c:TTCard):void {
			delete this.cards[c.card_id];
			//var index:int = this.cards.indexOf(c);
			//if (index != -1 ) this.cards.splice(index, 1);
		}
		
		public function bringToFront():void {
			if (this.parent.getChildIndex(this) != this.parent.numChildren - 1) { // this condition avoids unnecessarily repeating the addChild command
				this.parent.addChild(this);
			}
		}
		
		/* returns a local borderd Point) */
		public function borderedPoint(p:Point /* global */, card:TTCard, index:int = 0):Point {
			var returnP:Point = new Point(p.x, p.y);
			var cardoffsetx:int = card.origin.x;
			var cardoffsety:int = card.origin.y;
			if (returnP.x + cardoffsetx < 2) { //used to be 0
				returnP.x = 2 - cardoffsetx;
				returnP.y += index;
				// just stack the Y if the Y goes over boundaries
				if (returnP.y + cardoffsety + card.h > this.h -2) returnP.y = this.h + cardoffsety - card.h - 2;
				if (returnP.y + cardoffsety < 2) returnP.y = 2 - cardoffsety ; // top edge
			} else if (returnP.x + cardoffsetx + card.w > this.w - 2) { //right edge
				returnP.x = this.w - card.w - 2 - cardoffsetx;
				returnP.y += index;
				// just stack the Y if the Y goes over boundaries
				if (returnP.y + cardoffsety + card.h > this.h -2) returnP.y = this.h + cardoffsety - card.h - 2;
				if (returnP.y + cardoffsety < 2) returnP.y = 2 - cardoffsety ; // top edge
			} else if (returnP.y + cardoffsety < 2) {
				returnP.y = 2 - cardoffsety;
				returnP.x += index;
				// just stack the X if the X goes over boundaries
				if (returnP.x + cardoffsetx + card.w > this.w -2) returnP.x = this.w + cardoffsetx - card.w - 2;
				if (returnP.x + cardoffsetx < 2) returnP.x = 2 - cardoffsetx; 
			} else if (returnP.y + cardoffsety + card.h > this.h -2) {
				returnP.y = this.h - card.h - 2 - cardoffsety;
				returnP.x += index;
				// just stack the X if the X goes over boundaries
				if (returnP.x + cardoffsetx + card.w > this.w -2) returnP.x = this.w + cardoffsetx - card.w - 2;
				if (returnP.x + cardoffsetx < 2) returnP.x = 2 - cardoffsetx; 
			}
			return returnP;
		}		
		
		/**
		 * Manages the proper display of cards in an area. Cards are show in order of x then y position.
		 * @param	extra_sprite Extra sprite is used to add a sprite to the display of an area on a temporary basis. For example, if you are dragging a card in the area.
		 */
		public function addAreaCardsInOrderAnd(extra_sprite:Sprite = null):void {
			var unordered_cards:Dictionary = new Dictionary(true);
			var cden:Array = new Array();
			var o:Object;
			if (extra_sprite) {
				unordered_cards = cards;
			} else {
				unordered_cards = cards;
			}
			
			if (extra_sprite) {
				// let's assume this is only when we are dragging a sprite around and need to be fast (maybe we need a flag to try it the slow ay)
				// starting condition... ordered sprites in the lower layer.
				
				this.middle_layer.addChild(extra_sprite);
				
				var c:TTCard;
				// if extra_sprite is too low
				for (i = 0; i < this.upper_layer.numChildren; i+= 1) {
					try {
						c = this.upper_layer.getChildAt(i) as TTCard;
						if (!c.isChip && 
							(c.x - c.halfw < extra_sprite.x || 
							(c.x - c.halfw == extra_sprite.x && c.y - c.halfh <= extra_sprite.y))) {
							this.upper_layer.removeChild(c);
							this.lower_layer.addChild(c);
							i -= 1;
						}
					} catch (type_error: TypeError) {
						trace("casting type error, not a TTCard");
					}
				}
				
				// if extra_sprite is too high
				for (i = this.lower_layer.numChildren-1; i >= 0 ; i -= 1) {
					try {
						c = this.lower_layer.getChildAt(i) as TTCard;
						if (c.isChip || 
							(c.x - c.halfw > extra_sprite.x || 
							(c.x - c.halfw == extra_sprite.x 
							&& c.y- c.halfh >extra_sprite.y))) {
							this.lower_layer.removeChild(c);
							this.upper_layer.addChildAt(c, 0); 
						}
					} catch (type_error: TypeError) {
						trace("casting type error, not a TTCard");
					}
				}
				
			} else {
				// this sorting is guaranteed to happen before you ever drag a card.
				//for (var i:int = 0; i < unordered_cards.length; i += 1) {
				for each (o in unordered_cards) {
					//o = unordered_cards[i];
					if (o.hasOwnProperty("isChip") && !o.isDraggingFace) { // safe to check isDraggingFace because isChip exists this is a TTCard object
						//trace("hasown property front: " + o.front);
						cden.push( { "isChip":o.isChip, "x":o.x- Math.round(o.width / 2), "y":o.y- Math.round(o.height / 2 ), "sprite":o } ); 	
					} else if (o.hasOwnProperty("isChip") && o.isDraggingFace) {
						cden.push( { "isChip":o.isChip, "x":o.x , "y":o.y , "sprite":o } ); // card?
					} else {
						// all other children
						cden.push( { "isChip":false, "x":o.x , "y":o.y , "sprite":o } ); // card?	
					}
				}
				cden.sortOn(['isChip','x','y'], Array.NUMERIC);
				for (var i:int = 0; i < cden.length ; i += 1) {
					this.lower_layer.addChild(cden[i].sprite);
				}
			}
		}
		
		/**
		 * Draws a yellow rectangle around the area.
		 */
		public function lightMeUp():void {
		    if (this.lights == null)
		    {
		        // draws a yellow rectangle around the selected shape
		        this.lights = new Shape();
		        this.lights.graphics.lineStyle(2.0, 0x00FFFF, 2.0);
			    this.lights.graphics.drawRect(0, 0, this.w-1, this.h-1);
			    this.addChild(this.lights);
		    }
		    else
		    {
				this.lights.visible = true;
			}
		}
		
		/**
		 * Hide the yellow rectangle around an area
		 */
		public function lightMeDown():void {
			if (this.lights) this.lights.visible = false;
		}
		
		/**
		 * Collision detection with a global point px,py. Only works with convex shaped areas.
		 * @param	px global x
		 * @param	py global y
		 * @return <code>true</code> if area collides with px,py, else <code>false</code>
		 */
		public function collidesWith(px:Number, py:Number):Boolean {
			// px and py are GLOBAL
			// warning this collision detection assumes that the object is
			// convex. This will fail on concave shapes.
			var collide:Boolean = true;
			var a:Point, b:Point, c:Point, d:Point;
			//A-B
			//| |
			//C-D
			a = this.localToGlobal(new Point(0,0));
			b = this.localToGlobal(new Point(this.w, 0));
			c = this.localToGlobal(new Point(0, this.h));
			d = this.localToGlobal(new Point(this.w, this.h));
			collide = collide && TTMath.lineCross(a.x, a.y, b.x, b.y, px, py);
			collide = collide && TTMath.lineCross(b.x, b.y, d.x, d.y, px, py);
			collide = collide && TTMath.lineCross(d.x, d.y, c.x, c.y, px, py);
			collide = collide && TTMath.lineCross(c.x, c.y, a.x, a.y, px, py);
			return collide;
		}
		
		/**
		 * Counts the total cash in an area
		 * @return total cash in an area (Number)
		 */
		public function cashTotal():Number {
			var total:Number = 0;
			for each (var card:TTCard in this.cards) {
				if (card.isCashChip()) {
					total += Number(card.data);
				}
			}
			return total;
		}
		
		/**
		 * Counts the total number of cards in an area
		 * @return Number of cards in area
		 */
		public function cardTotal():Number {
			var total:Number = 0;
			for each (var card:TTCard in this.cards) {
				if (!card.isChip) {
					total += 1;
				}
			}
			return total;
		}
	}

}