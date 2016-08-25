import luxe.Vector;


	/** simple intersection tests */
class Intersect {


	public static inline var EPSILON:Float = 1.0E-8;

	inline public static function AABBAABB(b1pos:Vector, b1half:Vector, b2pos:Vector, b2half:Vector ):Bool{ // fastest

		if(Math.abs(b1pos.x - b2pos.x) > b1half.x + b2half.x) return false;
		if(Math.abs(b1pos.y - b2pos.y) > b1half.y + b2half.y) return false;

		return true;
	}

	inline public static function AABBAABB2(b1posX:Float, b1posY:Float, b1half:Vector, b2pos:Vector, b2half:Vector ):Bool{ // fastest

		if(Math.abs(b1posX - b2pos.x) > b1half.x + b2half.x) return false;
		if(Math.abs(b1posY - b2pos.y) > b1half.y + b2half.y) return false;

		return true;

	}

	inline public static function BoundsBounds(box1min:Vector, box1max:Vector, box2min:Vector, box2max:Vector):Bool{

		if (box1max.x < box2min.x || box1min.x > box2max.x) return false;
		if (box1max.y < box2min.y || box1min.y > box2max.y) return false;

		return true;

	}

	inline public static function PointAABB(point:Vector, boxPos:Vector, boxHalf:Vector):Bool{

		if(Math.abs(boxPos.x - point.x) > boxHalf.x) return false;
		if(Math.abs(boxPos.y - point.y) > boxHalf.y) return false;

		return true;

	}

	inline public static function PointBounds(point:Vector, boxMin:Vector, boxMax:Vector):Bool{

		if ( point.x < boxMin.x || point.x > boxMax.x ) return false;
		if ( point.y < boxMin.y || point.y > boxMax.y ) return false;

		return true;

	}


    inline public static function CircleCircle( c1pos:Vector, c1r:Float, c2pos:Vector, c2r:Float) : Bool {

        var dx:Float = c1pos.x - c2pos.x;
        var dy:Float = c1pos.y - c2pos.y;
        var r:Float = c1r + c2r;

		return (dx * dx + dy * dy) < (r * r);

    }

	inline public static function CircleAABB(circlePos:Vector, radius:Float, boxPos:Vector, boxHalf:Vector):Bool {

		var cpX:Float = circlePos.x;
		var cpY:Float = circlePos.y;

		var minX:Float = boxPos.x - boxHalf.x;
		var minY:Float = boxPos.y - boxHalf.y;
		var maxX:Float = boxPos.x + boxHalf.x;
		var maxY:Float = boxPos.y + boxHalf.y;

		if (cpX < minX) cpX = minX;
		if (cpX > maxX) cpX = maxX;
		if (cpY < minY) cpY = minY;
		if (cpY > maxY) cpY = maxY;

	    var diffX:Float = circlePos.x - cpX;
	    var diffY:Float = circlePos.y - cpY;

	    return ( diffX * diffX + diffY * diffY < radius * radius );

	}

	inline public static function CircleBounds(circlePos:Vector, radius:Float, bmin:Vector, bmax:Vector):Bool {

		var cpX:Float = circlePos.x;
		var cpY:Float = circlePos.y;

		if (cpX < bmin.x) cpX = bmin.x;
		if (cpX > bmax.x) cpX = bmax.x;
		if (cpY < bmin.y) cpY = bmin.y;
		if (cpY > bmax.y) cpY = bmax.y;

	    var diffX:Float = circlePos.x - cpX;
	    var diffY:Float = circlePos.y - cpY;

	    return ( diffX * diffX + diffY * diffY < radius * radius );

	}

	inline public static function PointCircle(point:Vector, circlePos:Vector, radius:Float):Bool {

		var deltaX:Float = point.x - circlePos.x;
		var deltaY:Float = point.y - circlePos.y;
		var d2:Float = (deltaX * deltaX + deltaY * deltaY);
		var r2:Float = radius * radius;

		return (d2 <= r2);

	}
	

}
