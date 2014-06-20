package engine 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import mx.core.FlexTextField;
	
	import flash.geom.Matrix;
	/**
	 * Import card graphics from a library swf file
	 * @author Gifford Cheung
	 */
	public class TTCardImages
	{
		
		//[Embed(source = "CardLibrary.swf", )]
		//[Bindable]
		//public var CardLibrary:Class; // TODO: make this work dynamically 
		//http://livedocs.adobe.com/flex/3/html/help.html?content=embed_3.html
		
		[Embed(source='../cards/library.swf', symbol='CARD_AD')]
		[Bindable]
		public static var CARD_AD:Class;
		
		[Embed(source = '../cards/library.swf', symbol = 'CARD_2D')]
		[Bindable]
		public static var CARD_2D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_3D')]
		[Bindable]
		public static var CARD_3D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_4D')]
		[Bindable]
		public static var CARD_4D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_5D')]
		[Bindable]
		public static var CARD_5D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_6D')]
		[Bindable]
		public static var CARD_6D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_7D')]
		[Bindable]
		public static var CARD_7D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_8D')]
		[Bindable]
		public static var CARD_8D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_9D')]
		[Bindable]
		public static var CARD_9D:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_10D')]
		[Bindable]
		public static var CARD_TD:Class;
		
		[Embed(source = '../cards/library.swf', symbol = 'CARD_JD')]
		[Bindable]
		public static var CARD_JD:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_QD')]
		[Bindable]
		public static var CARD_QD:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_KD')]
		[Bindable]
		public static var CARD_KD:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_AH')]
		[Bindable]
		public static var CARD_AH:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_2H')]
		[Bindable]
		public static var CARD_2H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_3H')]
		[Bindable]
		public static var CARD_3H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_4H')]
		[Bindable]
		public static var CARD_4H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_5H')]
		[Bindable]
		public static var CARD_5H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_6H')]
		[Bindable]
		public static var CARD_6H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_7H')]
		[Bindable]
		public static var CARD_7H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_8H')]
		[Bindable]
		public static var CARD_8H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_9H')]
		[Bindable]
		public static var CARD_9H:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_10H')]
		[Bindable]
		public static var CARD_TH:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_JH')]
		[Bindable]
		public static var CARD_JH:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_QH')]
		[Bindable]
		public static var CARD_QH:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_KH')]
		[Bindable]
		public static var CARD_KH:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_AC')]
		[Bindable]
		public static var CARD_AC:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_2C')]
		[Bindable]
		public static var CARD_2C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_3C')]
		[Bindable]
		public static var CARD_3C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_4C')]
		[Bindable]
		public static var CARD_4C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_5C')]
		[Bindable]
		public static var CARD_5C:Class;
	
		[Embed(source='../cards/library.swf', symbol='CARD_6C')]
		[Bindable]
		public static var CARD_6C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_7C')]
		[Bindable]
		public static var CARD_7C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_8C')]
		[Bindable]
		public static var CARD_8C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_9C')]
		[Bindable]
		public static var CARD_9C:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_10C')]
		[Bindable]
		public static var CARD_TC:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_JC')]
		[Bindable]
		public static var CARD_JC:Class;

		[Embed(source='../cards/library.swf', symbol='CARD_QC')]
		[Bindable]
		public static var CARD_QC:Class;

		[Embed(source='../cards/library.swf', symbol='CARD_KC')]
		[Bindable]
		public static var CARD_KC:Class;
		
		[Embed(source = '../cards/library.swf', symbol = 'CARD_AS')]
		[Bindable]
		public static var CARD_AS:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_2S')]
		[Bindable]
		public static var CARD_2S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_3S')]
		[Bindable]
		public static var CARD_3S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_4S')]
		[Bindable]
		public static var CARD_4S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_5S')]
		[Bindable]
		public static var CARD_5S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_6S')]
		[Bindable]
		public static var CARD_6S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_7S')]
		[Bindable]
		public static var CARD_7S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_8S')]
		[Bindable]
		public static var CARD_8S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_9S')]
		[Bindable]
		public static var CARD_9S:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_10S')]
		[Bindable]
		public static var CARD_TS:Class;
	
		[Embed(source='../cards/library.swf', symbol='CARD_JS')]
		[Bindable]
		public static var CARD_JS:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_QS')]
		[Bindable]
		public static var CARD_QS:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_KS')]
		[Bindable]
		public static var CARD_KS:Class;
		
		[Embed(source='../cards/library.swf', symbol='CARD_JOKER')]
		[Bindable]
		public static var CARD_JOKER:Class;
		
		/**
		 * Draw a card based on the library
		 * @param	c
		 * @param	spr
		 * @param	w
		 * @param	h
		 * @param	offx
		 * @param	offy
		 */
		public static function drawCard(c:String, spr:Sprite, w: int, h: int, offx:int = 0, offy:int = 0):void {
			if (TTCardImages[c]) {
				var bd:BitmapData = new BitmapData(w, h, true, 0x00000000);
				var transform:Matrix = new Matrix();
				transform.scale(.5, .5);
				bd.draw(new TTCardImages[c](), transform);
				transform = new Matrix();
				transform.translate(-offx, -offy);
				spr.graphics.beginBitmapFill(bd, transform, true);
				spr.graphics.drawRect(0+offx, 0+offy, w - 1, h - 1);
			} else 
				trace("Error, no such card in image library: "+c);
		}
	}
}