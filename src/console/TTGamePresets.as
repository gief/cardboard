package console 
{
	/**
	 * Contains snapshots of a game. Used to start a game.
	 * 
	 * @author Gifford Cheung
	 */
	public class TTGamePresets 
	{
		public function TTGamePresets() { }
		public static const g1: String = 
		"{\"game_id\":\"74ab\",\"name\":\"74ab\",\"latest_message_number\":0,\"owner_id\":\"t1\"}";

		public static const a1: String = 
		"[{\"w\":600,\"r\":0,\"x\":100,\"owner\":\"-1\",\"y\":100,\"h\":600,\"id\":9001}," +
		"{\"w\":700,\"r\":0,\"x\":100,\"owner\":\"unassigned_private\",\"y\":700,\"h\":100,\"id\":19003}," + 
		"{\"w\":700,\"r\":90,\"x\":100,\"owner\":\"unassigned_private\",\"y\":100,\"h\":100,\"id\":48001}," +
		"{\"w\":700,\"r\":180,\"x\":700,\"owner\":\"unassigned_private\",\"y\":100,\"h\":100,\"id\":23002}," + 
		"{\"w\":700,\"r\":-90,\"x\":700,\"owner\":\"unassigned_private\",\"y\":700,\"h\":100,\"id\":22003}]";
		 
		public static const c1: String = "[" 
			+ chips(10, 00, 00, 9001, 200, 100, 1500) + "," 
			+ chips(10, 00, 00, 9001, 220, 100, 1600) + "," 
			+ chips(10, 00, 00, 9001, 240, 100, 1700) + ","  
			+ chips(10, 00, 00, 9001, 270, 100, 1800) + ","  
			+ chips(10, 00, 00, 9001, 290, 100, 1900) + "," 
			+ chips(10, 00, 00, 9001, 310, 100, 2000) + "," 
			+ chips(10, 00, 00, 9001, 340, 100, 2100) + ","  
			+ chips(10, 00, 00, 9001, 360, 100, 2200) + ","  
			+ chips(10, 00, 00, 9001, 380, 100, 2300) + "," 
			+ chips(10, 00, 00, 9001, 410, 100, 2400) + "," 
			+ chips(10, 00, 00, 9001, 430, 100, 2500) + ","  
			+ chips(10, 00, 00, 9001, 450, 100, 2600) + ","  
			+ JSON.stringify( { /* red Dealer chip */
				area_id: 9001, 
				card_id:8000,
				back: 0, 
				front: 0, 
				r: 0, 
				data: "dealer", 
				x: 200, y:200, 
				isChip: true, 
				chipColor: "0xff0000", h: 40, w: 40, halfh: 20, halfw: 20 } )
			+ ","
			+ JSON.stringify( {  /* yellow Current player chip */
				area_id: 9001, 
				card_id:8050,
				back: 0, 
				front: 0, 
				r: 0, 
				data: "current", 
				x: 250, y:250, 
				isChip: true, 
				chipColor: "0xffff00", h: 30, w: 30, halfh: 15, halfw: 15 } )
			+ ","
			+
		"{\"area_id\":9001,\"r\":0,\"card_id\":14001,\"face_up\":false,\"data\":null,\"x\":27,\"y\":37,\"back\":\"back\",\"front\":\"4D\"}," +
		"{\"area_id\":9001,\"r\":0,\"card_id\":31001,\"face_up\":false,\"data\":null,\"x\":27,\"y\":37,\"back\":\"back\",\"front\":\"8C\"}," +
		"{\"area_id\":9001,\"r\":0,\"card_id\":16001,\"face_up\":false,\"data\":null,\"x\":27,\"y\":38,\"back\":\"back\",\"front\":\"6D\"}," + 
		"{\"area_id\":9001,\"r\":0,\"card_id\":21001,\"face_up\":false,\"data\":null,\"x\":28,\"y\":39,\"back\":\"back\",\"front\":\"JD\"},{\"area_id\":9001,\"r\":0,\"card_id\":24001,\"face_up\":false,\"data\":null,\"x\":28,\"y\":39,\"back\":\"back\",\"front\":\"AC\"},{\"area_id\":9001,\"r\":0,\"card_id\":32002,\"face_up\":false,\"data\":null,\"x\":30,\"y\":41,\"back\":\"back\",\"front\":\"AH\"},{\"area_id\":9001,\"r\":0,\"card_id\":29001,\"face_up\":false,\"data\":null,\"x\":30,\"y\":42,\"back\":\"back\",\"front\":\"6C\"},{\"area_id\":9001,\"r\":0,\"card_id\":34001,\"face_up\":false,\"data\":null,\"x\":30,\"y\":43,\"back\":\"back\",\"front\":\"3H\"},{\"area_id\":9001,\"r\":0,\"card_id\":33001,\"face_up\":false,\"data\":null,\"x\":31,\"y\":45,\"back\":\"back\",\"front\":\"2H\"},{\"area_id\":9001,\"r\":0,\"card_id\":22002,\"face_up\":false,\"data\":null,\"x\":31,\"y\":46,\"back\":\"back\",\"front\":\"6H\"},{\"area_id\":9001,\"r\":0,\"card_id\":17001,\"face_up\":false,\"data\":null,\"x\":33,\"y\":47,\"back\":\"back\",\"front\":\"7D\"},{\"area_id\":9001,\"r\":0,\"card_id\":11003,\"face_up\":false,\"data\":null,\"x\":34,\"y\":47,\"back\":\"back\",\"front\":\"JS\"},{\"area_id\":9001,\"r\":0,\"card_id\":10001,\"face_up\":false,\"data\":null,\"x\":35,\"y\":49,\"back\":\"back\",\"front\":\"KD\"},{\"area_id\":9001,\"r\":0,\"card_id\":46001,\"face_up\":false,\"data\":null,\"x\":36,\"y\":50,\"back\":\"back\",\"front\":\"7S\"},{\"area_id\":9001,\"r\":0,\"card_id\":25002,\"face_up\":false,\"data\":null,\"x\":37,\"y\":52,\"back\":\"back\",\"front\":\"9H\"},{\"area_id\":9001,\"r\":0,\"card_id\":11001,\"face_up\":false,\"data\":null,\"x\":37,\"y\":52,\"back\":\"back\",\"front\":\"AD\"},{\"area_id\":9001,\"r\":0,\"card_id\":13001,\"face_up\":false,\"data\":null,\"x\":37,\"y\":52,\"back\":\"back\",\"front\":\"3D\"},{\"area_id\":9001,\"r\":0,\"card_id\":27001,\"face_up\":false,\"data\":null,\"x\":39,\"y\":53,\"back\":\"back\",\"front\":\"4C\"},{\"area_id\":9001,\"r\":0,\"card_id\":37001,\"face_up\":false,\"data\":null,\"x\":41,\"y\":54,\"back\":\"back\",\"front\":\"8H\"},{\"area_id\":9001,\"r\":0,\"card_id\":26002,\"face_up\":false,\"data\":null,\"x\":43,\"y\":55,\"back\":\"back\",\"front\":\"TH\"},{\"area_id\":9001,\"r\":0,\"card_id\":28002,\"face_up\":false,\"data\":null,\"x\":44,\"y\":55,\"back\":\"back\",\"front\":\"2S\"},{\"area_id\":9001,\"r\":0,\"card_id\":36001,\"face_up\":false,\"data\":null,\"x\":45,\"y\":56,\"back\":\"back\",\"front\":\"7H\"},{\"area_id\":9001,\"r\":0,\"card_id\":35001,\"face_up\":false,\"data\":null,\"x\":47,\"y\":56,\"back\":\"back\",\"front\":\"5H\"},{\"area_id\":9001,\"r\":0,\"card_id\":44001,\"face_up\":false,\"data\":null,\"x\":48,\"y\":56,\"back\":\"back\",\"front\":\"5S\"},{\"area_id\":9001,\"r\":0,\"card_id\":32001,\"face_up\":false,\"data\":null,\"x\":49,\"y\":56,\"back\":\"back\",\"front\":\"TC\"},{\"area_id\":9001,\"r\":0,\"card_id\":19001,\"face_up\":false,\"data\":null,\"x\":50,\"y\":57,\"back\":\"back\",\"front\":\"9D\"},{\"area_id\":9001,\"r\":0,\"card_id\":41001,\"face_up\":false,\"data\":null,\"x\":50,\"y\":57,\"back\":\"back\",\"front\":\"AS\"},{\"area_id\":9001,\"r\":0,\"card_id\":20001,\"face_up\":false,\"data\":null,\"x\":51,\"y\":59,\"back\":\"back\",\"front\":\"TD\"},{\"area_id\":9001,\"r\":0,\"card_id\":25001,\"face_up\":false,\"data\":null,\"x\":52,\"y\":60,\"back\":\"back\",\"front\":\"2C\"},{\"area_id\":9001,\"r\":0,\"card_id\":45001,\"face_up\":false,\"data\":null,\"x\":53,\"y\":60,\"back\":\"back\",\"front\":\"6S\"},{\"area_id\":9001,\"r\":0,\"card_id\":22001,\"face_up\":false,\"data\":null,\"x\":53,\"y\":62,\"back\":\"back\",\"front\":\"QD\"},{\"area_id\":9001,\"r\":0,\"card_id\":12001,\"face_up\":false,\"data\":null,\"x\":54,\"y\":63,\"back\":\"back\",\"front\":\"2D\"},{\"area_id\":9001,\"r\":0,\"card_id\":39001,\"face_up\":false,\"data\":null,\"x\":54,\"y\":65,\"back\":\"back\",\"front\":\"QH\"},{\"area_id\":9001,\"r\":0,\"card_id\":47001,\"face_up\":false,\"data\":null,\"x\":54,\"y\":65,\"back\":\"back\",\"front\":\"8S\"},{\"area_id\":9001,\"r\":0,\"card_id\":11002,\"face_up\":false,\"data\":null,\"x\":55,\"y\":67,\"back\":\"back\",\"front\":\"JC\"},{\"area_id\":9001,\"r\":0,\"card_id\":40001,\"face_up\":false,\"data\":null,\"x\":55,\"y\":69,\"back\":\"back\",\"front\":\"KS\"},{\"area_id\":9001,\"r\":0,\"card_id\":13002,\"face_up\":false,\"data\":null,\"x\":55,\"y\":70,\"back\":\"back\",\"front\":\"9C\"},{\"area_id\":9001,\"r\":0,\"card_id\":43001,\"face_up\":false,\"data\":null,\"x\":56,\"y\":72,\"back\":\"back\",\"front\":\"4S\"},{\"area_id\":9001,\"r\":0,\"card_id\":19002,\"face_up\":false,\"data\":null,\"x\":56,\"y\":73,\"back\":\"back\",\"front\":\"4H\"},{\"area_id\":9001,\"r\":0,\"card_id\":10002,\"face_up\":false,\"data\":null,\"x\":58,\"y\":73,\"back\":\"back\",\"front\":\"TS\"},{\"area_id\":9001,\"r\":0,\"card_id\":15002,\"face_up\":false,\"data\":null,\"x\":59,\"y\":74,\"back\":\"back\",\"front\":\"KH\"},{\"area_id\":9001,\"r\":0,\"card_id\":12002,\"face_up\":false,\"data\":null,\"x\":59,\"y\":75,\"back\":\"back\",\"front\":\"QS\"},{\"area_id\":9001,\"r\":0,\"card_id\":23001,\"face_up\":false,\"data\":null,\"x\":60,\"y\":75,\"back\":\"back\",\"front\":\"KC\"},{\"area_id\":9001,\"r\":0,\"card_id\":30001,\"face_up\":false,\"data\":null,\"x\":62,\"y\":76,\"back\":\"back\",\"front\":\"7C\"},{\"area_id\":9001,\"r\":0,\"card_id\":9002,\"face_up\":false,\"data\":null,\"x\":63,\"y\":76,\"back\":\"back\",\"front\":\"9S\"},{\"area_id\":9001,\"r\":0,\"card_id\":15001,\"face_up\":false,\"data\":null,\"x\":64,\"y\":78,\"back\":\"back\",\"front\":\"5D\"},{\"area_id\":9001,\"r\":0,\"card_id\":28001,\"face_up\":false,\"data\":null,\"x\":64,\"y\":78,\"back\":\"back\",\"front\":\"5C\"},{\"area_id\":9001,\"r\":0,\"card_id\":42001,\"face_up\":false,\"data\":null,\"x\":66,\"y\":79,\"back\":\"back\",\"front\":\"3S\"},{\"area_id\":9001,\"r\":0,\"card_id\":14002,\"face_up\":false,\"data\":null,\"x\":67,\"y\":80,\"back\":\"back\",\"front\":\"QC\"},{\"area_id\":9001,\"r\":0,\"card_id\":26001,\"face_up\":false,\"data\":null,\"x\":67,\"y\":81,\"back\":\"back\",\"front\":\"3C\"},{\"area_id\":9001,\"r\":0,\"card_id\":38001,\"face_up\":false,\"data\":null,\"x\":69,\"y\":82,\"back\":\"back\",\"front\":\"JH\"},{\"area_id\":9001,\"r\":0,\"card_id\":18001,\"face_up\":false,\"data\":null,\"x\":70,\"y\":83,\"back\":\"back\",\"front\":\"8D\"}]";
		
		/**
		 * Function to generating the snapshot string to describe chips. Note that reds and blues are not tested with the chip counting code
		 * @param	whites - number of white chips
		 * @param	reds - number of red chips
		 * @param	blues - number of blue chips
		 * @param	area - what area the chips should be in
		 * @param	x - location of the first chip
		 * @param	y - location of the first chip
		 * @param	id_start - a starting number for generating card ids for each chip
		 * @return String of snapshot of chips
		 */
		public static function chips(whites: Number, reds: Number, blues: Number, area:Number, x: Number, y: Number, id_start: Number): String {
			var chips:String = "";
			var i:Number = 0;
			for (i = 0; i < whites; i += 1) {
				if (chips.length > 0) chips += ",";
				chips += JSON.stringify( { 
											area_id: area, 
											card_id:id_start,
											back: 5, 
											front: 5, 
											r: 0, 
											data: 1, 
											x: x, y:y, 
											isChip: true, 
											chipColor: "0xffffff", h: 20, w: 20, halfh: 10, halfw: 10 } );
				y += 5;
				id_start += 1;
			}
			
			for (i = 0; i < reds; i += 1) {
				if (chips.length > 0) chips += ",";
				chips += JSON.stringify( { 
											area_id: area, 
											back: 5, 
											front: 5, 
											card_id: id_start,
											r: 0, 
											data: 5, 
											x: x, y:y, 
											isChip: true, 
											chipColor: "0xff0000", h: 20, w: 20, halfh: 10, halfw: 10 } );
				y += 5;
				id_start += 1;
			}
			for (i = 0; i < blues; i += 1) {
				if (chips.length > 0) chips += ",";
				chips += JSON.stringify( { 
											area_id: area, 
											back: 5, 
											front: 5, 
											card_id: id_start,
											r: 0, 
											data: 10, 
											x: x, y:y, 
											isChip: true, 
											chipColor: "0x0000ff", h: 20, w: 20, halfh: 10, halfw: 10 } );
				y += 5;			
				id_start += 1;
			}
			return chips;
		}
		public static const p1: String =
		"[\"t1\",\"t2\",\"t3\",\"t4\"]";
		public static const me1: String = 
		"{\"self\":\"t1\", \"rotation\":0}"; // have it rotate.	
	}

}
