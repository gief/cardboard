package communicator 
{
	
	/**
	 * Abstract class for the communication code.
	 * 
	 * @author giffordcheung
	 */
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
	
	public class TTAbstractCommunicator extends EventDispatcher 
	{
		
		public function TTAbstractCommunicator() 
		{
			super();
		}
		
		/**
		 * is Connected?
		 * @return <code>true</code> if connected; <code>false</code> if not.
		 */
		public function isConnected():Boolean 
		{
			return false;
		}
		
		/**
		 * Connect to client
		 * @param	username
		 * @param	password
		 * @param	server
		 * @param	port
		 * @param	gameroom This is the unique room identifier
		 */
		public function connect(username:String, password:String, server:String, port:uint, gameroom:String):void 
		{
			throw new Error("communicator must be implemented");
		}
		
		/**
		 * Disconnect
		 */
		public function disconnect():void 
		{
			throw new Error("communicator must be implemented");
		}
		
		/**
		 * Send a message 
		 * @param	to - recipient, some implementations ignore this or have custom "ALL" at the moment (see TTLocalNetConnectionCommunicator)
		 * @param	from - your identifier
		 * @param	message - message
		 */
		public function send(to:String, from:String, message:String):void 
		{
			throw new Error("communicator must be implemented");
		}
		
		
	}

}