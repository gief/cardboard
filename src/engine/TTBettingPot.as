package engine 
{
	import flash.geom.Point;
	import flash.utils.Timer;
	import mx.core.FlexGlobals;
	import flash.events.Event;
	import mx.core.UIComponent;
	/**
	 * Special component for holding bets for a game of poker (modelled after Texas Hold'em). This bettingpot is essentially
	 * a game engine for poker (based on Texas Hold'em) that coordinates the game by managing the personalPots and the community
	 * zone/pot.
	 * 
	 * Note that in a multiplayer setting, this game logic is managed by one client (not necessarily the server) and the
	 * rest of connected network clients only see cards and chips being moved and visual effects being dictated by network
	 * messaging.
	 * 
	 * @author Gifford Cheung
	 */
	public class TTBettingPot extends UIComponent
	{
		public var area: TTArea;
		public var origin: Point;
		public var displaytext:Point;
		public var owner_id: String;
		public var current_player: Number;
		public var current_potindex: Number;
		public var currentPlayerPot: TTBettingPersonalDock;
		
		public var tt:TT = FlexGlobals.topLevelApplication.tt;
		public var w:int;
		public var h:int;
		public var pot:Array;
		public var cardmovingcontainer:TTCardContainer;
		public var playersAreas:Array = new Array();
		public var personalPots:Array = new Array();
		
		/** location we want to receive new chips */
		public var receive:Point;
		public var stackindex:int = 0;
		public var stackindexvertical:int = 0;
		
		public var dealerchip:TTCard;
		public var currentchip:TTCard;
		
		
		public var flippedCardListener:Boolean = false; 
		
		public function TTBettingPot(area:TTArea, origin:Point, owner_id:String) 
		{
			cardmovingcontainer = new TTCardContainer();
			this.area = area;
			this.origin = origin;
			this.owner_id = owner_id;
			this.current_player = 0;
			this.w = 80;
			this.h = 135;
			
			this.displaytext = new Point(origin.x, origin.y + this.h);
			
			if (owner_id == tt.myself_id) {
				FlexGlobals.topLevelApplication.bp = this;
			}
			pot = new Array();
			for each (var a:TTArea in tt.areas) {
				if (a.area_id != this.area.area_id) {
					playersAreas.push(a);
				}
			}
			
			receive = new Point(origin.x + 35, origin.y  + 10); 
			drawSquare();
			tt.addChild(this);
			
			TTSideConsole.writeln("<b>Automatic Component are enabled.</b> Drop the <font color='#EEEE00'>yellow chip</font> into the center area to start a round of bidding or to finish your bid.");
			TTSideConsole.writeln("Move the <font color='#FF0000'>red chip</font> into another light brown area to change the dealer. Deal cards into each player's zone or area. Their indicator will turn <font color='#00FF00'>green</font> if they have cards and enough chips to play.");
			TTSideConsole.writeln("");
			TTSideConsole.writeln("<font color='#FF3333'>Currently Automatic Components are known to fail in multiplayer.</font>");
			TTSideConsole.writeln("");
			TTSideConsole.writeln("Despite its bugs, this automation is included in this release as a demonstration of how semi-automation might exist hand-in-hand with a highly flexible game environment without losing the freedom to do whatever you want with the cards.");
			
			
			
		}
		
		public function stack_index_vertical():int {
			return stackindexvertical;
		}
		
		public function stack_index_vertical_change(dx:int):void {
			stackindexvertical += dx;
		}
		
		public function stack_index():int {
			return stackindex;
		}
		
		public function stack_index_change(dx:int):void {
			stackindex += dx;
		}
		
		public function stack_index_reset():void {
			stackindex = 0;
		}
		
		public function stack_indices_reset():void {
			stackindex = 0;
			stackindexvertical = 0;
		}
		
		/** add special text to the yellow chip that instructs the user to drop a chip in the right area to activate the automatic processes 
		 */
		public function decorDropCenter():void {
			currentchip.setDragDecorText("DROP\nTO START\nBIDDING\nROUND", 0xFF0000);
		}
			
		/**
		 * Resets the game table for a new game
		 * @param	currentPlayerPot
		 * @param	softreset -- reset in between rounds (NOT IMPLEMENTED)
		 */
		public function resetTable(currentPlayerPot:TTBettingPersonalDock, softreset:Boolean = false):void {
			var area:TTArea;
			var card:TTCard;
			
			
			//distribute the chips
			cardmovingcontainer.resetSelection();
			for each (area in tt.areas) {
				for each (card in area.cards) {
					if (!card.isChip) {
						cardmovingcontainer.cards.push(card);
					}
				}
			}
			cardmovingcontainer.shuffle();
			cardmovingcontainer.stackSelected(this.area.localToGlobal(new Point(448, 305)), 0, 2, 0, true, TTCardContainer.FLIP_DOWN, true);

			
			//shuffle the cards and
			//put dealer chip in the right place
			cardmovingcontainer.resetSelection();
			for each (area in tt.areas) {
				for each (card in area.cards) {
					if (card.isCashChip()) {
						cardmovingcontainer.cards.push(card);
					} else if (card.data == "dealer") {
						dealerchip = card;
						dealerchip.setDragDecorText("ASSIGN\nDEALER", 0xFF0000);
					} else if (card.data == "current") {
						currentchip = card;
						//currentchip.setDragDecorText("NEXT", 0xFFFF00);
						decorDropCenter();
						//currentchip.setDragDecorText("DROP\nTO START\nBIDDING\nROUND", 0xFF0000);
					}
				}
			}
			
		
			var r:Point = currentPlayerPot.players_area.receive();
			
			var distro:Array = new Array();
			for each (area in playersAreas) {
				distro.push(1);
			}
			this.distribute(cardmovingcontainer.cards, playersAreas, distro);
			
			gameState = "DEALER_ACTION";

			//move the dealer chip to a certain location
			dealerchip.enqueueAndSendMove(currentPlayerPot.central_area, currentPlayerPot.receive.x, currentPlayerPot.receive.y, true, true, true);
			/* replace by the above 5/26/2014
			 * dealerchip.sendMove(dealerchip.area.area_id, dealerchip.x, dealerchip.y, currentPlayerPot.central_area.area_id, currentPlayerPot.receive.x, currentPlayerPot.receive.y, true);
			 */
			currentPlayerPot.addCard(dealerchip);
			// move current chip in nonquiet mode to trigger action
			
			this.currentPlayerPot = currentPlayerPot;
			currentchip.enqueueAndSendMove(currentPlayerPot.players_area, r.x, r.y, true, true, true);
			/* replaced by the above 5/26/2014
			currentchip.sendMove(currentchip.area.area_id, currentchip.x, currentchip.y,  currentPlayerPot.players_area.area_id, r.x, r.y);
			*/
		}

		/**
		 * Draw the square for this zone
		 */
		public function drawSquare():void {
			// a-b
			// | |
			// c-d
			var a:Point = (new Point(area.x + origin.x, area.y + origin.y));
			var b:Point = (new Point(area.x + origin.x+w, area.y + origin.y));
			var c:Point = (new Point(area.x + origin.x, area.y + origin.y+h));
			var d:Point = (new Point(area.x + origin.x+w, area.y + origin.y+h));
			var offset:int = 2;
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, a.x-offset, a.y, b.x+offset, b.y);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, a.x, a.y-offset, c.x, c.y+offset);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, c.x-offset, c.y, d.x+offset, d.y);
			tt.visual_effect_layer.drawPermenaLine(tt.comm.about_all_players[owner_id].permenalabel, b.x, b.y-offset, d.x, d.y+offset);
		}
		
		private var displayLines:Array = new Array();
		
		/**
		 * Update the textual display of this zone
		 * @param	text - new text to display
		 * @param	line - which line to alter
		 */
		public function updateDisplay(text:String, line:int = 1):void {
			displayLines[line] = text;
			var alltext:String = "";
			for (var i:int = 0; i < displayLines.length; i += 1 ) {
				alltext += displayLines[i] + "\n";
			}
			var location:Point = tt.globalToLocal(this.area.localToGlobal(displaytext));
			//trace("point: " +  location.x + " " + location.y + " " +  " oldone : "  + origin.x + " , " + origin.y);
			tt.visual_effect_layer.writePermenaText(tt.comm.about_all_players[owner_id].permenalabel, "box", alltext, location.x, location.y, 0);
		}
		
		/**
		 * Collision detection (card)
		 * @param	card
		 * @param	custom_card_point
		 * @param	custom_card_point_area
		 * @return <code>true</code> if collision, <code>false</code> otherwise.
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
		 * Collision detection (global point)
		 * @param	p
		 * @return <code>true</code> if collision, <code>false</code> otherwise.
		 */
		public function pointInside(p:Point):Boolean {
			// a-b
			// | |
			// c-d
			var a:Point = area.localToGlobal(origin);
			var b:Point = area.localToGlobal(new Point(origin.x + this.w, origin.y));
			var c:Point = area.localToGlobal(new Point(origin.x, origin.y + this.h));
			var d:Point = area.localToGlobal(new Point(origin.x + this.w, origin.y + this.h));
			var collide: Boolean = true;
			
			collide = collide && TTMath.lineCross(a.x, a.y, b.x, b.y, p.x, p.y);
			collide = collide && TTMath.lineCross(b.x, b.y, d.x, d.y, p.x, p.y);
			collide = collide && TTMath.lineCross(d.x, d.y, c.x, c.y, p.x, p.y);
			collide = collide && TTMath.lineCross(c.x, c.y, a.x, a.y, p.x, p.y);
			return collide;
		}
		
		/**
		 * Listener that keeps track of card/chip movement to update semantic understanding of state
		 * @param	card
		 * @param	moved_from
		 * @param	moved_from_area
		 */
		public function movedCardListener(card:TTCard, moved_from:Point, moved_from_area:TTArea):void {
			var wasInPot:Boolean = this.collidesWithCardAt(card, moved_from, moved_from_area);
			var isInPot:Boolean = this.collidesWithCardAt(card);
			
			if (wasInPot || isInPot) { // this means a card moved in or out of the pot
				if (isInPot) {
					//pot[card.card_id] = card;
					addCard(card);
				} else {
					removeCard(card);
				}			
			}

			
			if (wasInPot != isInPot ||  // card has moved in or out of the pot
				card.area.area_id != moved_from_area.area_id || // card has moved from one area to the next
				card.data == "dealer" || card.data == "current") {
				runGame(card, moved_from, moved_from_area);
				updateDisplay("$"+pot_total(), 0);
			}
			
		}
		
		/**
		 * Semantically adds a card into this zone's "pot"
		 * @param	card
		 */
		public function addCard(card:TTCard):void {
			if (pot.indexOf(card) == -1) {
				pot.push(card);
			}	
		}
		
		/**
		 * Semantically removes a card from the pot.
		 * @param	card
		 */
		public function removeCard(card:TTCard):void {
			pot.splice(pot.indexOf(card), 1);
		}
		
		/**
		 * Setup to identify the personalPots that this zone keeps track of.
		 * @param	r - array of pots
		 */
		public function setPersonalPots(r:Array):void {
			this.personalPots = r;
			
			//set current_potindex
			for (var i:int = 0; i < personalPots.length; i += 1) {
				if (personalPots[i].player_id == tt.comm.all_players[current_player]) {
					current_potindex = i;
				}
				(personalPots[i] as TTBettingPersonalDock).players_area = playersAreas[i]; //untested
			}
			//FlexGlobals.topLevelApplication.cbServer.text = "assigned: " + current_potindex;
			
		}
		
		public var gameState:String = "INIT";
		private var temp_stack:TTCardContainer = new TTCardContainer;
		private var temp_point:Point;
		// dealer
		public var dealer:TTBettingPersonalDock;
		// small blind
		public var smallBlind:TTBettingPersonalDock;
		// big blind
		public var bigBlind:TTBettingPersonalDock;
		private var timer:int = 200;
		
		public var high_bid:int = 0;
		public var current_bid:int = 0;
		
		/**
		 * Pot total
		 * @return total value of this pot
		 */
		public function pot_total():int {
			var total:int = 0;
			for each (var c:TTCard in pot) {
				if (c.isCashChip()) {
					total += Number(c.data);
				}
			}
			return total;
		}
		

		/**
		 * Moves the yellow chip to the next player based on poker rules about being in the game or not.
		 * @param	num
		 * @param	currentPlayerPotOverride
		 * @param	ignoreSkips
		 * @return
		 */
		public function advancePlayer(num:int, currentPlayerPotOverride:TTBettingPersonalDock = null, ignoreSkips:Boolean = false):Object {
			var return_object:Object = new Object;
			var skippedDealer:Boolean = false;
			var next:TTBettingPersonalDock = currentPlayerPot;
			if (currentPlayerPotOverride) {
				next = currentPlayerPotOverride;
			}
			var num_players_in:int =  numPlayersIn();
			var origin:TTBettingPersonalDock = currentPlayerPot;
			var skip:int = 0;
			var skipped_too_much:Boolean = false;
			var next_mybid:int;
			while (num > 0 && !skipped_too_much) {
				next = next.nextPlayerPot;
				next_mybid = next.bidTotal();
				//TTSideConsole.writeln("check " + next.player_id + " broke: " + next.players_area.cashTotal() + next.bidTotal() + " mybid: " + next_mybid + " numcards: "  + next.cardTotal() + next.players_area.cardTotal());
				if (next.isIn()) {
				/*
				(!(next.players_area.cashTotal() == 0 && next.bidTotal() == 0) &&  // not broke
					next.cardTotal() + next.players_area.cardTotal() != 0 ) {*/
					num -= 1;
				} else if (ignoreSkips) {
					num -= 1;
				} else {
					//TTSideConsole.writeln("Skipping " + next.player_id); 
					skippedDealer = skippedDealer || dealer.player_id == next.player_id;
					skip += 1;
				}
				skipped_too_much = skip -1 > num_players_in;
			}
			//TTSideConsole.writeln("Skips " + skip + " pplength: " + num_players_in); 
			
			if (!skipped_too_much) {
				var r_global:Point = next.players_area.localToGlobal(next.players_area.receive());
				var r:Point = next.players_area.receive();
				
				currentchip.enqueueAndSendMove(next.players_area, next.players_area.receive().x, next.players_area.receive().y, true, false, true);
				
				//var c:Point = currentchip.area.localToGlobal(new Point(currentchip.x, currentchip.y));
				//TTCardMover.enqueue(
				//		currentchip, 
				//		currentchip.area.area_id, c.x, c.y, (currentchip.rotation + currentchip.area.rotation) % 360, 
				//		next.players_area.area_id, r_global.x, r_global.y, next.players_area.rotation + currentchip.rotation,
				//		true /*myself*/, false /*remote*/, true/*animate*/, true /*quiet*/, true /*false/*processit*/);
				//currentchip.processMovedCard(r_global.x, r_global.y, next.players_area.area_id, true); /* moved out to see if it works */
				//currentchip.sendMove(currentchip.area.area_id, currentchip.x, currentchip.y,  next.players_area.area_id, r.x, r.y);
				
				tt.selectedCards.removeCard(currentchip);
				currentchip.hideSelected();
				currentPlayerPot = next;
			} else {
				tt.selectedCards.removeCard(currentchip);
				currentchip.hideSelected();
				//currentchip.sendMove(currentchip.area.area_id, currentchip.x, currentchip.y,  this.area.area_id, 100, 225,true);
				updateDisplay("No players\nin game.", 2);
				//TTSideConsole.writeln("<font color='gray' size='13'><b>No one is playing</b> (No one has cards)</font>");
			}
			return_object.skippedTooMuchAndCouldNotFindAnEligibleNextPlayer = skipped_too_much;
			return_object.skippedDealer = skippedDealer;
			return return_object;
		}

		
		public var old_current:TTBettingPersonalDock;
		
		/**
		 * Semantically assigns as certain player/pot/personaldock as the current player
		 * @param	p
		 */
		public function assignCurrentPlayerPot(p:TTBettingPersonalDock):void {
			old_current = currentPlayerPot;
			currentPlayerPot = p;
		}
		
		/**
		 * Main game loop for poker. This is a very big function. 
		 * Includes most or all of the poker game states including what would be impossible
		 * game states if we had total control over the chips and cards.
		 * 
		 * @param	movedCard
		 * @param	moved_from
		 * @param	moved_from_area
		 */
		public function runGame(movedCard:TTCard = null, moved_from:Point = null, moved_from_area:TTArea = null):void  {

			var current_is_in_an_active_place:Boolean = false;
			//var old_current:String = currentPlayerPot.player_id;
			var current_player_has_changed_directly:Boolean = false;
			var yellow_thrown_to_center:Boolean = false;
			var temp_pot:TTBettingPersonalDock;
			var temp_card:TTCard;
			
			if (movedCard) {
				if (movedCard.data == "current") {
					for each (var pot:TTBettingPersonalDock in personalPots) {
						if (pot.players_area.area_id == movedCard.area.area_id && movedCard.area.owner_id != "-1") {
							assignCurrentPlayerPot(pot);
							current_is_in_an_active_place = true;
						}
					}
					
					// DO I NEED THIS AT ALL?
					current_player_has_changed_directly =  (current_is_in_an_active_place && 
						moved_from_area.area_id != currentPlayerPot.players_area.area_id &&
						old_current.player_id != currentPlayerPot.player_id);
						
					yellow_thrown_to_center = movedCard.area.owner_id == "-1";
				}
				if (movedCard.data == "dealer") {
					//dealer.updateStatusAndDisplay(); THIS SHOULD ALREADY HAVE RUN VIA MOVE LISTENER
					// if we don't know who the dealer is, then the dealer is the last person who was the dealer.
					if (smallBlind) smallBlind.updateStatusAndDisplay();
					if (bigBlind) bigBlind.updateStatusAndDisplay();
					if (bigBlind) bigBlind.nextPlayerPot.updateStatusAndDisplay();
				}
			}
			//TTSideConsole.write(currentPlayerPot.player_id + "\n");
			var allPotsTotal:int = 0;
			var numCardsTotal:int = 0;
			for each (var personalPot:TTBettingPersonalDock in personalPots) {
				allPotsTotal += personalPot.bidTotal();
				numCardsTotal += personalPot.cardTotal() + personalPot.players_area.cardTotal();
			}
			
			//TTSideConsole.writeln(gameState);
			
			// act based on game state
			switch (gameState) {
				case "INIT" :
					// ZERO STATE
					break;
				case "DEALER_ACTION":
					if (current_player_has_changed_directly) {
						TTSideConsole.writeln("\nYou've manually moved the yellow chip.\n<font color='#000099'><b>A Bidding Round has begun!</b></font>");
						gameState = "WAITING_FOR_BID";
						currentchip.setDragDecorText("FINISH\nBID", 0xFFFF00);
					}
					
					if (yellow_thrown_to_center) {
						if (numPlayersIn() > 1) {
							advancePlayer(1, dealer);
							TTSideConsole.writeln("\n<font color='#000099'><b>A Bidding Round has begun!</b></font>");
							gameState = "WAITING_FOR_BID";
							currentchip.setDragDecorText("FINISH\nBID", 0xFFFF00);
						} else {
							TTSideConsole.writeln("\n<font color='#888888'><b>Need at least 2 players with cards & chips to start.</b></font>");
						}
					}
					break;
				case "WAITING_FOR_BID":
					/*
					 * 
					 * We are waiting for the player to confirm a bid.
					 * To confirm a bid, the player moves the chip out of his area into another player's area
					 * Or he moves it to center, where an automatic thing is done.
					 * 
					 * In both cases, we have to decide:
						 * Did he check? 0,0,0,0 ---> dealer?...
						 * 	There are cards. There is a bet in the box and his bet is ZERO. This is considered a check.
						 * Did he call? There are cards. There is a bet in the box and his bet MATCHES the highest bet. and his bet is not 0 This is considered a call.
						 * * Did he fold? There are no cards in his box anymore. All his money goes to the pot. This is a fold.
						 * Did he raise? There are cards. There is a higher bet in the box than the current high bet. This is a raise.
						 * Did he end the bidding? 
						 * 	If all card holders have the same bet, then the round is over and we are WIAITN FOR DEALER
					 * 
					 * We also have to know what ends the round....
					 * 	Sparse documentation here.
					 * 
					 * Thus we need to know:
						 * Are there cards? (old_current_player.numCards)
						 * high bid (calculateHighBid())
						 * box total (pot_total)
						 * your bet (old_current_player.mybid)
						 * 
						 * If there are cards showing --- and no bids, then we need to distribute pot money... (ask question to go on?)
						 *
						 * everytime money goes into the pot, we record it as main pot (this goes to the winner no matter what)
						 * everytime we have an all in, we record that we have an all in situation? or move the chips out for now....
					 * 
					 */
					
					//updateDisplay("High Bid:" + calculateHighBid(), 2);
					var old_current_bid:int = old_current.bidTotal();
					var high:int = calculateHighBid();
					var dealerHasChecked:Boolean = false;
	
					if (yellow_thrown_to_center) {
						if (!dealer) {
							TTSideConsole.writeln("<font color='red'>No Dealer Assigned. Please move the Dealer chip into a player's area.</font>");
							break;
						}
						//TTSideConsole.writeln("yellow_thrown_to_center");
						//TTSideConsole.writeln("hi.," + old_current.cardTotal() +  " hi: " + old_current.players_area.cardTotal());
						
						// Player just CHECKED, CALLED or RAISED
						if (old_current.cardTotal() + old_current.players_area.cardTotal() > 0 ) {
							// The player has and is therefore, still in the game.
							if (old_current_bid > 0) {
								// call or raise
								TTSideConsole.writeln(old_current.playerName() + "'s bid is <font color='#008800'><b>$" + old_current_bid + "</b></font>");
								
								if (old_current.players_area.cashTotal() == 0) {
									TTSideConsole.writeln(old_current.playerName() + " is  <b>ALL IN</b>.");
								} else {
									if (old_current_bid < high) {
										// needs logical cleanup
										// This is a strange situation. The player passed the turn while having a low bid.
										TTSideConsole.writeln("&nbsp;&nbsp;&nbsp;"+old_current.playerName() + " is <font color='#880000'><b>$" + String(high - old_current_bid) + "</b> short. </font><font color='#999999' size='13'>What's going on?</font>");
									}
								}
							} else if (old_current_bid > high) {
							// this will never happen?
							} else if (old_current_bid == 0) {
									if (old_current_bid < high && !currentPlayerPot.isBigBlind) {
										// This is a strange situation. The player passed the turn while having a low bid.
										TTSideConsole.writeln("&nbsp;&nbsp;&nbsp;"+old_current.playerName() + " is <font color='#880000'><b>$" + String(high - old_current_bid) + "</b> short. </font><font color='#999999' size='13'>What's going on?</font>");
									}
								if (old_current.player_id == dealer.player_id) {
									// a little redundant, but this is clearer
									// bidded zero and is the dealer, so we set a flag for later.
									dealerHasChecked = true;
								}
							}
						} else { // endif cardtotal + area.cardtotal > 0
							TTSideConsole.writeln(old_current.player_id + " folded.");
						}
						
						// CHECK FOR A WINNER
						var winner:TTBettingPersonalDock = onePlayerLeft();
						if (winner != null) {
							// WE HAVE A WINNER!
							TTSideConsole.writeln(winner.playerName() + " wins! ");// TODO give him the money?);
							stack_indices_reset();
							decorDropCenter();
							gameState = "DEALER_ACTION";
						} 
						
						// CHECK FOR ALL BETS CALLED, etc...
						var all_bids_called_or_all_in:Boolean = bidsAreEvenOrAllIn(); 
						if (all_bids_called_or_all_in && high > 0) {
							TTSideConsole.writeln("All bets are called. Betting is round over.");
							var r:Point = dealer.players_area.receive();
							var r_global:Point = dealer.players_area.localToGlobal(dealer.players_area.receive());
							var c:Point = currentchip.area.localToGlobal(new Point(currentchip.x, currentchip.y));
							currentchip.enqueueAndSendMove(dealer.players_area, dealer.players_area.receive().x, dealer.players_area.receive().y, true, false, true);
							//TTCardMover.enqueue(currentchip /*card*/, currentchip.area.area_id/*orig area id*/, 
								//c.x/*ox*/, c.y/*oy*/, currentchip.rotation/*or*/, 
								//dealer.players_area.area_id /*daid*/, r.x/*dx*/, r.y/*desty*/, currentchip.rotation/*destr*/, 
								//null/**/, null/**/, true/*animate*/, true/*quiet*/, true/*processit*/);
							//currentchip.sendMove(currentchip.area.area_id, currentchip.x, currentchip.y,  dealer.players_area.area_id, r.x, r.y, true);
							
							/* collect chips and bring them into the pot */
							var allLegitBids:Array = new Array();
							stack_index_reset();
							for each (temp_pot in personalPots) {
								var temp_pot_bidTotal:int = temp_pot.bidTotal();
								if (temp_pot.cardTotal() + temp_pot.players_area.cardTotal() > 0 ) {
									//&& temp_pot_bidTotal > 0) {
									allLegitBids.push({bid:temp_pot_bidTotal, p_id:temp_pot.player_id, pot:temp_pot});
								}
							}
							allLegitBids.sortOn("bid");
							var playersInString:String = "";
							var playersIn:int = 0;
							var previousBid:int = 0;
							for (var i:int = 0; i < allLegitBids.length; i += 1) {
								if (previousBid == 0 || previousBid < allLegitBids[i].bid) {
									for (var j:int = 0; j < allLegitBids[i].bid - previousBid; j += 1) {
										var gap:int = 0;
										for each (var temp_p:Object in allLegitBids) {
											var temp_chip:TTCard = (temp_p.pot as TTBettingPersonalDock).getAChipFromBid(j+previousBid); // subseptible to lag?
											if (temp_chip) {
												stack_index_vertical_change(1);
												var receive_point:Point = receive_stacked(stack_index(), stack_index_vertical() * 2 + gap);
												// TODO: stack function that is More aware of chips in the pot already
												temp_chip.enqueueAndSendMove(area, receive_point.x, receive_point.y, true, false, true);
												//replaced by above code 5/26/2014
												//temp_chip.sendMove(temp_chip.area.area_id, temp_chip.x, temp_chip.y, area.area_id, receive_point.x, receive_point.y, false);
												if (j == 0) {
													playersIn += 1;
													playersInString += (temp_p.pot as TTBettingPersonalDock).playerName() + " ";
												}
											}
											gap += 2;
										}
									}
									if (stack_index() > 0 && (allLegitBids[i].bid - previousBid) * playersIn > 0) {
										TTSideConsole.write("Side Pot:");
									}
									if ((allLegitBids[i].bid - previousBid) * playersIn > 0) {
									TTSideConsole.writeln("$" + (allLegitBids[i].bid - previousBid) * playersIn + " from " + playersInString);
									}
									playersInString = "";
									playersIn = 0;	
									
								}
								stack_index_change(1);
								previousBid = allLegitBids[i].bid;
							}
							
							stack_index_change( -1);
							// This next line is a design choice. Since we want players to freely choose how much longer to play
							// a betting round, we do not dictate when the betting is over. Instead, we use a textual prompt
							// to indicate the decision is theirs to make.
							TTSideConsole.writeln("<font size='13' color='#616161'>What's next, <font color='#DD0000'>dealer</font>? Deal cards? Showdown?</font>");
							gameState = "DEALER_ACTION";
							decorDropCenter();
						}
						
						// NOW, LET'S MOVE TO THE NEXT ELIGIBLE PLAYER
						var advance_status:Object = new Object();
						advance_status.skippedTooMuchAndCouldNotFindAnEligibleNextPlayer = false;
						advance_status.skippedDealer = false;
						if (gameState == "WAITING_FOR_BID") advance_status = advancePlayer(1, currentPlayerPot);
						
						if (advance_status.skippedTooMuchAndCouldNotFindAnEligibleNextPlayer) {
							// we couldn't advance_status because NO ONE IS IN....
							TTSideConsole.writeln("<font size='12'>No players own any cards, assuming game is over.\n</font><font color='#555555'><b>Restarting Game.</b>\nWaiting for deal for the round to start.");
							stack_indices_reset();
							decorDropCenter();
							gameState = "DEALER_ACTION";
						} else if (advance_status.skippedDealer || dealerHasChecked) {
							if (high == 0) {
								TTSideConsole.writeln("<b>All players have checked.</b>");
								TTSideConsole.writeln("<font size='13' color='#616161'>What's next, <font color='#DD0000'>dealer</font>? Deal new cards? Showdown?</font>");
							
								var dealer_receive:Point = dealer.players_area.receive();
								//trace("moving: " + currentchip.area.area_id + " , " + currentchip.x+ " , " + currentchip.y+ " , " + dealer.players_area.area_id+ " , " + dealer_receive.x+ " , " + dealer_receive.y+ " ,.");
								currentchip.enqueueAndSendMove(dealer.players_area, dealer_receive.x, dealer_receive.y, true, false, true);
								//replaced by above code 5-27-2014
								//currentchip.sendMove(currentchip.area.area_id, currentchip.x, currentchip.y,  dealer.players_area.area_id, dealer_receive.x, dealer_receive.y, true);
								
								currentchip.setDragDecorText("DROP\nTO START\nBIDDING\nROUND", 0xFF0000);
								gameState = "DEALER_ACTION";
							} else if (dealerHasChecked) { 
								// There is a high bid greater than 0
								// The dealer has just checked (bid == 0)
								// The dealer is still in the game (he wasn't skipped)
								TTSideConsole.writeln("&nbsp;&nbsp;&nbsp;"+dealer.playerName() + " is <font color='#880000'><b>$" + String(high) + "</b> short. </font><font color='#999999' size='13'>What's going on?</font>");
							}
						}
						
						if (pot_total() == 0) {
							stack_indices_reset();
						}
					}

					if (current_player_has_changed_directly) {
						// do nothing. this is the player's choice.
					}
			}

		}
		
		/**
		 * Are the bids all even or is everyone all in? Used to calculate whether or not the bidding is finished.
		 * @return <code>true</code> if bidding round is over, else <code>false</code>
		 */
		public function bidsAreEvenOrAllIn():Boolean {			
			var high:int = calculateHighBid();
			var all_bids_called_or_all_in:Boolean = true;
			for each (var xx:TTBettingPersonalDock in personalPots) {
				// if player is in game
				if (xx.cardTotal() + xx.players_area.cardTotal() > 0) {
					if (xx.players_area.cashTotal() > 0) {
						// if player has the same high  bid
						all_bids_called_or_all_in = all_bids_called_or_all_in && xx.bidTotal() == high;
					} else {
						// this player could be all in.... if they have no money, but has cards.
					}
				}
			}	
			return all_bids_called_or_all_in;
		}
		
		/**
		 * Is there only one player left in the game?
		 * @return
		 */
		public function onePlayerLeft():TTBettingPersonalDock {
			var the_one:TTBettingPersonalDock = null;
			for each (var xx:TTBettingPersonalDock in personalPots) {
				// if player is in game
				if (xx.cardTotal() + xx.players_area.cardTotal() > 0) { //&&
					//xx.players_area.cashTotal() > 0) {
						if (the_one == null) {
							the_one = xx;
						} else {
							return null;
						}
				}
				
			}
			return the_one;
		}
		
		/**
		 * Number of players who are still "in"
		 * @return Number of player who are "in"
		 */
		public function numPlayersIn():int {
			var num:int = 0;
			for each (var xx:TTBettingPersonalDock in personalPots) {
				// if player is in game
				if (xx.cardTotal() + xx.players_area.cardTotal() > 0 &&
					xx.players_area.cashTotal() + xx.bidTotal() > 0) {
					num += 1;
				}
			}
			return num;
		}
		
		/**
		 * High bid
		 * @return Number, high bid
		 */
		public function calculateHighBid():int {
			var bids:Array = new Array();
			var high:int = 0;
			for each (var pp:TTBettingPersonalDock in personalPots) {
				if (pp.cardTotal() + pp.players_area.cardTotal() > 0) {// &&
					//pp.players_area.cashTotal() > 0) {
				high = Math.max(pp.bidTotal(), high);
				}
			}
			return high;
		}
		
		/**
		 * Distributes blinds (unused)
		 */
		public function distributeBlinds():void {
			// currently unused (10/2012)
			// small blind
			for each ( var chip:TTCard in this.fromArea(1, smallBlind.players_area) ) { // smallBlind.fromThisPot(1 /* this should be configurable in the future */)) {
				trace("DEPRECATED CODE BELOW, SHOULD ALSO INCLUDE ENQUEUE, SEE TTCard.enqueueAndSendMove");
				chip.sendMove(chip.area.area_id, chip.x, chip.y, smallBlind.central_area.area_id, smallBlind.receive.x, smallBlind.receive.y, true);
				smallBlind.addCard(chip);
			}
			
			TTSideConsole.write("\nSmall Blind from " +smallBlind.player_id);
			
			//check bigBlinder
			temp_stack.cards = this.fromArea(2, bigBlind.players_area);
			for each (var c:TTCard in temp_stack.cards) {
				bigBlind.addCard(c);
			}
			temp_point = bigBlind.central_area.localToGlobal(bigBlind.receive);
			temp_stack.stackSelected(temp_point, 8, 8, 1, false, 0, true);
			
			TTSideConsole.write("\nBig Blinds from" +bigBlind.player_id);
			for each (var pot:TTBettingPersonalDock in personalPots) {
				pot.checkIfDealer();
			}
			
			//updateLowerDisplay("high bid: " + calculateHighBid());
					
			
		}
		
		/**
		 * Stack point for receiving cards/chips
		 * @param	stackindex
		 * @param	yoffset
		 * @return
		 */
		public function receive_stacked(stackindex:int, yoffset:int = 0):Point {
			return new Point(receive.x + ((stackindex-1) * 30), receive.y+yoffset);
		}
		
		/**
		 * Get chips from pot up to a certain amount of money. (Unused atm)
		 * @param	upToAmount
		 * @param	area
		 * @return array of chips
		 */
		public function fromArea(upToAmount:int, area:TTArea):Array {
			var count:int = 0;
			var returnarray:Array = new Array();
			for each (var card:TTCard in area.cards) {
				if (count > upToAmount) {
					trace ("Returning too much money using fromArea. More sophisticated algorithm required.");
					break;
				}
				if (count == upToAmount) {
					break;
				}
				//element = pot[i] as TTCard;
				if (card.isCashChip()) {
					returnarray.push(card);
					count += Number(card.data);
				}
			}
			/*if (count < upToAmount) {
				trace ("Not enough money in the area");
			}*/
			return returnarray;
		}
		
		/**
		 * Distribute cards/chips according to a certain ratio among different areas (see initialization code for an example in this instance)
		 * e.g.:
		 * var divest:Array = fromPot(16);
		 *		if (divest.length == 16) {
		 *			distribute(divest, [tt.areas[1], tt.areas[2], tt.areas[3]], [1,1,2]);
		 *		}
		 * @param	cards
		 * @param	areas
		 * @param	ratios
		 */
		public function distribute(cards:Array, areas:Array, ratios:Array):void {
			if (areas.length != ratios.length) {
				trace("incorrect use");
			}
			
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
					5, 0, 0, false, 0, true);
					
			}			
		}
	}

}