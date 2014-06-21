package communicator 
{
	import flash.events.Event;
	
	/**
	 * Communication events: "message", "disconnect", "connect"
	 * @author Gifford Cheung
	 */
	public class TTCommunicationEvent extends Event 
	{
    	public static var MESSAGE:String = "message";
        public static var DISCONNECT:String = "disconnect";
        public static var CONNECT:String = "connect";
        /* public static var ERROR:String = "error"; */

		public var to:String;
		public var from:String;
		public var message:String;

		
		public function TTCommunicationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, to:String = null, from:String = null, message:String = null) 
		{ 			
			this.to = to;
			this.from = from;
			this.message = message;
			super(type, bubbles, cancelable);	
		} 
		
		public override function clone():Event 
		{ 
			return new TTCommunicationEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TTCommunicationEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}