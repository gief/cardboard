package engine 
{
	import flash.geom.Point;
	import mx.core.FlexGlobals;
	import net.houen.pokerface.AHand;
	/**
	 * Semantically-aware tracker that will keep track of an area as if it belongs to a certain player. This personal dock is hardwired
	 * to play poker (base case: Texas Hold'em) and will track the player's area and a delineated smart zone to indicate card ownership 
	 * and bets. 
	 * 
	 * This code is a prototype of how semi-automatic components should interface with the generally unrestricted 
	 * behavior of the basic version of Card Board. It is designed to be smart, but not restrict players from doing what they want.
	 * 
	 * 
	 * @author Gifford Cheung
	 */
	public class TTBettingPersonalDock 
	{
		/** Area where the personal dock is located */
		public var central_area: TTArea;
		
		/** Private Area connected with this doc */
		public var players_area: TTArea
		
		public var origin: Point;
		public var ending: Point;
		public var receive: Point;
		public var owner_id: String;
		public var player_id: String;
		public var component_manager:TTComponentManager;
		public var tt:TT = FlexGlobals.topLevelApplication.tt;
		public var width:int;
		public var height:int;
		public var textSpot:Point;
		/** Personal "pot" which is your public bid and the cards you display in your zone */
		public var pot:Array;
		public var cardmovingcontainer:TTCardContainer;
		public var isDealer:Boolean;
		public var isSmallBlind:Boolean;
		public var isBigBlind:Boolean;
		public var nextPlayerPot:TTBettingPersonalDock;
		public var bettingPot:TTBettingPot;
		
		public var flippedCardListener:Boolean = false; 
		
		public var pokerHand:AHand;
		public var pokerScore:String;
		public var pokerCategory:String;

		
		public var debugtext:String = "";
	
		
		public function TTBettingPersonalDock(central_area:TTArea, origin:Point, ending:Point, owner_id:String, player_id:String) 
		{
			cardmovingcontainer = new TTCardContainer();
			this.central_area = central_area;
			this.origin = origin;
			this.ending = ending;
			this.receive = Point.interpolate(origin, ending, 0.75);//  (origin, ending);
			this.owner_id = owner_id;
			this.player_id = player_id;
			this.width = Math.abs (ending.x - origin.x);
			this.height = Math.abs(ending.y - origin.y); // used for collision detection
			this.component_manager = FlexGlobals.topLevelApplication.tt.game_components[owner_id];
			// TODO construct an id
			
			this.textSpot = tt.globalToLocal(this.central_area.localToGlobal(new Point(origin.x + Math.floor (width / 2) - 50, origin.y + Math.floor (height / 2) - 50)));
			

			pot = new Array();
			drawSquare();
		}
		
		/**
		 * Function for collecting bids. 
		 * @param	chipNum Allows you to select the 2nd or 3rd chip from the set of chips.
		 * @return a chip from the player's bid
		 */
		public function getAChipFromBid(chipNum:int = 0):TTCard {
			var offset:int = 0;
			for (var i:int = 0; i < pot.length; i += 1 ) {
				if ((pot[i] as TTCard).isCashChip()) {
					if (offset == chipNum) {
						return (pot[i] as TTCard);
					} else {
						offset += 1;
					}
					
				}
			}
			return null;
		}
			
		/**
		 * is the player "in" following conventional poker rules (has cards and has a bid)
		 * @return <code>true</code> if in, else <code>false</code>
		 */
		public function isIn():Boolean {
			return (cardTotal() + players_area.cardTotal() > 0) && (bidTotal() + players_area.cashTotal() > 0);
		}
		
		/**
		 * Player's Name
		 * @return Player's name in the player's font color.
		 */
		public function playerName():String {
			if (tt.comm.about_all_players[player_id] != null) {
				return '<font color="' + tt.comm.about_all_players[player_id]["trailcolor"] + '"><b><u>' + player_id + '</u></b></font>';
			} else {
				return '<font color="#BBBBBB"><b><u>' + player_id + '</u></b></font>';
				
			}
		}
		
		/**
		 * Assigns a player to this component
		 * @param	player_id player to assign to this component
		 */
		public function assignPlayer(player_id:String):void {
			this.player_id = player_id;
		}
		
		/**
		 * Draw a square around the smart zone
		 */
		public function drawSquare():void {
			//component_manager
			// a-b
			// | |
			// c-d
			
			var a:Point = (new Point(central_area.x + origin.x, central_area.y + origin.y));
			var b:Point = (new Point(central_area.x + ending.x, central_area.y + origin.y));
			var c:Point = (new Point(central_area.x + origin.x, central_area.y + ending.y));
			var d:Point = (new Point(central_area.x + ending.x, central_area.y + ending.y));
			var offset:int = 2;
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, a.x-offset, a.y, b.x+offset, b.y);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, a.x, a.y-offset, c.x, c.y+offset);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, c.x-offset, c.y, d.x+offset, d.y);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, b.x, b.y-offset, d.x, d.y+offset);
		}

		/**
		 * Following poker conventions, checks if the player is the dealer and updates the proper flags to indicate this.
		 */
		public function checkIfDealer():void {
			isDealer = false;
			var card:TTCard;
			for each (card in this.pot) {
				if (card.data == "dealer") {
					isDealer = true;
					isSmallBlind = false;
					isBigBlind = false;
					bettingPot.dealer = this;
					
					this.nextPlayerPot.isSmallBlind = true;
					this.nextPlayerPot.isDealer = false;
					this.nextPlayerPot.isBigBlind = false;
					bettingPot.smallBlind = this.nextPlayerPot;
					
					this.nextPlayerPot.nextPlayerPot.isBigBlind = true;
					this.nextPlayerPot.nextPlayerPot.isSmallBlind = false;
					this.nextPlayerPot.nextPlayerPot.isDealer = false;
					bettingPot.bigBlind = this.nextPlayerPot.nextPlayerPot;
					
					this.nextPlayerPot.nextPlayerPot.nextPlayerPot.isBigBlind = false;
					this.nextPlayerPot.nextPlayerPot.nextPlayerPot.isSmallBlind = false;
					this.nextPlayerPot.nextPlayerPot.nextPlayerPot.isDealer = false;			
					break;
				}
			}
		}
		
		/**
		 * Do I have the yellow current player chip in my possession?
		 * @return <code>true</code> if current player, else <code>false</code>
		 */
		public function isCurrentPlayer():Boolean {
			var currentPlayer:Boolean = false;
			for each (var card:TTCard in this.players_area.cards) {
				currentPlayer = currentPlayer || (card.isChip && card.data == "current") ;
			}
			return currentPlayer;
		}
		
		/**
		 * Updates visual text about game state for this player
		 * @param	extra - extra string to attach to the zone text.
		 */
		public function updateStatusAndDisplay(extra:String = "" ):void {
			var count:int = 0;
			var txt:String = "";
			//isDealer = false;
			var cardtotal:int = cardTotal() + players_area.cardTotal();
			var bidtotal:int = bidTotal();
			var cashtotal:int = players_area.cashTotal();
			var broke:Boolean = bidtotal + cashtotal == 0;
			var iscurrentplayer:Boolean = isCurrentPlayer();
			checkIfDealer();
			if (iscurrentplayer) bettingPot.assignCurrentPlayerPot(this);
			
			txt += "$" + String(bidtotal) + ", " + cardtotal + (cardtotal==1?" card":" cards");
			//txt += "\n" + player_id;
			var newcolor:Number = 0x008800;
			bettingPot.updateDisplay("High Bid: $" + bettingPot.calculateHighBid(), 1);
			 
			if (bettingPot && bettingPot.gameState != "INIT") {
				if (isDealer) {
					txt += "\ndealer";
				}
				if (isSmallBlind) {
					txt += "\nsmall blind";
				}
				if (isBigBlind) {
					txt += "\nbig blind";
				}
				if (cardtotal == 0) {
					txt += "\n(Out)";
					newcolor = 0xE0E0E0;
				}
				
				if (iscurrentplayer) {
					//txt += "\nYOUR TURN";
					//newcolor = 0xF2EA6A;
				}
				if (broke || cardtotal == 0) {
					txt += "\n";
				}
				if (broke && bidtotal == 0) {
					txt += "Broke! ";
					newcolor = 0xE0E0E0;
				}
				
				if (broke && cardtotal > 0) {
					txt += "All in";
				}

				if (extra) {
					txt += extra;
				}

			}
			
			TTArea.sendAreaAccentColor(newcolor, players_area.area_id);
			
			tt.visual_effect_layer.writePermenaText(tt.comm.about_all_players[owner_id].permenalabel, "personalbox"+player_id, txt, textSpot.x, textSpot.y, 0);
		}
		
		/**
		 * Returns the total bid of this player
		 * @return Number indicating bid total
		 */
		public function bidTotal():Number {
			var total:Number = 0;
			for each (var card:TTCard in this.pot) {
				if (card.isCashChip()) {
					total += Number(card.data);
				}
			}
			return total;
		}
		
		/**
		 * Returns the total number of cards owned by this player
		 * @return Number of cards owned
		 */
		public function cardTotal():Number {
			var total:Number = 0;
			for each (var card:TTCard in this.pot) {
				if (!card.isChip) {
					total += 1;
				}
			}
			return total;
		}
		
		/**
		 * Collision detection for a card
		 * @param	card
		 * @param	custom_card_point
		 * @param	custom_card_point_area
		 * @return
		 */
		public function collidesWithCardAt(card:TTCard, custom_card_point:Point = null, custom_card_point_area:TTArea = null):Boolean {
			
			if (custom_card_point) {
				return (
					pointInside(custom_card_point_area.localToGlobal(new Point(card.origin.x + custom_card_point.x, 				card.origin.y + custom_card_point.y))) &&
					pointInside(custom_card_point_area.localToGlobal(new Point(card.origin.x + custom_card_point.x + card.w, 	card.origin.y + custom_card_point.y))) &&
					pointInside(custom_card_point_area.localToGlobal(new Point(card.origin.x + custom_card_point.x, 				card.origin.y + custom_card_point.y + card.h))) &&
					pointInside(custom_card_point_area.localToGlobal(new Point(card.origin.x + custom_card_point.x + card.w, 	card.origin.y + custom_card_point.y + card.h)))
						);				
			} else {
				return (
					pointInside(card.area.localToGlobal(new Point(card.origin.x + card.x, card.origin.y + card.y))) &&
					pointInside(card.area.localToGlobal(new Point(card.origin.x + card.x + card.w, card.origin.y + card.y))) &&
					pointInside(card.area.localToGlobal(new Point(card.origin.x + card.x, card.origin.y + card.y + card.h))) &&
					pointInside(card.area.localToGlobal(new Point(card.origin.x + card.x + card.w, card.origin.y + card.y + card.h)))
						);
			}
		}
		
		/**
		 * Collision detection for a point
		 * @param	p
		 * @return
		 */
		public function pointInside(p:Point):Boolean {
			// a-b
			// | |
			// c-d
			var a:Point = central_area.localToGlobal(origin);
			var b:Point = central_area.localToGlobal(new Point(origin.x + this.width, origin.y));
			var c:Point = central_area.localToGlobal(new Point(origin.x, origin.y + this.height));
			var d:Point = central_area.localToGlobal(new Point(origin.x + this.width, origin.y + this.height));
			var collide: Boolean = true;
			
			collide = collide && TTMath.lineCross(a.x, a.y, b.x, b.y, p.x, p.y);
			collide = collide && TTMath.lineCross(b.x, b.y, d.x, d.y, p.x, p.y);
			collide = collide && TTMath.lineCross(d.x, d.y, c.x, c.y, p.x, p.y);
			collide = collide && TTMath.lineCross(c.x, c.y, a.x, a.y, p.x, p.y);
			return collide;
		}
		
		/**
		 * Add a card to your pot
		 * @param	card
		 */
		public function addCard(card:TTCard):void {
			if (pot.indexOf(card) == -1) {
				pot.push(card);
			}
		}
		
		/**
		 * Remove a card from the pot
		 * @param	card - card to remove
		 */
		public function removeCard(card:TTCard):void {
			pot.splice(pot.indexOf(card), 1);
		}
		
		/**
		 * Listener for cards that move in and out of this area/pot 
		 * @param	card
		 * @param	moved_from
		 * @param	moved_from_area
		 */
		public function movedCardListener(card:TTCard, moved_from:Point, moved_from_area:TTArea):void {
			
			//trace(this.collidesWithCardAt(card, moved_from, moved_from_area) + "moved" + this.collidesWithCardAt(card));
			var wasInPot:Boolean = this.collidesWithCardAt(card, moved_from, moved_from_area);
			var isInPot:Boolean = this.collidesWithCardAt(card);
			
			var relatedToPersonalArea:Boolean = 
				this.players_area.area_id == moved_from_area.area_id || 
				this.players_area.area_id == card.area.area_id;
				
			if (wasInPot != isInPot) { // this means a card moved in or out of the pot
				if (isInPot) {
					addCard(card);
					//TTSideConsole.write("\n "+this.player_id+"AddCard " + card.front);	
					//TTSideConsole.write("\n "+this.player_id+"collisions was:" + wasInPot + " is:" + isInPot);	
				} else {
					removeCard(card);
					//TTSideConsole.write("\n "+this.player_id+"removeCard " + card.front);	
					//TTSideConsole.write("\n "+this.player_id+"collisions was:" + wasInPot + " is:" + isInPot);	
				}
				
				updateStatusAndDisplay();
			} else if (relatedToPersonalArea) {
				updateStatusAndDisplay();
			}
			
			if (!card.isChip) {
				if (component_manager.cz) {
					component_manager.cz.updateAnalysis();
				}
			}
		}
		
		/**
		 * Get money from this pot up to a certain amount (if there is not enough money, return what you can)
		 * @param	upToAmount
		 * @return array containing the cash chips that are returned
		 */
		public function fromThisPot(upToAmount:int):Array {
			var count:int = 0;
			var returnarray:Array = new Array();
			for each (var card:TTCard in this.pot) {
				if (count > upToAmount) {
					trace ("Returning too much money using fromPot. More sophisticated algorithm required.");
					break;
				}
				if (count == upToAmount) {
					break;
				}
				if (card.isCashChip()) {
					returnarray.push(card);
					count += Number(card.data);
				}
			}
			return returnarray;
		}
		
		/**
		 * Redistribute  cards(cash) from <code>cards</code> among certain number of areas.
		 * (currently duplicate code as found in TTBettingPot needs to be removed or deduplicated
		 * 	Example:
		 * <code>
		 *		var divest:Array = fromPot(16);
		 *	 	if (divest.length == 16) {
		 *			distribute(divest, [tt.areas[1], tt.areas[2], tt.areas[3]], [1,1,2]);
		 *		}
		 *		</code>
		 *	
		 * @param	cards
		 * @param	areas
		 * @param	ratios
		 */
		 public function distribute(cards:Array, areas:Array, ratios:Array):void {
			// TODO why is this here
			// TODO why is this not static?
			
			if (areas.length != ratios.length) {
				trace("incorrect use");
			}
			//cardmovingcontainer.cards = cards; // not cards.concat() for a copy of the array?
			
			var distros:Array = new Array();
			var area:TTArea;
			var distro:Array;
			var ratio:int;
			var i:int, j:int;

			for (i = 0; i < ratios.length; i += 1 ) {
				distros.push(new Array());
			}
			
			for (i = 0; i < cards.length; null ) {
				if (i == cards.length) { break; }
				for (j = 0; j < distros.length; j += 1) {
					if (i == cards.length) { break; }
					distro = distros[j];
					ratio = ratios[j];
					if (distro == null) { distro = new Array();}
					var add:Array = cards.slice(i, i + ratio);
					for each (var a:TTCard in add) {
						delete pot[a.card_id];
						distro.push(a);
					}
					i = i + ratio;
					if (i > cards.length) {	i = cards.length; }
				}
			}
			
			// each distro should have the cards we want to move now...
			for (j = 0; j < distros.length; j +=1) {
				distro = distros[j];
				area = areas[j];
				cardmovingcontainer.cards = distro.slice();
				cardmovingcontainer.stackSelected(
					area.localToGlobal(new Point(Math.floor(area.w / 2), 10)),
					2, 0);
			}
			updateStatusAndDisplay();
		}
	}

}