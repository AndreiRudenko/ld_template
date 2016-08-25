package utils;

import luxe.utils.Maths;


class Mathf{


	inline public static function ApValue(start:Float, end:Float, shift:Float):Float {

		if (start < end) {
			return  Math.min(start + shift, end);
		} else {
			return Math.max(start - shift, end);
		}

	} 

	inline public static function ApValueT(start:Float, end:Float, shift:Float, dt:Float):Float {

		if (start < end) {
			return  Math.min(start + shift * dt, end);
		} else {
			return Math.max(start - shift * dt, end);
		}

	} 
	
	inline public static function ApFriction(vel:Float, value:Float):Float {

		// value 100 = return 0
		var ret:Float = vel * Maths.clamp(value, 0.0, 1.0);
		if(Math.abs(ret) > 0.1){
			return ret;
		} else {
			return 0;
		}

	} 

	inline public static function ApFrictionT(start:Float, shift:Float, dt:Float):Float {

		var ret:Float = start * Maths.clamp(1.0 - dt * shift, 0.0, 1.0);
		if(Math.abs(ret) > 0.1){
			return ret;
		} else {
			return 0;
		}

	} 

	
}
