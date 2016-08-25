package physics.collision;

import luxe.Vector;

import physics.Contact;
import physics.RaycastHit;

import components.physics.Collider;


class IntersectAABB {


	public static function test(into:Contact) : Bool {

		var bodyA:Collider = into.collider; 
		var bodyB:Collider = into.otherCollider; 

		if(bodyA.entity.destroyed || bodyB.entity.destroyed) {
			return false;
		}

		var dx:Float = bodyA.position.x - bodyB.position.x;
		var px:Float = (bodyB.half.x + bodyA.half.x) - Math.abs(dx);

		if (px < 0) {
			return false;
		}

		var dy:Float = bodyA.position.y - bodyB.position.y;
		var py:Float = (bodyB.half.y + bodyA.half.y) - Math.abs(dy);

		if (py < 0) {
			return false;
		}

		into.reset();

		if (px < py) {
			into.separation = px;
			into.normal.x = (dx >= 0) ? 1 : -1;
		} else {
			into.separation = py;
			into.normal.y = (dy >= 0) ? 1 : -1;
		}

		// find contact points
		closestPointOnBox(
			bodyA.position.x,
			bodyA.position.y,
			bodyB.position.x, 
			bodyB.position.y, 
			bodyB.half.x, 
			bodyB.half.y, 
			into.point
		 );

		return true;

	}

	inline public static function closestPointOnBox(pposX:Float, pposY:Float, bposX:Float, bposY:Float, bhalfX:Float, bhalfY:Float, out:Vector):Bool {

		var deltaX:Float = pposX - bposX;
		var deltaY:Float = pposY - bposY;

		var inside:Bool = true;

		if (Math.abs(deltaX) > bhalfX)  {
			inside = false;
			deltaX = bhalfX * (deltaX >= 0 ? 1 : -1);
		}

		if (Math.abs(deltaY) > bhalfY) {
			inside = false;
			deltaY = bhalfY * (deltaY >= 0 ? 1 : -1);
		}

		// point was found outside. all good.
		if(!inside){
			out.x = bposX + deltaX;
			out.y = bposY + deltaY;
			return inside;
		}

		// find the mtd (Minimum Translation Distance).
		// calculate the distance of the point form one face along each axes.
		var mtdX:Float = (bhalfX - Math.abs(deltaX)) * (deltaX >= 0 ? 1 : -1);
		var mtdY:Float = (bhalfY - Math.abs(deltaY)) * (deltaY >= 0 ? 1 : -1);

		// Find the minimum of the three.
		if (Math.abs(mtdX) < Math.abs(mtdY)) {
			mtdY = 0.0;
		} else {
			mtdX = 0.0;
		}

		// point on surface
		out.x = pposX + mtdX;
		out.y = pposY + mtdY;

		return inside;

	}
	

}
