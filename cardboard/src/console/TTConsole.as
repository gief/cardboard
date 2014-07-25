package console 
{

	import communicator.TTComm;
	import engine.*;
	import flash.system.LoaderContext;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import flash.text.TextField;
	import mx.core.Application;
	
	import mx.core.FlexGlobals;
	
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	
	import flash.utils.*;
	
	
	/**
	 * Developer's console. Future work should make this visible to users.
	 * Much of this code is out of date.
	 * @author Gifford Cheung
	 */
	public class TTConsole extends Panel 
	{
		public var consolescreen:TextArea;
		public var consoleinput:TextInput;
		public var consolebutton:Button;
		public var comm:TTComm;
	
		public function TTConsole():void 
		{
			super();			
		}
		
		
		public function parse():void 
		{
			var functionArgs:Array = consoleinput.text.split(" ");
			var functionName:String = functionArgs.shift();
				
			if (this.hasOwnProperty(functionName) && functionName != 'parse') {
				try {
					this[functionName].apply(this, functionArgs); //arg1 (this) will change later to apply to the right object as in the game
				} catch (e:SecurityError) {
					consolescreen.text += "\n Security Error " + e.message + "\n";
				} catch (e:Error) { //catch (e:ArgumentError) {
					consolescreen.text += e.message + "\n";//  + e.getStackTrace + "\n";
				} 
			}
			consoleinput.text = "";
		}
		
		public function commands():void {
			/*
			 * TODO: this needs to hide irrelevant commands
			var classInfo:XML = describeType(this);
			for each (var m:XML in classInfo..method) {
                consolescreen.text += "Method " + m.@name + "():" + m.@returnType + "\n";
            }
			*/
		}
				
		public function snapshot():void {
			var x:Object = FlexGlobals.topLevelApplication.tt.getSnapshot(); //test
			consolescreen.text += "\n" + JSON.stringify(x);
		}
		
		public function loadGame():void {
			consolescreen.text += "\nLoading Game: Note: this command is not transmitted over the network. \n";
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadOrReloadGame(arguments[0]);
		}
		
		public function loadAreas():void {
			consolescreen.text += "\nLoading Area: Note: this command is not transmitted over the network. \n";
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadAreas(arguments[0]);			
		}
		
		public function loadCardArray():void {
			consolescreen.text += "\nLoading Array of Cards: Note: this command is not transmitted over the network. \n";
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadCards(arguments[0]);
		}
		
		public function deleteAllCards():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.deleteAllCards();
			tt.sendDeleteAllCardsMessage();
		}
		
		public function loadCards():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			if (!tt.game_id) {
				// game not yet started
				consolescreen.text += "\nNo game yet, cannot load cards\n";
				return; 
			}
			
			//expecting a series of values separated by comma
			var input:String = arguments[0];
			var cards:Array = input.split(",");
			for each (var card:String in cards) {
				this["loadCard"].apply(this, [card]); 
			}
		}
		
		public function loadCard():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			if (!tt.game_id) {
				// game not yet started
				consolescreen.text += "\nNo game yet, cannot load cards\n";
				return; 
			}
			if (arguments[0].substring(0, 4) == "http") {
				consolescreen.text += "\nLoading:" +arguments[0]+"\n";
				var url:URLRequest = new URLRequest(arguments[0]);
				var loaderContext:LoaderContext = new LoaderContext(true);
				var imgLoader:Loader = new Loader();
				imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCardCallback);
				imgLoader.load(url, loaderContext);
			} else {
				var cards:Array = new Array();
				// area_id
				var card:Object = new Object();
				card.area_id = 9001; // This can be made automagically another day
				card.card_id = tt.generateCardId();
				card.back = "0";
				card.chipColor = 0;
				card.data = "nothing";
				card.face_up = true;
				//front
				card.front = arguments[0];
				//h
				card.h = 70;
				//halfh
				card.halfh = 35;
				//halfw
				card.halfw = 25;
				card.isChip = false;
				card.r = 0;
				//w
				card.w = 50;
				card.x = 225;
				card.y = 225;
				
				cards.push(card);
				tt.loadCards(JSON.stringify(cards));
				TTCard.sendLoadCardsMessage(cards);
			}
		}
		
		public function loadCardCallback(e:Event):void {
			consolescreen.text += "Loading:" +e.target.url+": Load Complete\n";
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			TTCardImages.loaded(e);
			var cards:Array = new Array();
			// area_id
			var card:Object = new Object();
			card.area_id = 9001; // This can be made automagically another day
			card.card_id = tt.generateCardId();
			card.back = "0";
			card.chipColor = 0;
			card.data = "nothing";
			card.face_up = true;
			//front
			card.front = "LOAD_" + e.target.url;
			//h
			card.h = e.target.content.height;
			//halfh
			card.halfh = Math.round(e.target.content.height / 2);
			//halfw
			card.halfw = Math.round(e.target.content.width / 2);
			card.isChip = false;
			card.r = 0;
			//w
			card.w = e.target.content.width;
			card.x = 225;
			card.y = 225;
			
			
			cards.push(card);
			tt.loadCards(JSON.stringify(cards));
			TTCard.sendLoadCardsMessage(cards);
		}
		
		public function help(): void {
			consolescreen.text += "This is a help function.";
			/*
			consolescreen.text += "setPlayer 2001 2003\n"
				+ "commInit http:\\tabletop-testing.appspot.com\n"
				+ "xInit\n"
				+ "loadGame 8001\n\n"
				+ "setPassword() setServer() setRoom()";
			*/
		}
		
		public function hide():void {
			mx.core.FlexGlobals.topLevelApplication.ttcomponent.visible = false;
		}
		
		public function show():void {
			mx.core.FlexGlobals.topLevelApplication.ttcomponent.visible = true;
		}

		public function echo():void {		
			consolescreen.text += "ECHO: ";
		
			for each (var s:String in arguments) {
				consolescreen.text += s + " ";
			}
			consolescreen.text += "\n";
			consolescreen.text += "-next step. Create TTRPCcommunicator [this is the client for now] [ there will be a game engine later]\n";
		}
		
		public function tostatus():void {
			FlexGlobals.topLevelApplication.statusbar.text = "";
			for each (var s:String in arguments) {
				FlexGlobals.topLevelApplication.statusbar.text += s + " ";
			}
		}
		
		
	}

}