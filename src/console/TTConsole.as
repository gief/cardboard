package console 
{

	import communicator.TTComm;
	import engine.*;
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import flash.text.TextField;
	import mx.core.Application;
	
	import mx.core.FlexGlobals;
	
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
			comm = new TTComm();
			FlexGlobals.topLevelApplication.tt.comm = comm;
		}
		
		
		public function parse():void 
		{
			var functionArgs:Array = consoleinput.text.split(" ");
			var functionName:String = functionArgs.shift();
				
			if (this.hasOwnProperty(functionName) && functionName != 'parse') {
				try {
					this[functionName].apply(this, functionArgs); //arg1 (this) will change later to apply to the right object as in the game
				} catch (e:Error) { //catch (e:ArgumentError) {
					consolescreen.text += e.message + "\n";
				} 
			}
			consoleinput.text = "";
		}
		
		public function commands():void {
			var classInfo:XML = describeType(this);
			for each (var m:XML in classInfo..method) {
                consolescreen.text += "Method " + m.@name + "():" + m.@returnType + "\n";
            }
		}
		public function dropAreasAndCards():void {
			FlexGlobals.topLevelApplication.tt.dropAreasAndCards();
		}
		public function snapshot():void {
			var x:Object = FlexGlobals.topLevelApplication.tt.getSnapshot(); //test
			consolescreen.text += "\n" + JSON.stringify(x);
			/*
			consolescreen.text += "\n" + x["Game"];
			consolescreen.text += "\n" + x["Areas"];
			consolescreen.text += "\n" + x["Cards"];
			*/
		}
		
		public function loadGame():void {
			consolescreen.text += "\nLoading Game, next loadAreas and loadCards, then initXMPP \n";
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadOrReloadGame(arguments[0]);
		}
		
		public function loadAreas():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadAreas(arguments[0]);			
		}
		
		public function loadCards():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.loadCards(arguments[0]);
		}
		
		/*
		public function initXMPP():void {
			comm.initXMPPConnection();
		}
		*/
		
		public function back():void {
			this.parent.addChildAt(this, 0);
		}
		
		public function front():void {
			this.parent.addChildAt(this, this.parent.numChildren);
		}

		public function r():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.rotation += 90;
			tt.recenterAfterRotation();
		}
		
		public function p():void {
			consolescreen.text += "P1ING\n";
			for (var i:String in FlexGlobals.topLevelApplication.parameters) {
                 consolescreen.text += i + ":" + FlexGlobals.topLevelApplication.parameters[i] + "\n";
            }
		}
		/*
		public function pload():void {
			var g:String,
				a: String,
				c:String,
				p:String;
			var me: Object;
			for (var i: String in FlexGlobals.topLevelApplication.parameters) {
				switch (i) {
					case "gs":
						g = FlexGlobals.topLevelApplication.parameters[i];
						break;
					case "as":
						a = FlexGlobals.topLevelApplication.parameters[i];
						break;
					case "cs":
						c = FlexGlobals.topLevelApplication.parameters[i];
						break;
					case "ps":
						p = FlexGlobals.topLevelApplication.parameters[i];
						break;
					case "mes":
						me = JSON.parse(FlexGlobals.topLevelApplication.parameters[i]);
						break;
				};
			}
			arguments[0] = me["self"];
//			arguments[0] = "t1";
			this["setPlayer"].apply(this, arguments);
			//setPlayer();
			arguments[0] = p;
			this["setPlayers"].apply(this, arguments);
			arguments[0] = "1234!@#$";
			this["setPassword"].apply(this, arguments);
			//setPassword();
			arguments[0] = "127.0.0.1";
			this["setServer"].apply(this, arguments);
			//setServer();
			arguments[0] = "ttroom";
			this["setRoom"].apply(this, arguments);
			//setRoom();
			arguments[0] = g;
			this["loadGame"].apply(this, arguments);
			//loadGame();
			arguments[0] = a;
			this["loadAreas"].apply(this, arguments);
			//loadAreas();
			arguments[0] = c;
			this["loadCards"].apply(this, arguments);
				
			xInit();

		}
		*/
		public function rr():void {
			var tt:TT = mx.core.FlexGlobals.topLevelApplication.tt;
			tt.areas[0].cards[0].rotation += 45;
		}
		
		public function dateTest():void {
			var now:Date = new Date();
			consolescreen.text += Math.floor((new Date()).valueOf()/1000);
		}
		
		public function setPlayer(): void {
			var tt:TT = FlexGlobals.topLevelApplication.tt;
			tt.myself_id = arguments[0];
		}
		
		public function setPassword(): void {
			FlexGlobals.topLevelApplication.tt.myself_password = arguments[0];
			consolescreen.text += "passwd set to: " + arguments[0];
		}
		
		public function setServer(): void {
			FlexGlobals.topLevelApplication.tt.server = arguments[0];
			consolescreen.text += "server set to: " + arguments[0];
		} 
		
		public function setRoom(): void {
			FlexGlobals.topLevelApplication.tt.room = arguments[0];
			consolescreen.text += "room set to: " + arguments[0];
		}
		
		public function setArea(): void {
		}
		
		public function preset1(): void {
			arguments[0] = "t1";
			this["setPlayer"].apply(this, arguments);
			//setPlayer();
			arguments[0] = TTGamePresets.p1;
			this["setPlayers"].apply(this, arguments);
			arguments[0] = "1234!@#$";
			this["setPassword"].apply(this, arguments);
			//setPassword();
			arguments[0] = "127.0.0.1";
			//arguments[0] = "24.16.145.137";
			this["setServer"].apply(this, arguments);
			//setServer();
			arguments[0] = "ttroom";
			this["setRoom"].apply(this, arguments);
			//setRoom();
			arguments[0] = TTGamePresets.g1;
			this["loadGame"].apply(this, arguments);
			//loadGame();
			arguments[0] = TTGamePresets.a1;
			this["loadAreas"].apply(this, arguments);
			//loadAreas();
			arguments[0] = TTGamePresets.c1;
			this["loadCards"].apply(this, arguments);
			//loadCards();
			//connect.
			consolescreen.text += "Preset 1 set: press connect.";
			
		}
		public function preset2():void {
			arguments[0] = "t2";
			this["setPlayer"].apply(this, arguments);
			//setPlayer();
			arguments[0] = TTGamePresets.p1;
			this["setPlayers"].apply(this, arguments);
			arguments[0] = "1234!@#$";
			this["setPassword"].apply(this, arguments);
			//setPassword();
			arguments[0] = "127.0.0.1";
			this["setServer"].apply(this, arguments);
			//setServer();
			arguments[0] = "ttroom";
			this["setRoom"].apply(this, arguments);
			//setRoom();
			arguments[0] = TTGamePresets.g1;
			this["loadGame"].apply(this, arguments);
			//loadGame();
			arguments[0] = TTGamePresets.a1;
			this["loadAreas"].apply(this, arguments);
			//loadAreas();
			arguments[0] = TTGamePresets.c1;
			this["loadCards"].apply(this, arguments);
		}

		public function preset3():void {
			arguments[0] = "t3";
			this["setPlayer"].apply(this, arguments);
			//setPlayer();
			arguments[0] = TTGamePresets.p1;
			this["setPlayers"].apply(this, arguments);
			arguments[0] = "1234!@#$";
			this["setPassword"].apply(this, arguments);
			//setPassword();
			arguments[0] = "127.0.0.1";
			this["setServer"].apply(this, arguments);
			//setServer();
			arguments[0] = "ttroom";
			this["setRoom"].apply(this, arguments);
			//setRoom();
			arguments[0] = TTGamePresets.g1;
			this["loadGame"].apply(this, arguments);
			//loadGame();
			arguments[0] = TTGamePresets.a1;
			this["loadAreas"].apply(this, arguments);
			//loadAreas();
			arguments[0] = TTGamePresets.c1;
			this["loadCards"].apply(this, arguments);
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
		
		public function o(): void {
			try {
				var a:Array = comm.outgoing_log;
				consolescreen.text += "Outgoing log size: " + a.length + "\n";
				for each (var m:Object in a) {
					consolescreen.text += m.my_message_number + ": " + m.action + " " + m.card_id + "\n";
				}
			} catch (e:Error) {
				consolescreen.text += e.message + "\n" + e.getStackTrace + "\n";
			}
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