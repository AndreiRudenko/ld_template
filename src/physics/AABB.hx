package physics;

import luxe.Vector;
import utils.ShapeDrawer;


class AABB{


	public var max : Vector;
	public var min : Vector;


	public function new(_min:Vector = null, _max:Vector = null) {

		min = _min != null ? _min : new Vector();
		max = _max != null ? _max : new Vector();

	}

    public function point_inside( _p:Vector ) {

		if (_p.x < min.x || _p.x > max.x) return false;
		if (_p.y < min.y || _p.y > max.y) return false;

		return true;

    }

    public function overlaps( _other:AABB ) {

		if ( _other.max.x < min.x || _other.min.x > max.x ) return false;
		if ( _other.max.y < min.y || _other.min.y > max.y ) return false;

		return true;

    }

    public function overlaps_min_max( _min:Vector, _max:Vector ) {

		if ( _max.x < min.x || _min.x > max.x ) return false;
		if ( _max.y < min.y || _min.y > max.y ) return false;

		return true;

    }

    public function copy_from( _other:AABB ) {

        min.x = _other.min.x;
        min.y = _other.min.y;
        max.x = _other.max.x;
        max.y = _other.max.y;

    }

	public function clone():AABB{

	    return new AABB(min.clone(), max.clone());

	}

	public inline function draw(){

        ShapeDrawer.drawBox_MinMax(min, max, ShapeDrawer.color_white);  

	}

	public function destroy(){

		max = null;
		min = null;

	}

    public static function Listen( _aabb:AABB, listener ) {

        _aabb.min.listen_x = listener;
        _aabb.min.listen_y = listener;
        _aabb.max.listen_x = listener;
        _aabb.max.listen_y = listener;

    }

    
}
