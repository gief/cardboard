package engine 
{
	import flash.events.Event;
	
	/**
	 * TODO: Events for the engine, cleaner than existing implementation?
	 * @author Gifford Cheung
	 */
	public class TTEngineEvent extends Event 
	{
		/*
		 * TODO
    	public static var FLIP:String = "flip";
        public static var HELLO:String = "hello";
        public static var HELLORESPONSE:String = "helloresponse";
        public static var MOVE:String = "move";
        public static var PERMENA:String = "permena";
        public static var PING:String = "ping";
        public static var PLAYCOMPONENT:String = "playcomponent";
        public static var ROTATE:String = "rotate";
        public static var CONSOLE:String = "console";
        public static var TRAIL:String = "trail";
		*/
		
		public function TTEngineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new TTEngineEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TTEngineEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}