package utils;

// import physics.Body;
// import physics.AABB;

import phoenix.Color;
import phoenix.Batcher;
import luxe.Vector;

class ShapeDrawer {

	// public static var batcher:Batcher = Main.hud_batcher;
	public static var depth:Float = 100.0;

	public static var color_black = new Color(0,0,0,0);
	public static var color_black_05 = new Color(0,0,0,0.5);
	public static var color_black_01 = new Color(0,0,0,0.1);
	public static var color_gray = new Color(1,1,1,0.5);
	public static var color_gray_01 = new Color(1,1,1,0.1);
	public static var color_gray_05 = new Color(1,1,1,0.5);
	public static var color_white = new Color(1,1,1,1);
	public static var color_orange_02 = new Color(1,0.6,0,0.5);
	public static var color_green:Color = new Color().rgb(0x3ED867);
	public static var color_green2:Color = new Color().rgb(0xA6F145);
	public static var color_blue:Color = new Color().rgb(0x4487C8);
	public static var color_bluegreen:Color = new Color().rgb(0xA6F145);
	public static var color_orange:Color = new Color().rgb(0xFFB549);
	public static var color_purple:Color = new Color().rgb(0x6D4CCE);
	public static var color_red:Color = new Color().rgb(0xFA4859);
	public static var color_yellow:Color = new Color().rgb(0xFFF949);
	public static var color_pink:Color = new Color().rgb(0xE84288);



	inline public static function drawLine( start:Vector, end:Vector, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher ) {
		if(color == null) color = color_orange;
		
		return Luxe.draw.line({
			p0: new Vector(start.x, start.y),
			p1: new Vector(end.x, end.y),
			color: color,
			depth: depth,
			batcher: _batcher,
			immediate: _immediate
		});
	}

	inline public static function drawRay( origin:Vector, dir:Vector, dist:Float, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher ) {
		if(color == null) color = color_orange;

		Luxe.draw.line({
			p0: origin,
			p1: new Vector(origin.x + dir.x * dist, origin.y + dir.y * dist),
			color: color,
			depth: depth,
			batcher: _batcher,
			immediate: _immediate
		});

	}

	inline public static function drawBox( boxPos:Vector, boxHalf:Vector, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher ) {
		if(color == null) color = color_orange;

		return Luxe.draw.rectangle({
			x : boxPos.x, 
			y : boxPos.y,
			w : boxHalf.x * 2,
			h : boxHalf.y * 2,
			origin : new Vector( boxHalf.x, boxHalf.y),
			color : color,
			depth : depth,
			batcher: _batcher,
			immediate : _immediate
		});

	}

	inline public static function drawBox_MinMax( min:Vector, max:Vector, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher ) {
		if(color == null) color = color_orange;

		var w:Float = max.x - min.x;
		var h:Float = max.y - min.y;
		var cx:Float = min.x + w * 0.5;
		var cy:Float = min.y + h * 0.5;
		return Luxe.draw.rectangle({
			x : cx, 
			y : cy,
			w : w,
			h : h,
			origin : new Vector( w * 0.5, h * 0.5),
			color : color,
			depth : depth,
			batcher: _batcher,
			immediate : _immediate
		});

	}

	inline public static function drawCircle( cPos:Vector, rad:Float, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher ) {
		if(color == null) color = color_orange;
		
		return Luxe.draw.ring({
			x: cPos.x,
			y: cPos.y,
			r: rad,
			color: color,
			depth: depth,
			batcher: _batcher,
			immediate: _immediate
		});
	} 

	inline public static function drawPoint( x:Float, y:Float, size:Float = 4, ?color:Color, ?_immediate:Bool = true, ?_batcher:Batcher) {
		if(color == null) color = color_orange;

		return Luxe.draw.ring({
			x: x,
			y: y,
			r: size,
			color: color,
			depth: depth,
			batcher: _batcher,
			immediate: _immediate
		});

	}

	inline public static function drawText( _x:Float, _y:Float, text:Dynamic, size:Int = 12, _immediate:Bool = true, ?_batcher:Batcher ) {

		return Luxe.draw.text({
			pos : new Vector(_x, _y),
			text : Std.string(text),
			point_size : size,
			depth : depth,
			batcher: _batcher,
			immediate : _immediate
		});

	}
	
}
