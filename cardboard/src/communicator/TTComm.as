package communicator 
{

	import com.adobe.utils.NumberFormatter;
	import console.TTConsole;
	import flash.events.*;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.events.HTTPStatusEvent;
		
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	
	import flash.geom.Point;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	
	import mx.core.FlexGlobals;
	
	import engine.*;
	

	import communicator.TTCommunicationEvent;

	/**
	 * This is the message center for Card Board. After a connection is established, 
	 * Card Board passes messages to its peers (and itself) to indicate the state of the game board and its game 
	 * pieces.
	 * 
	 * @author Gifford Cheung
	 */
	public class TTComm 
	{
		public var showmessages:Boolean = false; // debugging
		public var timer:Timer;
		public var timerInterval:int = 200;
		public var outgoing_buffer:Array;
		public var outgoing_log:Array = new Array();
		public var incoming_buffer:Array;
		public var movecard_buffer:Array;
		public var current_message_number:int;
		public var s_current_message_number:int;
		public var my_message_number:int; // my message number starts at 0
		
		
		public var communicationInstance:*; 
		
		public var myJID:String;
		public var xmppConnectAttempted:Boolean = false;
		public var serverKnowsMe:Boolean = false;
		public var isConnectedToAGame:Boolean = false;
		public var message_errors:Number = 0;
		
		public var all_players:Array; 
		public var about_all_players:Object; 
		public var player_server_address:String;

		public var commLog:String;

		public function TTComm() 
		{
			my_message_number = 0;
			current_message_number = 0;
			outgoing_buffer = new Array();
			incoming_buffer = new Array();
			about_all_players =  new Object();

		}
		
		/**
		 * Initiate a TTLocalNetConnectionCommunicator for LAN-based gameplay. 
		 * Currently hard-coded into this version. An older method for this is was initXMPPConnection. 
		 * Future versions should allow your choice of protocol. (E.g. LAN-based RTMFP and server-based RTMFP)
		 * 
		 * @return
		 */
		public function initLANConnection():String {
			TTSideConsole.loopbackWrite("LAN Connection...");
				
			communicationInstance = new TTLocalNetConnectionCommunicator();
			setListeners();
			
			try {
				(communicationInstance as TTAbstractCommunicator).connect(null, null, null, 0, String(FlexGlobals.topLevelApplication.tt.room));
			} catch (e:Error) {
				TTSideConsole.loopbackWrite("Connection Error." + e.getStackTrace);
			}
			return "Connecting to Lan";
		}
		
		
		/**
		 * Sets listeners for communication events coming from the communicationInstance
		 */
		public function setListeners():void {
			(communicationInstance as EventDispatcher).addEventListener(TTCommunicationEvent.CONNECT, initTimerHandler);
			(communicationInstance as EventDispatcher).addEventListener(TTCommunicationEvent.MESSAGE, enqueueMessage);
		}

		/**
		 * Send a message to everyone 
		 * @param	message to send
		 */
		public function send(message:Object):void {
			var message:Object = message;
			// NO MORE MESSAGE NUMBER CHECKING
			
			message.my_message_number = this.my_message_number;
			this.my_message_number += 1;
			
			message.sendType = "p2p";
			outgoing_buffer.push(message);
		}
		
		/**
		 * Send a message to everyone. Currently out of date, redirects to the send function
		 */
		public function xPoll():void {
			// timer will send this
			var message:Object = arguments[0];
			
			send(message);
			/*
			message.sendType = "clientserver";
			message.my_message_number = this.my_message_number;
			outgoing_buffer.push(message);
			// no more log?
			// outgoing_log[this.my_message_number] = message;
			this.my_message_number += 1;
			*/
		}
		
		
		/**
		 * Composes and broadcasts a "HELLO" message for clients to introduce themselves
		 * to the network by identifying themselves, the color of their cursor, etc...
		 * @param	suggestedColor
		 */
		public function broadcastHello(suggestedColor:int):void {
			var message:Object = new Object();
			message.action = "HELLO";
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.traillabel = "trail";
			message.pinglabel = "ping";
			message.permenalabel = "permena";
			message.suggested_color = suggestedColor;
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			(FlexGlobals.topLevelApplication.tt.comm as TTComm).send(message);
		}
		
		/**
		 * When a HELLO message is received, it is processed by the server. This is the function that it runs to
		 * add the new user and to send out a snapshot of the game state back to the new user. This code used
		 * to assign a private area to the player, but now that is implemented by a different message.
		 * 
		 * @param	hello - the hello message object
		 */
		public function processHelloSendHelloResponse(hello:Object):void { 
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			var message:Object = new Object();
			message.action = "HELLORESPONSE";
			
			//----------------------------Envelope cover-------------------------------
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.iamserver = this.myJID == player_server_address; 
			message.game_id = tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
						
			//----------------------------Processing------------------------------------
			var count:int = 0;
			var new_all_players:Array = tt.comm.all_players.slice(); 
			var num_players:int = new_all_players.length;
			var indexOfHelloPlayer:int = -1;
						
			message.all_players = new_all_players;
			message.snapshot = tt.getSnapshot();
			
			//save information about this player
			about_all_players[hello.self_id] = new Object;

			// Trails and pings
			var traillabel:String = hello.self_id + hello.traillabel;
			var pinglabel:String = hello.self_id + hello.pinglabel;
			var permenalabel:String = hello.self_id + hello.permenalabel;
			
			about_all_players[hello.self_id]["traillabel"] =  hello.self_id + hello.traillabel;
			about_all_players[hello.self_id]["pinglabel"] =  hello.self_id + hello.pinglabel;
			about_all_players[hello.self_id]["trailcolor"] =  hello.suggested_color;
			about_all_players[hello.self_id]["pingcolor"] =  hello.suggested_color;
			about_all_players[hello.self_id]["permenalabel"] = hello.permenalabel;
			about_all_players[hello.self_id]["self_id"] = hello.self_id;
			
			// tell the player about all other players
			message.about_all_players = about_all_players;
			send(message); 
		}
		
		/**
		 * The client who originally said "HELLO", now receives a response
		 * and now stores the game information and applies the game state.
		 * 
		 * @param	m
		 */
		public function processHelloResponse(m:Object):void {
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			//FlexGlobals.topLevelApplication.startServer.label = "RESPONSE from " + m.self_id;
			serverKnowsMe = true;
			isConnectedToAGame = true;
			all_players = m.all_players;
			about_all_players = m.about_all_players;

			tt.loadOrReloadGame(JSON.stringify(m.snapshot.Game)); 
			tt.loadAreas(JSON.stringify(m.snapshot.Areas));
			tt.loadCards(JSON.stringify(m.snapshot.Cards));
			
			tt.visual_effect_layer.reloadTrailRegistration(about_all_players);
			tt.visual_effect_layer.reloadPermenaRegistration(about_all_players);

			for each (var area:TTArea in tt.areas) {
				area.reRenderBackground();
			}
		}

		/**
		 * Incoming messages are put in a queue for processing
		 * @param	e
		 */
		private function enqueueMessage( e:TTCommunicationEvent ):void {
			incoming_buffer.push(e);
		}

		/**
		 * The main branching code for evaluating messages. 
		 * @param	communicationEvent
		 */
		private function handleMessage( communicationEvent:TTCommunicationEvent ):void {
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			
			if (showmessages) trace('--------------message---------------\n');
			
			var messages:Object = JSON.parse(communicationEvent.message);
				
			if (communicationEvent.to == "ALL" || communicationEvent.to == FlexGlobals.topLevelApplication.tt.myself_id) {
				//log
				//commLog += "\n" + messagePacket.body;
				//FlexGlobals.topLevelApplication.commlog.htmlText += "\n" + messagePacket.body;

				// message order juggling
				messages.sortOn(['my_message_number'], Array.NUMERIC);
				
				
				for each (var m:Object in messages) {
					if (!isConnectedToAGame && 
							m.action != "HELLO" && 
							m.action != "HELLORESPONSE") {
							//trace("dropping [" + m.message_number + "] too early, haven't gotten a HELLORESPONSE: " + m.action);
							continue;
						}
					if (!isConnectedToAGame && m.action == "HELLORESPONSE") {
						this.current_message_number = m.message_number; 
					}
						
					// have not yet tested if message juggling is really working
					this.current_message_number += 1; 
					
					// PROCESS THE MESSAGE

					// check here to see if the sender is myself {this depends on the communication implementation?}
					var myself:Boolean = m.person_id == tt.myself_id;
					
					switch (m.action) {
						case "FLIPCARD":
							if (!myself) {
								var card:TTCard = tt.getCard(m.area_id, m.card_id);
								if (card) card.flip();
								// Note, this can happen out of order. In the future we need a TTCardMover.enqueue(flip)
							}
							break;
						case "MOVECARD":
							if (!myself) {
								var movedcard:TTCard = tt.getCard(m.area_id_orig, m.card_id);
								var destarea:TTArea = tt.getArea(m.area_id_dest);
								var gp:Point = destarea.localToGlobal(	new Point(m.x_dest, m.y_dest));
								var op:Point = movedcard.area.localToGlobal( new Point(m.x_orig, m.y_orig));

								TTCardMover.enqueue(
											movedcard, 
											m.area_id_orig, op.x, op.y, (movedcard.rotation + movedcard.area.rotation) % 360,  
											m.area_id_dest, gp.x, gp.y, (destarea.rotation + movedcard.rotation) % 360,
											myself, true, /*!animatedonce*/true, m.quiet);
							}
							break;
						case "ROTATECARD":
							if (!myself) {
								var rotatedcard:TTCard = tt.getCard(m.area_id, m.card_id);
								if (rotatedcard) {
									rotatedcard.processRotatedCard(m.new_rotation);
								} else {
									trace ("ERROR: rc couldn't find card: " + m.card_id);
								}
							}
							break;
						case "CONFIGAREA":
							if (!myself) {
								var area:TTArea = tt.getArea(m.area_id);
								if (area) {
									area.setOwnerId(m.owner_id);
								}
							}
							break;
						case "RESETGAME":
							// reset the game. TODO
							break;
						case "PING":
							tt.visual_effect_layer.queueAnimatedPing(m.pinglabel, m.x, m.y, 1.0);
							break;
						case "TRAIL":
							tt.visual_effect_layer.enqueueTrailPoint( m.traillabel, m.x, m.y);
							break;
						case "PERM":
							tt.visual_effect_layer.permen_instructions.push(m); // simple, but works, the message has a label and 2 coordinates
							break; 
						case "HELLO":
							if (tt.myself_id == tt.server_player_id) {
								this.processHelloSendHelloResponse(m);
							} else {
								// I AM NOT SERVER
								// I AM NOT THE HELLOER
							}
							break;
						case "HELLORESPONSE":
							processHelloResponse(m);
							break;
						case "PLAYCOMPONENT":
							if (m.command == "init") {
								//HERE WE GO.
								if (tt.game_components[m.owner_id] == null) {
									tt.game_components[m.owner_id] = new TTComponentManager();
									trace("create new dealer under " + m.owner_id);
								}
								TTComponentManager.processInitMessage(m.component_type, m.area_id, m.x, m.y, m.owner_id, m.component_id);
							}
							break;
						case "SIDECONSOLE":
							TTSideConsole.handleSideConsole(m);
							break;
						case "AREAACCENTCOLOR":
							TTArea.processAreaAccentColor(m);
							break;
						case "CARDDECOR":
							(tt.getCard(m.area_id, m.card_id) as TTCard).processCardDecor(m);
							break;
					}
					
				}
			}
		}

		/**
		 * generic XMPP message handler for debugging purposes prints message to the trace
		 * @param	e
		 */
		private function genericXMPPHandler (e:Event):void {
			trace ("XMPP : " + e.type);
			if (e.type == "data") {
				
			}
		}

		/**
		 * Initiates the communication timer for handling messages.
		 * @param	e
		 */
		private function initTimerHandler(e:Event):void {
			// timer
			timer = new Timer(timerInterval);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
			
			TTSideConsole.loopbackWrite("Connection Success.");
		}
		
		private var timer_flipper : int = 0;

		/**
		 * Timer handler that will check the incoming and outgoing message buffers. 
		 * @param	e
		 */
		private function timerHandler(e:TimerEvent):void {
			
			while (incoming_buffer.length > 0) {
					/* Refactor name */
					handleMessage(incoming_buffer.shift());
				}
			if ((communicationInstance as TTAbstractCommunicator).isConnected()) {
				// TODO:
				/*
				 * collected_msgs
				 * server_msgs
				 */
				var collected_msgs_p2p:Array = new Array();
				var collected_msgs_clientserver:Array = new Array();
				var message:Object;
				while (outgoing_buffer.length > 0) {
					message = outgoing_buffer.shift();
					if (message.sendType == "clientserver") {
						collected_msgs_clientserver.push(message);
					} else if (message.sendType == "p2p") {
						collected_msgs_p2p.push(message);
					}
				}
				if (collected_msgs_clientserver.length > 0) {
					communicationInstance.send(
						FlexGlobals.topLevelApplication.tt.server_player_id, 
						FlexGlobals.topLevelApplication.tt.myself_id, 
						"\\poll " + JSON.stringify(collected_msgs_clientserver));
				}				
				if (collected_msgs_p2p.length > 0) {
					messageAllPlayers(JSON.stringify(collected_msgs_p2p));
				}
				
				/*
				 * The new trails do not need a 
				timer_flipper = (timer_flipper + 1) % (450);
				if (timer_flipper == 0) {
					connection.sendKeepAlive(); // keep-alive should 
					conn.sendPresence(); // a keep-alive
				}
				*/
			}
			return;
		}
		
		/*
		 *  Send a message to all players. Currently undifferentiated from send function.
		 */
		public function messageAllPlayers(msg:String) :void {
			//var address:String;
			(communicationInstance as TTAbstractCommunicator).send("ALL", FlexGlobals.topLevelApplication.tt.myself_id, msg);
			/*
			 * old code:
			for each (var recipient:String in all_players) {
				address = recipient
				+ "@" + FlexGlobals.topLevelApplication.tt.server 
				+ "/" + FlexGlobals.topLevelApplication.tt.room;
				communicationInstance.send(address, msg);
			}
			*/
		}
		
	}
	
}