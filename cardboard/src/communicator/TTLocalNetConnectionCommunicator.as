package communicator 
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	/**
	 * Communicator for LAN using RTFMP. Based on the explanation from: http://blog.leeburrows.com/2011/10/p2p-flash-on-a-local-network-part1/
	 * @author giffordcheung
	 */
	
	public class TTLocalNetConnectionCommunicator extends TTAbstractCommunicator 
	{
		private var netConn:NetConnection;
		private var group:NetGroup;
		
		private var connected:Boolean;
		private var gameroom: String;
		private var password: String;
		
		public function TTLocalNetConnectionCommunicator() 
		{
			connected = false;
			super();
		}
		/* INTERFACE communicator.TTCommunicator */
		
		override public function isConnected():Boolean {
			return connected;
		}

		override public function connect(username:String, password:String, server:String, port:uint, gameroom:String):void 
		{
			this.gameroom = gameroom;
			netConn = new NetConnection();
			netConn.addEventListener(NetStatusEvent.NET_STATUS, netHandler);
			netConn.connect("rtmfp:");
			
		}
		
		override public function disconnect():void 
		{
			// untested
			netConn.close();
		}
		
		override public function send(to:String, from:String, message:String):void 
		{
			//trace("TTLan:sending:" + message);
			var obj:Object = new Object();
			obj.txt = message;
			obj.id = new Date().time;
			obj.from = from;
			obj.to = to;
			this.group.post(obj);
			
			// echo the message back to myself
			dispatchEvent (new TTCommunicationEvent(TTCommunicationEvent.MESSAGE, false, false, obj.to, obj.from, obj.txt));
		}
		
		private function netHandler(event:NetStatusEvent):void {
			//trace("netHandler triggered.");
			switch(event.info.code) {
				// connect success
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				case "NetGroup.Connect.Success":
					trace ("LAN : connected");
					this.connected = true;
					dispatchEvent( new TTCommunicationEvent(TTCommunicationEvent.CONNECT));
					break;
				case "NetGroup.Posting.Notify":
					trace("posting notify!" + event.info.message.txt);
					dispatchEvent (new TTCommunicationEvent(TTCommunicationEvent.MESSAGE, false, false, event.info.message.to, event.info.message.from, event.info.message.txt));
					break;
			}
		}
		
		/**
		 * Assigns the private room
		 */
		private function setupGroup():void {
			var groupspec:GroupSpecifier = new GroupSpecifier(this.gameroom);
			groupspec.postingEnabled = true;
			groupspec.routingEnabled = true;
			groupspec.ipMulticastMemberUpdatesEnabled = true;
			groupspec.addIPMulticastAddress("225.225.0.1:30000");
			group = new NetGroup(netConn, groupspec.groupspecWithAuthorizations());
			group.addEventListener(NetStatusEvent.NET_STATUS, netHandler);
		}
	}

}