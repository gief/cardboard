package engine 
{
	import mx.core.FlexGlobals;
	/**
	 * Side console class (the text box on the right side of the screen)
	 * @author Gifford Cheung
	 */
	public class TTSideConsole 
	{
		
		public function TTSideConsole() 
		{
			
		}
		
		/**
		 * Writeln for box
		 * @param	text
		 */
		public static function writeln(text:String):void {
			write(text + "\n");
		}
		
		/**
		 * Write for box
		 * @param	text
		 */
		public static function write(text:String):void {
			TTSideConsole.sendToSideConsole(text);
		}
		
		/**
		 * Sends a SIDECONSOLE message to the network
		 * @param	text
		 */
		public static function sendToSideConsole(text:String):void {
			var message:Object = new Object();
			message.action = "SIDECONSOLE";
			message.self_id =  FlexGlobals.topLevelApplication.tt.myself_id; 
			message.game_id = FlexGlobals.topLevelApplication.tt.game_id;
			var now:Date = new Date();
			message.timestamp = "" + new Date().valueOf();
			message.text = text;
			
			FlexGlobals.topLevelApplication.tt.comm.xPoll(message);// XMPP
		}
		
		/**
		 * Processes a SIDECONSOLE message
		 * @param	message
		 */
		public static function handleSideConsole(message:Object):void {
			FlexGlobals.topLevelApplication.sideconsole.htmlText += message.text;
		}
		
		/**
		 * Writes to sideconsole without sending a SIDECONSOLE message to the network.
		 * @param	text
		 */
		public static function loopbackWrite(text:String):void {
			TTSideConsole.handleSideConsole( { text:text } );
			
		}
	}

}