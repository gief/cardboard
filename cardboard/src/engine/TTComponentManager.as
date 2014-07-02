package engine 
{
	import communicator.TTComm;
	import flash.geom.Point;
	import mx.core.UIComponent;
	import mx.core.FlexGlobals;
	
	/**
	 * Component Manager organizes and initializes the various 'smart' components such as the Betting Pot, th Personal Docks and the Community Zone.
	 * @author Gifford Cheung
	 */
	public class TTComponentManager extends UIComponent 
	{
		
		public var clear_radius:Number; // anything I don't own needs to be at least this far from me
		public var myArea:TTArea; // kill this?
		public var tt:TT = FlexGlobals.topLevelApplication.tt;
		public var comm:TTComm = FlexGlobals.topLevelApplication.tt.comm;
		public var owner_id:String;
		public var components:Array = [];
		public var cz:TTCommunityZone;
				
		public function TTComponentManager() 
		{
		}
		
		/**
		 * Starts the components
		 * @param	component_type
		 * @param	area_id
		 * @param	x
		 * @param	y
		 * @param	owner_id
		 */
		public static function startComponent(component_type: String, area_id: Number, x: Number, y: Number, owner_id: String):void {
			var component_id:String = Math.floor(Math.random() * 1000).toString();
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			var comm:TTComm = FlexGlobals.topLevelApplication.tt.comm;
			sendInitMessage(component_type, area_id, x, y, owner_id, component_id);
		}
		
		/**
		 * Sends the initial PLAYCOMPONENT message to the network.
		 * @param	component_type
		 * @param	area_id
		 * @param	x
		 * @param	y
		 * @param	owner_id
		 * @param	component_id
		 */
		public static function sendInitMessage(component_type: String, area_id: Number, x: Number, y: Number, owner_id: String, component_id:String):void {
			var message:Object = new Object();
			message.action = "PLAYCOMPONENT";
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();

			message.command = "init";
			message.component_type = component_type;
			message.area_id = area_id;
			message.x = x;
			message.y = y;
			message.owner_id = owner_id;
			message.component_id = component_id;
			
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
		}
		
		/**
		 * Processes the PLAYCOMPONENT messaged
		 * @param	component_type
		 * @param	area_id
		 * @param	x
		 * @param	y
		 * @param	owner_id
		 * @param	component_id
		 */
		public static function processInitMessage(component_type: String, area_id: Number, x: Number, y: Number, owner_id: String, component_id:String):void {
			if (component_type == "BettingPot" && owner_id != FlexGlobals.topLevelApplication.tt.myself_id) {
				FlexGlobals.topLevelApplication.menu_dealer.label = "Loaded.";
				FlexGlobals.topLevelApplication.menu_dealer.enabled = false;
			}
			if (component_type == "BettingPot" && owner_id == FlexGlobals.topLevelApplication.tt.myself_id) {
				var bp:TTBettingPot = new TTBettingPot(FlexGlobals.topLevelApplication.tt.getArea(area_id),
													new Point(x, y),
													owner_id);
													
				var _this:TTComponentManager = FlexGlobals.topLevelApplication.tt.game_components[owner_id];
				if (_this == null) { trace("ERROR: cannot find component under owner_id"); }

				
				var tt:TT = FlexGlobals.topLevelApplication.tt;
				
				// hard coded hack, sorry all
				var reference_area:TTArea = tt.areas[1];
				if (reference_area.area_id == area_id) { reference_area = tt.areas[2]; }
				trace(String(reference_area.w) + " reference area: " + reference_area.h);
								
				//look through players here
				// BRITTLE we need to run Dealer only ONCE after all the players are registered.
				var assignment:Array = new Array();
				
				for (var i:int = 0; i < 4; i += 1 ) {
					assignment[i] = ["South", "West", "North", "East"][i];
					/* old code that used to have player names associated with positions 
					if (i < tt.comm.all_players.length) {
						assignment[i] = tt.comm.all_players[i];
					} else {
						assignment[i] = "CPU" + String(i);
					}	
					*/
				}
				
				var central_area:TTArea = FlexGlobals.topLevelApplication.tt.getArea(area_id); // keeper
				var bpd:TTBettingPersonalDock;
				var bpds:Array = new Array();
				var previous:TTBettingPersonalDock;
				var first:TTBettingPersonalDock;
				var currentplayerdock:TTBettingPersonalDock;
				//south
				bpd = new TTBettingPersonalDock(	central_area,
													new Point(reference_area.h, reference_area.w-(reference_area.h * 2)),
													new Point(central_area.w, central_area.h),
													owner_id,
													assignment[0]);
				bpd.bettingPot = bp;
				_this.components.push( bpd );
				bpds.push(bpd);
				previous = bpd;
				first = bpd;
				
				//west
				bpd = new TTBettingPersonalDock(	central_area,
													new Point(0, reference_area.h),
													new Point(reference_area.h, central_area.h),
													owner_id,
													assignment[1]);
				bpd.bettingPot = bp;
				_this.components.push( bpd );
				bpds.push(bpd);
				previous.nextPlayerPot = bpd;
				previous = bpd;
				
				//north
				bpd = new TTBettingPersonalDock(	central_area,
													new Point(0, 0),
													new Point(reference_area.w - (reference_area.h * 2), reference_area.h),
													owner_id,
													assignment[2]);
				bpd.bettingPot = bp;
				_this.components.push( bpd );
				bpds.push(bpd);
				previous.nextPlayerPot = bpd;
				previous = bpd;
				
				//east
				bpd = new TTBettingPersonalDock(	central_area,
													new Point(reference_area.w - (reference_area.h * 2), 0),
													new Point(central_area.w, central_area.h - reference_area.h),
													owner_id,
													assignment[3]);
				bpd.bettingPot = bp;
				_this.components.push( bpd );
				bpds.push(bpd);
				previous.nextPlayerPot = bpd;
				bpd.nextPlayerPot = first;
				
				bp.setPersonalPots(bpds);
				currentplayerdock = _this.components[0]
				// Legacy code when components were assigned to names
				/*
				for each (var xx:TTBettingPersonalDock in bpds) {
					if (xx.player_id == tt.myself_id) currentplayerdock = xx;
				}
				*/
				
				_this.components.push( bp );
				bp.resetTable(currentplayerdock);
				
				_this.cz = new TTCommunityZone(FlexGlobals.topLevelApplication.tt.getArea(area_id),
					new Point(x + 82, y), 
					bpds,
					owner_id);
				
				_this.components.push(_this.cz);
			}
		}


	}

}