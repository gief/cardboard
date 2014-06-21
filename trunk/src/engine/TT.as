package engine 
{

	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;
	import communicator.TTComm;
	import mx.controls.TextInput;
	import mx.core.Application;
	import flash.system.Security;
	import mx.core.FlexTextField;
	import mx.core.UIComponent;
	import com.adobe.crypto.SHA1;
	import console.TTGamePresets;
	import mx.core.FlexGlobals;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.filters.GlowFilter;

	/**
	 * Main class for Card Board. The name TT is left over from "Table Top", the old name for the software.
	 * 
	 * @author Gifford Cheung
	 */
		
	public class TT extends Canvas
	{
		[Embed(source = "../fonts/PTC55F.ttf", fontFamily = "PT Sans Caption", embedAsCFF="false", mimeType="application/x-font")]
		public var ptsanscaption :Class;

		public var game_id:String;
		public var game_name:String;
		public var owner_id:Number;
		public var updatetime:String;
		public var areas:Array = new Array(); 
		public var myself_id:String;
		public var myself_password:String;
		public var server:String = "127.0.0.1";
		public var server_player_id:String;
		public var room:String;
		public var card_mover:TTCardMover;
		public var precalculated_width:Number;
		public var precalculated_height:Number;
		public var comm:TTComm;
		public var visual_effect_layer:TTVisualEffects;
		private var mouse_has_dragged:Boolean;
		public var gameHasBeenLoaded:Boolean = false;
		public var game_components:Array = new Array(); 
		public var global_action_point:Point; // global location for the action point like shuffling
		public var global_text_format:TextFormat = new TextFormat();
		public var selectedCards:TTCardContainer = new TTCardContainer();
      
		
		public function TT() 
		{
			super();
			
			this.card_mover = new TTCardMover;
			TTCardMover.mover = this.card_mover;
			addChild(this.card_mover);
			this.card_mover.x = 0;
			this.card_mover.y = 0;
			this.mouse_has_dragged = false;
			
			// right mouse click menu
			var right_menu:ContextMenu = new ContextMenu();
			right_menu.addEventListener(ContextMenuEvent.MENU_SELECT, menuHasAppeared);
			
			var cmi:ContextMenuItem;
			
			//flip up
			cmi = new ContextMenuItem("Flip up");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, flipUp);
			right_menu.customItems.push(cmi);
			
			//flip down
			
			cmi = new ContextMenuItem("Flip down");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, flipDown);
			right_menu.customItems.push(cmi);
			
			
			// Shuffle
			cmi = new ContextMenuItem("Shuffle Cards");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, shuffle);
			right_menu.customItems.push(cmi);
			
			// Stack Selected Cards
			cmi = new ContextMenuItem("Stack Cards");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, stackSelected);
			right_menu.customItems.push(cmi);
						
			// Spread Cards 
			cmi = new ContextMenuItem("Spread Cards");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, spreadTight);
			right_menu.customItems.push(cmi);

			cmi = new ContextMenuItem("-- Column");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, spreadVertical);
			right_menu.customItems.push(cmi);
			
			
			// Spread Cards [tight]
			cmi = new ContextMenuItem("-- Row");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, spreadTight);
			right_menu.customItems.push(cmi);
			
			/*
			// Spread Cards [loose]
			cmi = new ContextMenuItem("Spread Cards [loose]");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, spreadLoose);
			right_menu.customItems.push(cmi);
			*/
			
			// Stack Vertical 
			cmi = new ContextMenuItem("Chip stack");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, stackChips);
			right_menu.customItems.push(cmi);
			
						
			// Select All
			cmi = new ContextMenuItem("Select All Cards");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectAll);
			right_menu.customItems.push(cmi);
			
			// Select None
			
			cmi = new ContextMenuItem("- Cards Only");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectCardsOnly);
			right_menu.customItems.push(cmi);
			
			cmi = new ContextMenuItem("- Chips Only");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectChipsOnly);
			right_menu.customItems.push(cmi);
			
			
			cmi = new ContextMenuItem("Select None");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, selectNone);
			right_menu.customItems.push(cmi);
			
			
			// Toggle View
			cmi = new ContextMenuItem("Toggle view of this area");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleView);
			right_menu.customItems.push(cmi);
			
			// Toggle Ownership
			cmi = new ContextMenuItem("Toggle ownership of this area");
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleOwner);
			right_menu.customItems.push(cmi);

			
			this.contextMenu = right_menu;
			right_menu.hideBuiltInItems();
			global_text_format = new TextFormat();
			global_text_format.size = 15;
			global_text_format.leading = -4;// font spacing?
			global_text_format.kerning = -9; 
			global_text_format.color = 0x000;
			global_text_format.font = "PT Sans Caption";
		}
		

		/**
		 * Continued initialization code that runs after a game has been loaded. 
		 * Initializes the visual effects layer.
		 */
		public function initAfterLoadedGame():void {
			if (!this.visual_effect_layer) {
				this.visual_effect_layer = new TTVisualEffects();
			}
			this.addChild(this.visual_effect_layer);
			gameHasBeenLoaded = true;
			
			visual_effect_layer.reloadPermenaRegistration(comm.about_all_players);
			
			this.stage.frameRate = 60;
		}
		
		/**
		 * Generate a game ID
		 * @return A random string for use as a game id
		 */
		public function generateGameId():String {
			return SHA1.hash(new Date().toUTCString() + Math.random().toString()).substr(0,2);
		}
		
		/**
		 * For rotating the entire game system properly. Resets a rotation value that is greater than 360 degrees to a number below that.
		 * Ensure that small rounding errors do not skew the rotation of the board.
		 */
		public function recenterAfterRotation():void {
			this.rotation = rotation % 360;			
			//var w:Number = this.precalculated_width;
			//var h:Number = this.precalculated_height;
			var w:Number = this.width;
			var h:Number = this.height;
			//trace("rotation?: " + rotation);
			switch (this.rotation) {
				case 0:
					this.parent.x = 0;
					this.parent.y = 0;
					break;
				case 90:
					this.parent.x = w;
					this.parent.y = 0;
					
					break;
				case 180:
					this.parent.x = w;
					this.parent.y = h;
					break;
				case -90:
					this.parent.x = 0;
					this.parent.y = h;
					break;
			}
		}
		
		/**
		 * Context menu action: flip cards
		 * @param	evt
		 */
		public function flipCards(evt:ContextMenuEvent):void {
			selectedCards.flipCards();
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: flip cards up
		 * @param	evt
		 */
		public function flipUp(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.flipUp();
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: flip cards down
		 * @param	evt
		 */
		public function flipDown(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.flipDown();
			menuDisappearCallback();
		}
		
		/**
		 * Eventhandler for the appearance of a menu that will
		 * identify the global action point and
		 * disable mouse cursor tracking for the visual effect layer
		 * @param	evt
		 */
		public function menuHasAppeared(evt:ContextMenuEvent):void {
			var ttMouseTarget:Point = this.globalToLocal(evt.mouseTarget.localToGlobal(new Point(evt.mouseTarget.mouseX, evt.mouseTarget.mouseY)));
			if (gameHasBeenLoaded) this.visual_effect_layer.queueAnimatedPing("myping", ttMouseTarget.x, ttMouseTarget.y, 7.0); // setting the alpha to a high number (e.g. 7.0) will make this dot appear for a longer period of time which fits for the rightmouse menu
			if (gameHasBeenLoaded) this.visual_effect_layer.sendPing(FlexGlobals.topLevelApplication.tt.myself_id + "ping" /*hardcoded ping label*/, ttMouseTarget.x, ttMouseTarget.y);
			
			this.onMouseUp(new MouseEvent(MouseEvent.MOUSE_UP, true, false, evt.mouseTarget.mouseX, evt.mouseTarget.mouseY));
			this.global_action_point = evt.mouseTarget.localToGlobal(new Point(evt.mouseTarget.mouseX, evt.mouseTarget.mouseY));
			//TODO: draw a target... to be erased when an event has fired.
			if (visual_effect_layer) {
				this.visual_effect_layer.pauseTracking();
			}
		}
		
		/**
		 * Eventhandler for the disappearance of the right-click menu 
		 * that will resume mouse tracking
		 */
		public function menuDisappearCallback():void {
			this.visual_effect_layer.unpauseTracking();
		}
		
		/**
		 * Context menu action: shuffle
		 * @param	evt
		 */
		public function shuffle(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.shuffle();
			selectedCards.stackSelected(global_action_point, 0, 2, 1, true, TTCardContainer.FLIP_DOWN); 
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: stack cards
		 * @param	evt
		 */		
		public function stackSelected(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.stackSelected(global_action_point,0,2);
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: spread cards out vertically
		 * @param	evt
		 */
		public function spreadVertical(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.stackSelected(global_action_point,0,14);	
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: Spread cards out horizontally with 12 px between each card
		 * Maintains the order of cards selected
		 * @param	evt
		 */		
		public function spreadTight(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.stackSelected(global_action_point,12,0);	
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action Spread cards out horizontally with 25 px between each card
		 * Maintains the order of cards selected
		 * @param	evt
		 */
		public function spreadLoose(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			selectedCards.stackSelected(global_action_point,25,0);
			menuDisappearCallback();
		}
		
		/**
		 * Context menu item: Stack chips nicely
		 * @param	evt
		 */
		public function stackChips(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCashChips(true);
			selectedCards.stackSelected(global_action_point, 0, 4,0,false,0,false,10);
			menuDisappearCallback();
		}
		
		/**
		 * Context menu item: Toggle player's view of the private cards in an area
		 * @param	evt
		 */
		public function toggleView(evt:ContextMenuEvent):void {
			// get Area
			for each (var area:TTArea in areas) {
				if (area.collidesWith(global_action_point.x, global_action_point.y)) {
					if (area.canView(myself_id)) {
						area.removeViewer(myself_id); 
						TTSideConsole.writeln(myself_id + " is no longer viewing area: " + area.area_id);
					} else {
						area.addViewer(myself_id);
						TTSideConsole.writeln(myself_id + " is viewing area: " + area.area_id);
					}
				}
			}
			menuDisappearCallback();
		}
		
		/**
		 * Context menu action: Claim or relinquish ownernship of an area
		 * @param	evt
		 */
		public function toggleOwner(evt:ContextMenuEvent):void {
			// get Area
			for each (var area:TTArea in areas) {
				if (area.collidesWith(global_action_point.x, global_action_point.y)) {
					if (area.owner_id == myself_id) {
						area.setOwnerId("-1");
						TTSideConsole.writeln(myself_id + " relinquished ownership of: " + area.area_id);
					} else {
						area.setOwnerId(myself_id);
						area.sendNewAreaOwner(myself_id);
						TTSideConsole.writeln(myself_id + " took ownership of: " + area.area_id);
					}
				}
			}
			menuDisappearCallback();
		}
		
		/** 
		 * Context menu item: Select all cards
		 */ 
		public function selectAll(evt:ContextMenuEvent):void {
			selectedCards.resetSelection();
			for each (var area:TTArea in areas) {
				for each (var card:TTCard in area.cards) {
					if (!card.isChip) {	
						selectedCards.addCard(card);
						card.showSelected();
					}
				}
			}
			menuDisappearCallback();
		}
		
		/**
		 * Context menu item: select nothing.
		 * @param	evt
		 */
		public function selectNone(evt:ContextMenuEvent):void {
			selectedCards.resetSelection();
			menuDisappearCallback();
		}
		
		/**
		 * Context menu item: deselect non cards from the current selection 
		 * @param	evt
		 */
		public function selectCardsOnly(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCards(true);
			menuDisappearCallback();
		}
		
		/**
		 * Context menu item: deselect non chips from the current selection
		 * @param	evt
		 */
		public function selectChipsOnly(evt:ContextMenuEvent):void {
			selectedCards.filterContainerRemoveNonCashChips(true);
			menuDisappearCallback();
		}
		
		public var selectionBoxDragging:Boolean = false;
		public var box:TTSelectionBox = new TTSelectionBox();
		public var box_text_container:UIComponent = new UIComponent();
		public var box_text:FlexTextField = new FlexTextField();
		
		
		public static var ctrlDown:Boolean = false;
		public static var shiftDown:Boolean = false;
		
		/**
		 * Fired when keyboardevent for key up fires
		 * Currenlty toggles the variable for tracking the Ctrl and Shift buttons
		 * @param	evt
		 */
		public function onKeyUp(evt:KeyboardEvent):void {
			TT.ctrlDown = evt.ctrlKey;
			TT.shiftDown = evt.shiftKey;
		}
		
		/**
		 * Fired when keyboardevent for key down fires.
		 * Toggles variable for tracking Ctrl & Shift buttons. 
		 * and activates certain keyboard shortcuts such as "F"/"Space bar" for flipping a card or "R" for rotation
		 * @param	evt
		 */
		public function onKeyDown(evt:KeyboardEvent):void {			
			TT.ctrlDown = evt.ctrlKey;
			TT.shiftDown = evt.shiftKey;
			var selectedCards:TTCardContainer = FlexGlobals.topLevelApplication.tt.selectedCards;
			if (evt.keyCode == 192) { // tilde
				FlexGlobals.topLevelApplication.ttcomponent.visible = !mx.core.FlexGlobals.topLevelApplication.ttcomponent.visible;
			} else if (evt.keyCode == 32 || evt.keyCode == 70) {
				selectedCards.flipCards();
			} else if (evt.keyCode == 82 && !selectedCards.readyToDrag && !selectedCards.isDragging) {
				selectedCards.rotateCards();
			}
		}
		
		/**
		 * fires when mouse click is released.
		 * Handles selection box and related mouse dragging activity
		 * @param	evt
		 */
		public function onMouseUp(evt:MouseEvent):void {
		//trace("Canvas.Mouse UP " + "evnt:" + evt.toString());
			if (selectedCards.cards.length > 0) {
				selectedCards.onMouseUp(evt);
			}
			
			if (selectionBoxDragging) {
				selectionBoxDragging = false;
				box.init = false;
				box.visible = false;
				box_text_container.visible = false;
			}
			if (!mouse_has_dragged) {
				// something?
			}
			mouse_has_dragged = false;
		}
		
		/**
		 * Fires when mouse buttone is pressed down within the main tt area.
		 * Handles drawing a selection box.
		 * @param	evt
		 */
		public function onMouseDown(evt:MouseEvent):void {
			//if (gameHasBeenLoaded && TT.shiftDown) this.visual_effect_layer.queueAnimatedPing("myping", this.mouseX, this.mouseY, 1.00);
			if (gameHasBeenLoaded) this.visual_effect_layer.queueAnimatedPing("myping", this.mouseX, this.mouseY, 1.0);
			if (gameHasBeenLoaded) this.visual_effect_layer.sendPing(FlexGlobals.topLevelApplication.tt.myself_id + "ping" /*hardcoded ping label*/, this.mouseX, this.mouseY);
			if (!TT.ctrlDown) {
				selectedCards.resetSelection();
			}
			selectionBoxDragging = true;
			if (gameHasBeenLoaded) this.visual_effect_layer.unpauseTracking();
			
			if (this.visual_effect_layer) {
				this.visual_effect_layer.unpauseTracking();
			}
			
			// stage.focus = FlexGlobals.topLevelApplication.tt;
		}
		
		
		/**
		 * Fires when a mouse moves.
		 * Handles selection box drawing and moving a set of selected items
		 * @param	evt
		 */
		public function onMouseMove(evt:MouseEvent):void {
			if (selectionBoxDragging) {
				mouse_has_dragged = true;
				
				if (!box.init) {
					// initialize the selectinbox
					this.addChild(box);
					box.visible = true;
					box.init = true;
					box.x = this.mouseX;
					box.y = this.mouseY;
					box_text_container.addChild(box_text);
					box_text_container.visible = true;
					box_text.visible = true;
					box_text_container.x = box.x;
					box_text_container.y = box.y;
					box_text.width = 200;
					box_text.x = 0;	
					box_text.y = 0;
					box_text.rotation = -rotation;
					box_text.filters = [new GlowFilter(0xFFFFFF, 1, 16, 16, 2, 1, false, false)];
					var format:TextFormat = box_text.getTextFormat();
					format.size = 23;
					format.color = 0x000;
					format.font = "PT Sans Caption";
					
					
					box_text.embedFonts = true;
					box_text.defaultTextFormat = format;
					box_text.antiAliasType = "advanced";
				}
				this.addChild(box_text_container);
					
				box.w = this.mouseX - box.x;
				box.h = this.mouseY - box.y;
				box.draw();
				// check collision
				selectedCards.resetSelection();
				for each (var area:TTArea in areas) {
					for each (var card:TTCard in area.cards) {
						if (box.hits(card)) {
							selectedCards.addCard(card);
							card.showSelected();
						}
					}
				}
				
				var numSelectedCards:Number = 0;
				var chipTotal:Number = 0;
				for each (var c:TTCard in selectedCards.cards) {
					if (c.isCashChip()) {		
						chipTotal += Number(c.data);
					} 
					
					if (!c.isChip) {
						numSelectedCards += 1;
					}
				}
				box_text.text = "";
				if (numSelectedCards == 1) { 
					box_text.text = numSelectedCards.toString() + " card"; 
				} else if (numSelectedCards > 1) {	
					box_text.text = numSelectedCards.toString() + " cards";
				}
				if (chipTotal) { 
					if (numSelectedCards) box_text.text += ", ";
					box_text.text += "$" + chipTotal.toString();
				}
			} else {
				// you might be moving the selected cards.
				// let selectedCards handle this.
				selectedCards.onMouseMove(evt);
			}
		}
		
		/**
		 * Retrieves an area 
		 * @param	_area_id the id to search for
		 * @return
		 */
		public function getArea(_area_id:int):TTArea {
			for each (var area:TTArea in areas) {
				if (area.area_id == _area_id) return area;
			}
			return null;
		}
		
		/**
		 * Retrieves a card. Searches the expected area first, if no hits, then runs an exhaustive search of all areas.
		 * @param	area_id the expected area where the card is
		 * @param	card_id the card id
		 * @return the sought card or <code>null</code>
		 */
		public function getCard(area_id:int, card_id:int):TTCard {
			
			for each (var area:TTArea in areas) {
				if (area.area_id == area_id) {
					return area.cards[card_id];
				}
			}
			
			//trace("search by area failed. Using exhausive search");
			for each (area in areas) {
				if (area.cards[card_id]) return area.cards[card_id];
			}
			
			return null;
		}
		
		/**
		 * Drops areas and cards from this game.
		 */
		public function dropAreasAndCards():void {
			for each (var area:TTArea in this.areas) {
				for each (var card:TTCard in area.cards) {
					area.removeCard(card);
					area.removeChild(card);
				}
				this.removeChild(area);
			}
			this.areas = new Array();
		}
		
		/**
		 * Loads a game's metadata (will overwrite an existing game with the new metadata)
		 * @see initAfterLoadedGame
		 * @param	json_encoded_game
		 */
		public function loadOrReloadGame(json_encoded_game: String):void {
			
			var game:Object = JSON.parse(json_encoded_game);
			// we have access to: owner, updatetime, id, and name
			owner_id = game.owner_id;
			updatetime = game.updatetime;
			//game_id = game.id;
			game_name = game.name;
			
			
			this.initAfterLoadedGame();
		}
		
		/**
		 * loads areas. If an area_id already exists, it will modify that area to fit the new input.
		 * @param	json_encoded_areas
		 */
		public function loadAreas(json_encoded_areas: String):void {
			var areas:Object = JSON.parse(json_encoded_areas);
			//this.dropAreasAndCards();
			var existingAreaIndex:int = -1;
			for each (var area:Object in areas) {
				for (var i:int = 0; i < this.areas.length; i += 1 ) {
					if (this.areas[i].area_id == area.id) {
						existingAreaIndex = i;
						break;
					}
				}
			
				//trace(area.id);
				var areaToUpdate:TTArea;
				if (existingAreaIndex > -1) {
					// modify the existing area
					areaToUpdate = this.areas[existingAreaIndex];
					areaToUpdate.w = area.w;
					areaToUpdate.h = area.h;
				} else {
					// add a new area
					areaToUpdate = new TTArea(area.w, area.h);
					areaToUpdate.area_id = area.id;
					this.areas.push(areaToUpdate);
				}
				
				areaToUpdate.x = area.x;
				areaToUpdate.y = area.y;
				areaToUpdate.rotation = area.r;
				if (area.owner != undefined) {
					areaToUpdate.owner_id = area.owner;
				} else {
					areaToUpdate.owner_id = "-1";
				}
				areaToUpdate.render();
				this.addChildAt(areaToUpdate, this.numChildren);
				loadCards(area.id);
			}
		}
		
		/**
		 * load cards. Will overwrite and move card that have the existing card_id
		 * @param	json_encoded_cards
		 */
		public function loadCards(json_encoded_cards: String):void {
			var cards:Object = JSON.parse(json_encoded_cards);
			var ttCard:TTCard;
			
			for each (var card:Object in cards) {
				ttCard = getCard(card.area_id, card.card_id);
				if (ttCard) {
					ttCard.back = card.back;
					ttCard.front = card.front;
					ttCard.face_up = card.face_up;
					ttCard.data = card.data;
					ttCard.isChip = card.isChip;
					ttCard.chipColor = card.chipColor; 
					ttCard.w = (card.w ? card.w : ttCard.w ); // default width
					ttCard.halfw = (card.halfw ? card.halfw : ttCard.halfw );
					ttCard.h = (card.h ? card.h : ttCard.h );
					ttCard.halfh = (card.halfh ? card.halfh : ttCard.halfh);
					ttCard.processRotatedCard(card.r);
					ttCard.processMovedCard(card.x, card.y, card.area_id);
				}  else {
					ttCard = new TTCard();
					ttCard.back = card.back;
					ttCard.front = card.front;
					ttCard.rotation = card.r;
					ttCard.x = card.x;
					ttCard.y = card.y;
					ttCard.face_up = card.face_up;
					ttCard.data = card.data;
					ttCard.card_id = card.card_id;
					ttCard.isChip = card.isChip;
					ttCard.chipColor = card.chipColor; 
					ttCard.w = (card.w ? card.w : ttCard.w ); // default width
					ttCard.halfw = (card.halfw ? card.halfw : ttCard.halfw );
					ttCard.h = (card.h ? card.h : ttCard.h );
					ttCard.halfh = (card.halfh ? card.halfh : ttCard.halfh) ;
					if ( card.area_id != null ) {
						for (var i:int = 0; i < this.areas.length; i += 1 ) {
							//trace("check: " + this.areas[i].area_id + " cid:" + card.area_id);
							if (this.areas[i].area_id == card.area_id) {
								ttCard.area = this.areas[i];
								this.areas[i].addCard(ttCard);
								break;
							}
						}
					} else {
						trace("errr didn't expect this.?");
					}
					ttCard.initCardAfterSnapshot();
					ttCard.drawFace(ttCard.face);
				}
			}
			
			var ttArea:TTArea;
			for each (card in cards) {
				if ( card.area_id != null && card.parent_card_id != null) {
					ttArea = this.areas[card.area_id];
					ttCard = ttArea.cards[card.id];
				}
			}
		}
		
		/**
		 * Connect to a game as a client.
		 * @param	username
		 * @param	password
		 * @param	server_address
		 * @param	game_room
		 * @param	server_player_id
		 */
		public function connectAsClient(username:String, password:String, server_address:String, game_room:String , server_player_id: String):void {
			myself_id = username;
			myself_password = password;
			this.server_player_id = server_player_id;
			comm.all_players = new Array (server_player_id); 
			server = server_address;
			game_id = game_room;			
			room = "ttroom" + game_room;
			comm.initLANConnection();
			//comm.initXMPPConnection();
			comm.broadcastHello(/*Suggested Ping Color = */FlexGlobals.topLevelApplication.cbColor.selectedColor);
			
		}
		
		/**
		 * Start a game server and be the game server
		 * @param	username
		 * @param	password
		 * @param	server_address
		 */
		public function startAsServer(username:String, password:String, server_address:String):void {
			if (false) {
				//TODO
				game_id = generateGameId();
			}
			//trace("Game id is now: " + game_id);
			
			game_id = FlexGlobals.topLevelApplication.cbGameRoom.text;
			//FlexGlobals.topLevelApplication.cbGameRoom.text = game_id;
			
			//set player
			myself_id = username;
			
			//reset player list (just myself as the server)
			server_player_id = username;
			(FlexGlobals.topLevelApplication.cbPlayerServerId as TextInput).text = username;
			comm.all_players = [myself_id];
			comm.about_all_players[myself_id] = new Object();
			
			// Trails and pings
			var traillabel:String =  myself_id + "localtraillabel";
			var pinglabel:String =  myself_id + "localpinglabel";
			var permenalabel:String =  myself_id + "localpermenalabel";
			
			comm.about_all_players[ myself_id]["traillabel"] =   traillabel;
			comm.about_all_players[ myself_id]["pinglabel"] =   pinglabel;
			comm.about_all_players[ myself_id]["trailcolor"] =  0x000;
			comm.about_all_players[ myself_id]["pingcolor"] =  0x000;
			comm.about_all_players[ myself_id]["permenalabel"] = permenalabel;
			comm.about_all_players[ myself_id]["self_id"] = myself_id;
			
			
			//set password
			myself_password = password;
			
			//set server
			server = server_address;
			trace("server: " + server);
			room = "ttroom" + game_id;
			
			if (true) { // in the future, this can be more dynamic or user-configured.
				loadOrReloadGame(TTGamePresets.g1);
				loadAreas(TTGamePresets.a1);
				loadCards(TTGamePresets.c1);
			}
			comm.initLANConnection();
			comm.broadcastHello(/*Suggested Ping Color = */FlexGlobals.topLevelApplication.cbColor.selectedColor);
			
		}
		
		/**
		 * Takes a snapshot of the game
		 * @return Generic object containing the game, areas, and cards 
		 */
		public function getSnapshot():Object {
			// stub return array of g, a, c
			
			var g:Object =  {   
				"game_id": game_id, "name": game_id, "owner_id": myself_id };
			var a:Array = [];
			var c:Array = [];
			
			for each (var area:TTArea in areas) {
				a.push( {   "h":area.h, 
							"r":area.rotation, 
							"w":area.w, 
							"y":area.y, 
							"x":area.x,
							"owner": area.owner_id,
							"id":area.area_id } );
				
				for each (var card:TTCard in area.cards) {  // TODO full chips info
					c.push( { 	"area_id":area.area_id, 
								"card_id":card.card_id, 
								"data":card.data, 
								"face_up": card.face_up, 
								"y": card.y, 
								"x": card.x,
								"r": card.rotation,
								"front": card.front,
								"back": card.back,
								"isChip": card.isChip,
								"chipColor": card.chipColor,
								"w": card.w,
								"halfw": card.halfw,
								"h": card.h,
								"halfh": card.halfh
								} );
				}
			}
			
			return { "Game":g, "Areas":a, "Cards": c };
		}
	}

}