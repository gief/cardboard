package engine 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import mx.core.FlexTextField;
	
	import mx.core.FlexGlobals;
	import flash.events.Event;
	import mx.core.UIComponent;
	import flash.filters.GlowFilter;
	
	/**
	 * Draw visual effects like ephemeral pings (non-reviewable, synchronous).
	 * 
	 * @author Gifford Cheung
	 */
	public class TTVisualEffects extends UIComponent
	{
		// this is the stuff that's there, the basic layer
		public var permena:Array = new Array(); // everything here will stay unless deleted
		public var ephemera:Array = new Array(); // everything here will be slowly faded away (e.g. alpha = alpha - 0.1)
		
		// this is an abstraction of the stuff that's there
		public var pings:Array = new Array();
		public var trails:Array = new Array();
		public var lastTrail:Vector.<Point> = new Vector.<Point>(3);
		public var permen_instructions:Array = new Array();
		public var permena_texts:Array = new Array();
		
		public var tracking:Boolean = false;
		
		// this regulates the visual updates
		private var timer:int = 0;
		
		public static var defaultPingSize:int = 15;
		
		public function TTVisualEffects() 
		{
			this.mouseEnabled = false; 
			this.mouseChildren = false;
			this.mouseFocusEnabled = false;
		}
		
		/**
		 * Stop tracking the mouse
		 */
		public function pauseTracking():void {
			this.tracking = false;
		}
		
		/**
		 * Continue tracking the mouse
		 */
		public function unpauseTracking():void {
			this.tracking = true;
		}

		/**
		 * enter frame handler: draws shadows, pings, text and other effets.
		 * @param	e
		 */
		public function enterFrameHandler(e:Event):void {
			// bring permena layer to top
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			if (tt.getChildAt(tt.numChildren -1) != this) {
				tt.addChild(this);
			}
			
			timer = (timer + 1) % 4;
			
			var i:int = 0;
			
			for (var trail_id:String in trails) {
				var trail_set:Vector.<Point> = trails[trail_id]["Vectors"];
				if (
					trails[trail_id]["last"][0] == trail_set[0] &&
					trails[trail_id]["last"][1] == trail_set[1] &&
					trails[trail_id]["last"][2] == trail_set[2]
					)
				break;
				tt.addChild(this);
				var trail_ephem:Sprite = ephemera[trail_id];

				trail_ephem.x = trail_set[0].x;
				trail_ephem.y = trail_set[0].y;
				trail_ephem.rotation = 360-tt.rotation;

			}
						
			var ping_set:Array = pings.pop();
			if (ping_set) {
				for each (var ping:Object in ping_set) {
					FlexGlobals.topLevelApplication.tt.addChild(this);
					if (ephemera[ping.circleshadow_id]) {
							var s:Sprite = ephemera[ping.circleshadow_id];
							s.x = ping.x; // +5; // alternative to mouseEnabled=false
							s.y = ping.y; // +5;
							s.alpha = ping.alpha;
					}
				}				
			}
			
			// PING FADER
			// KLUDGY, ASSUMING A hardcoded NAME FOR EACH PING
			/* slows performance? */
			for (var id:String in ephemera) {
				if ( id.substr(id.length-4, 4) == "ping" && ephemera[id].alpha > 0) {
					ephemera[id].alpha = ephemera[id].alpha - 0.08;
				}
			}
			
			
			if (trails["mymouseshadow"] 
				//&& timer == 0 
				&& this.tracking) { 
				//condition to draw this mouse location 
				this.enqueueTrailPoint("mymouseshadow", this.mouseX, this.mouseY);

			}
			
			if (FlexGlobals.topLevelApplication.tt.comm.isConnectedToAGame 
				&& timer == 0 
				&& this.tracking 
				) { // is connected
				//optimize here, if the trail is the same, do not send.
				this.sendTrail(FlexGlobals.topLevelApplication.tt.myself_id + "trail", this.mouseX, this.mouseY);
			}
			
			var npi:Object;
			
			for (var per_frame_handle:int = 30; per_frame_handle > 0; per_frame_handle -= 1) {
				npi = permen_instructions.shift(); // use this for drawing....n.p.i. stands for new permen instruction
				if (npi) {
					var p_sprite:Sprite = permena[npi.permenalabel];
							
					switch (npi.type) {
						case "eraseall":
							p_sprite.graphics.clear();
							p_sprite.removeChildren();
							permena_texts[npi.permenalabel] = new Array();
							break;
						case "line": 
							p_sprite.graphics.moveTo(npi.x1, npi.y1);
							p_sprite.graphics.lineTo(npi.x2, npi.y2);
							break;
						case "text":
							var texts:Array = permena_texts[npi.permenalabel];
							var npitext:FlexTextField;
							var debug: String = "";
							// does it exist?
							if (!texts) { 
								permena_texts[npi.permenalabel] = new Array();
								texts = permena_texts[npi.permenalabel];
								debug += " a";
							}
							
							npitext = texts[npi.textid];
							if (!npitext) {
								texts[npi.textid] = new FlexTextField();
								
								npitext = texts[npi.textid];
								
								
								debug += " b";

								npitext.embedFonts = true;
								npitext.defaultTextFormat = tt.global_text_format; //global
								npitext.antiAliasType = "advanced";
								
								npitext.filters = [new GlowFilter(0xFFFFFF, 1, 10, 10, 2, 1, false, false)];
							}
							
							npitext.width = 250;
							npitext.height = 130;
							npitext.text = npi.text;// + debug;

							npitext.rotation = 360-tt.rotation;
							npitext.x = rotatedX(tt.rotation, npi.x);
							npitext.y = rotatedY(tt.rotation, npi.y);

							
							p_sprite.addChild (npitext);
							break;
					}
				}
			}
		}
		
		/**
		 * Sends TRAIL message to network.
		 */
		public function sendTrail(traillabel:String, x:int, y:int):void {
			var message:Object = new Object();
			message.action = "TRAIL";
			message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			message.traillabel = traillabel;
			message.x = x;
			message.y = y;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
		}
		
		/**
		 * Sends PING message to network.
		 * @param	pinglabel
		 * @param	x
		 * @param	y
		 */
		public function sendPing(pinglabel:String, x:int, y:int):void {
			var message:Object = new Object();
			message.action = "PING";
			message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
			message.pinglabel = pinglabel;
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			message.x = x;
			message.y = y;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message); // XMPP
		}
		
		/**
		 * Draw a permenaline
		 * @param	permenalabel
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 */
		public function drawPermenaLine(permenalabel:String, x1:int, y1:int, x2:int, y2:int):void {
			/* reminder: points are local to tt */
			this.sendPermenaLine(permenalabel, x1, y1, x2, y2)
		}
		
		/**
		 * Send a PERM message to the network that indicats the text to be written.
		 * @param	permenalabel
		 * @param	textid
		 * @param	text
		 * @param	x
		 * @param	y
		 * @param	r
		 */
		public function writePermenaText(permenalabel:String, textid:String, text:String, x:int, y:int, r:int):void {
			/* reminder: points are local to tt */
			// if it doesn't exist, create it
			// if it does exist, redo it
			this.sendPermenaText(permenalabel, textid, text, x, y, r);
		}
		
		/**
		 * Rotation function for a rough approximation to allow the rotated game board to have permena text in the
		 * right place.
		 * @param	r
		 * @param	x
		 * @return
		 */
		public function rotatedX(r:int, x:int):int {
			switch (r) {
				case 90:
					return x; 
				case 180:
					return x + 100;
				case -90:
					return x + 100;
				default:
					return x;
			}
		}
		
		/**
		 * Rotation function for a rough approximation to allow the rotated game board to have permena text in the
		 * right place.
		 * @param	r
		 * @param	y
		 * @return
		 */
		public function rotatedY(r:int, y:int):int {
			switch (r) {
				case -90:
					return y;
				case 90:
					return y + 100;
				case 180:
					return y + 100;
				default:
					return y;
			}
		}
		
		/**
		 * Send PERM message with text.
		 * @param	permenalabel
		 * @param	textid
		 * @param	text
		 * @param	x
		 * @param	y
		 * @param	r
		 */
		public function sendPermenaText(permenalabel:String, textid:String, text:String, x:int, y:int, r:int):void {
				var message:Object = new Object();
				message.action = "PERM";
				message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
				message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
				message.permenalabel = permenalabel;
				message.x = x;
				message.y = y;
				message.type = "text";
				message.r = r;
				message.textid = textid;
				message.text = text;
				
				
				message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
				message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
				var now:Date = new Date();
				message.timestamp = "" + new Date().valueOf();
				FlexGlobals.topLevelApplication.tt.comm.xPoll(message); // XMPP
		}
		
		/**
		 * Send PERM message to the network
		 * @param	permenalabel
		 * @param	x1
		 * @param	y1
		 * @param	x2
		 * @param	y2
		 */
		public function sendPermenaLine(permenalabel:String, x1:int, y1:int, x2:int, y2:int):void {
			//e.g. tt.visual_effect_layer.sendPermenaLine(about_all_players["t1"].permenalabel, 0, 100, 500, 500);
			//e.g. tt.visual_effect_layer.sendPermenaLine(about_all_players[FlexGlobals.topLevelApplication.tt.myself_id].permenalabel, 0, 100, 500, 500);
			
			var message:Object = new Object();
			message.action = "PERM";
			message.person_id = FlexGlobals.topLevelApplication.tt.myself_id;
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			message.permenalabel = permenalabel;
			message.x1 = x1;
			message.x2 = x2;
			message.y1 = y1;
			message.y2 = y2;
			message.type = "line";
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message); // XMPP
		}
		
		/**
		 * Create a circle shadow and register it in the ephemera array.
		 * @param	circleshadow_id
		 * @param	size
		 * @param	color
		 */
		public function registerCircleShadow(circleshadow_id:String, size:int, color:int):void {
			var circle_shadow:Sprite = new Sprite();
			circle_shadow.graphics.beginFill(color);
			circle_shadow.graphics.drawCircle(0, 0, size);
			circle_shadow.alpha = 1.0;
			ephemera[circleshadow_id] = circle_shadow;
			circle_shadow.mouseEnabled = false;
			this.addChild(circle_shadow);			
		}
		
		/**
		 * Create a trail shadow and save it (trail and related ephemera)
		 * @param	trailshadow_id
		 * @param	size
		 * @param	color
		 * @param	alpha
		 * @param	floating_text
		 */
		public function registerTrailShadow(trailshadow_id:String, size:int, color:int, alpha:Number, floating_text:String):void {
			var trail_shadow:Sprite = new Sprite();
			trail_shadow.mouseEnabled = false;
			//trail_shadow.graphics.beginFill(color);
			trail_shadow.graphics.lineStyle(size, color, alpha);
			ephemera[trailshadow_id] = trail_shadow;
			this.addChild(trail_shadow);
			var trail_info:Vector.<Point> = new Vector.<Point>(3); // new Vector of Points with 3 elements
			trail_info[0] = new Point(0, 0);
			trail_info[1] = new Point(0, 0);
			trail_info[2] = new Point(0, 0);
			trails[trailshadow_id] = new Object();
			trails[trailshadow_id]["size"] = size;
			trails[trailshadow_id]["color"] = color;
			trails[trailshadow_id]["alpha"] = alpha;
			trails[trailshadow_id]["Vectors"] = trail_info;
			trails[trailshadow_id]["last"] = new Vector.<Point>(3);
			
			var shadowtext:FlexTextField = new FlexTextField();
			shadowtext.embedFonts = true;
			shadowtext.defaultTextFormat = (FlexGlobals.topLevelApplication.tt as TT).global_text_format; //global
			shadowtext.antiAliasType = "advanced";
			shadowtext.filters = [new GlowFilter(color, 1, 10, 10, 2, 1, false, false)];
			shadowtext.getTextFormat().size = 10;
			shadowtext.text = floating_text;
			shadowtext.x = 11;
			shadowtext.y = 18;

			trails[trailshadow_id]["trailtext"] = shadowtext;
			ephemera[trailshadow_id].addChild(shadowtext);
			
			if (trailshadow_id != "mymouseshadow") { // hide the local mouse cursor because it's annoying to see the lag
				trail_shadow.alpha = 1.0;
				trail_shadow.graphics.lineStyle(1.75,
									color,
									1.0);
				trail_shadow.graphics.moveTo(0, 0);
				trail_shadow.graphics.lineTo(20, 15);
				trail_shadow.graphics.lineTo(9,10);
				trail_shadow.graphics.lineTo(9,24);
				trail_shadow.graphics.lineTo(0,0);
			}
			
		}
		
		/**
		 * Register a permena (permenant visual effect)
		 * @param	permen_id
		 * @param	size
		 * @param	color
		 * @param	alpha
		 */
		public function registerPermen(permen_id:String, size:int, color:int, alpha:Number):void {
			var p:Sprite = new Sprite();
			p.mouseEnabled = false;
			p.graphics.lineStyle(size, color, alpha);
			permena[permen_id] = p;
			this.addChild(p);
		}
		
		/**
		 * Reload a player's trail registration
		 * @param	about_all_players
		 */
		public function reloadTrailRegistration(about_all_players:Object):void {
			trails.splice(0,trails.length); // clearing trails
			//trails = new Array();
			for each (var e:Sprite in ephemera) {
				this.removeChild(e);
			}
			ephemera.splice(0, ephemera.length); // clearing old ephemera
			
			for (var player:Object in about_all_players) {
				if (player == FlexGlobals.topLevelApplication.tt.myself_id) {
					registerTrailShadow("mymouseshadow", 30, about_all_players[player].pingcolor, 0.4, about_all_players[player]["self_id"]);
					registerCircleShadow("myping", TTVisualEffects.defaultPingSize, about_all_players[player].pingcolor);
				} else {
					registerTrailShadow(about_all_players[player].traillabel, 30, about_all_players[player].pingcolor, 0.4, about_all_players[player]["self_id"]);
					registerCircleShadow(about_all_players[player].pinglabel, TTVisualEffects.defaultPingSize, about_all_players[player].pingcolor);
				}
				//trace("UPDATE TRAIL REGISTRATION: " + about_all_players[player].traillabel);
			}
		}
		
		/**
		 * Reload a permena regitration
		 * @param	about_all_players
		 */
		public function reloadPermenaRegistration(about_all_players:Object):void {
			// clear out existing permena, erase the screens.
			permen_instructions.splice(0, permen_instructions.length); // clear queued instructions
			for each(var p:Sprite in permena) {
				if (p.parent == this) this.removeChild(p);
			}
			permena.splice(0, permena.length); // clearing existing permena
			
			for (var player:Object in about_all_players) {
				//registerPermen(about_all_players[player].permenalabel, 2, 0xF5BC73, .85);
				registerPermen(about_all_players[player].permenalabel, 2, 0x8888FF, .65);
			}
		}
		
		/**
		 * Enqueue a trail point 
		 * @param	trailshadow_id
		 * @param	x
		 * @param	y
		 */
		public function enqueueTrailPoint(trailshadow_id: String, x: int, y:int):void {
			if (trailshadow_id == FlexGlobals.topLevelApplication.tt.myself_id + "trail") return;
			if (trails[trailshadow_id]) { // sanity check that this entry exists
				trails[trailshadow_id]["Vectors"].pop(); // ensure there are always 3 elements
				if (x < 0) x = 0;
				if (y < 0) y = 0;
				if (x > 800) x = 800;
				if (y > 800) y = 800;
				//if (x > FlexGlobals.topLevelApplication.width) x =  FlexGlobals.topLevelApplication.width;
				//if (y > FlexGlobals.topLevelApplication.height) y =  FlexGlobals.topLevelApplication.height;
				trails[trailshadow_id]["Vectors"].unshift(new Point(x, y));
			} else {
				trace("tried to enqueue a trail but failed to find the one with id: " + trailshadow_id + " there are this many: " + trails.length);
			}
		}

		/**
		 * Enqueue an animated ping
		 * @param	circleshadow_id
		 * @param	x
		 * @param	y
		 * @param	alpha
		 */
		public function queueAnimatedPing(circleshadow_id: String, x: int, y: int, alpha: Number):void {
			if (ephemera[circleshadow_id]) { // check if this exists at all? safety
				var ping_set:Object = pings.pop();
				if (!ping_set) ping_set = new Array();
					ping_set.push (
						{
							"circleshadow_id" : circleshadow_id,
							"x" : x,
							"y" : y,
							"alpha" : alpha
							}
					);
				pings.unshift(ping_set);
			}
		}
		

		
	}

}