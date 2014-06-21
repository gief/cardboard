package communicator 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author giffordcheung
	 */
	public class TTMessageEvent extends Event 
	{
		
		public function TTMessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new TTMessageEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TTMessageEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}