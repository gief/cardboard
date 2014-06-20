package engine 
{
	import mx.core.UIComponent;
	import engine.TTCardContainer;
	import flash.geom.Point;
	import mx.core.FlexGlobals;
	import net.houen.pokerface.AHand;
	
	import net.houen.cactuskev.PokerEval;
	import net.houen.cactuskev.PokerLib;
	import net.houen.pokerface.Card;
	import net.houen.pokerface.Deck;
	import net.houen.pokerface.Hand5;
	import net.houen.pokerface.Hand7;
	import net.houen.cactuskev.CactusArrays;

	
	/**
	 * Smart zone that keeps track of community cards according to the rules of Texas Hold'em
	 * @author Gifford Cheung
	 */
	public class TTCommunityZone extends UIComponent 
	{	
		public var area: TTArea;
		public var origin: Point;
		public var displaytext:Point;
		public var displayLines:Array = new Array();
		public var owner_id: String;
		
		public var personalPots:Array;
		
		public var tt:TT = FlexGlobals.topLevelApplication.tt;
		public var w:int;
		public var h:int;
		
		public var communitycards:Array; 

		
		public function TTCommunityZone(area:TTArea, origin:Point, personalPots:Array, owner_id:String)  
		{
			communitycards = new Array();
			this.personalPots = personalPots;
			this.area = area;
			this.origin = origin;
			this.owner_id = owner_id;
			this.w = 300;
			this.h = 135;
			this.displaytext = new Point(origin.x + Math.floor(this.w / 3), origin.y + this.h);
			drawSquare();
			tt.addChild(this);
			updateDisplay("", 0);
			updateDisplay("", 1);
			updateDisplay("", 2);
			updateDisplay("", 3);
		}
				
		/**
		 * Draw the square that deliniates this smart zone
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
		
		/**
		 * Event listener to watch for cards that move in and out of this Zone
		 * @param	card
		 * @param	moved_from
		 * @param	moved_from_area
		 */
		public function movedCardListener(card:TTCard, moved_from:Point, moved_from_area:TTArea):void {
			var wasInZone:Boolean = this.collidesWithCardAt(card, moved_from, moved_from_area);
			var isInZone:Boolean = this.collidesWithCardAt(card);
			
			// optimization
			if (card.isChip) return;
			
			//TTSideConsole.writeln("wiZ" + String(wasInZone) + " isZ" + String(isInZone));
			
			if (wasInZone || isInZone) { // this means a card moved in or out of the pot
				if (isInZone) {
					addCard(card);
				} else {
					removeCard(card);
				}
				updateAnalysis();
			}
		}
		
		/**
		 * Event listener to watch for flipped cards 
		 * @param	card
		 */
		public function flippedCardListener(card:TTCard):void {
			if (card.area.area_id == this.area.area_id) {
				updateAnalysis();				
			}
		}
		
		
		/**
		 * Runs the cactusKev analysis for a 5 card hand
		 * @param	c1
		 * @param	c2
		 * @param	c3
		 * @param	c4
		 * @param	c5
		 * @return Hand5 score
		 */
		public function h5(c1:TTCard, c2:TTCard, c3:TTCard, c4:TTCard, c5:TTCard):Hand5 {
			return new Hand5([c1.cactusKevEncoding, c2.cactusKevEncoding, c3.cactusKevEncoding, c4.cactusKevEncoding, c5.cactusKevEncoding]);
		}

		/**
		 * Runs the catus Kev encoding for a 7 card hand
		 * @param	c1
		 * @param	c2
		 * @param	c3
		 * @param	c4
		 * @param	c5
		 * @param	c6
		 * @param	c7
		 * @return Hand7 analysis
		 */
		public function h7(c1:TTCard, c2:TTCard, c3:TTCard, c4:TTCard, c5:TTCard, c6:TTCard, c7:TTCard):Hand7 {
			return new Hand7([c1.cactusKevEncoding, c2.cactusKevEncoding, c3.cactusKevEncoding, c4.cactusKevEncoding, c5.cactusKevEncoding, c6.cactusKevEncoding, c7.cactusKevEncoding]);
		}
		
		
		/**
		 * Analyses 5 or 7 card hands across the smart zone and the player's personally displayed cards when 
		 * cards are displayed as in during a showdown.
		 */
		public function updateAnalysis():void {

			//var i:int = 0;
			var j:int = 0;
			var p_index:int = 0;
			var up:Array = [];
			for each (var c:TTCard in communitycards) {
				//TTSideConsole.writeln(String(i) + " " + String(c.front) + " " + String(c.cactusKevEncoding));
				if (!c.isChip && c.face_up) {
					up[j] = c;
					j += 1;
				}
				//i += 1;
			}
			//var i_save:int = i;
			var j_save:int = j;
			for each (var p_p:TTBettingPersonalDock in this.personalPots) {
				j = j_save;
				for each (var c_c:TTCard in p_p.pot) {
					if (!c_c.isChip && c_c.face_up) {
						up[j] = c_c;
						j += 1;
					}
				}
				
				
				if (j == 5) {
					p_p.pokerHand = h5(up[0], up[1], up[2], up[3], up[4]);
					p_p.pokerCategory = p_p.pokerHand.category;
					updateDisplay(p_p.player_id + ":" + String(p_p.pokerHand.category) + ", " + String(p_p.pokerHand.strength) + "", p_index);
				} else if (j == 7) {
					p_p.pokerHand = h7(up[0], up[1], up[2], up[3], up[4], up[5], up[6]);
					updateDisplay(p_p.player_id + ":" + String(p_p.pokerHand.category) + ", " + String(p_p.pokerHand.strength) + "" , p_index);
					//TTSideConsole.writeln(p_p.player_id + ":" + String(p_p.pokerHand.category) +", " + String(p_p.pokerHand.strength));
				} else {
					updateDisplay(p_p.player_id + ", " + j + " card" + (j==1?"":"s"), p_index);
				}
				
				p_index += 1;
			}			
		}
		
		/**
		 * Semantically add a card to this zone
		 * @param	card
		 */
		public function addCard(card:TTCard):void {
			if (communitycards.indexOf(card) == -1) {
				communitycards.push(card);
			}
		}
		
		/**
		 * Semantically remove a card from this zone
		 * @param	card
		 */
		public function removeCard(card:TTCard):void {
			communitycards.splice(communitycards.indexOf(card), 1);
		}
		
		/**
		 * Update the textual display on this zone
		 * @param	text - Text to update
		 * @param	line - Line numbr to edit
		 */
		public function updateDisplay(text:String, line:int = 0):void {
			displayLines[line] = text;
			var alltext:String = "";
			for (var i:int = 0; i < displayLines.length; i += 1 ) {
				alltext += displayLines[i] + "\n";
			}
			var location:Point = tt.globalToLocal(this.area.localToGlobal(displaytext));
			tt.visual_effect_layer.writePermenaText(tt.comm.about_all_players[owner_id].permenalabel, "cz", alltext, location.x, location.y, 0);
		}
		
		/**
		 * Collision detection: card.
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
		 * Collision detection, point.
		 * @param	p
		 * @return
		 */
		public function pointInside(p:Point):Boolean {
			// someday create a base class for BettingPot, CommunityZone, and Personal Betting Pot
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
		
	}

}