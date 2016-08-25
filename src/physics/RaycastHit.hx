package physics;

import luxe.Vector;
import components.physics.Collider;


/** Information returned about an object detected by a raycast in 2D physics. */
@:publicFields
class RaycastHit {

        /** The centroid of the primitive used to perform the cast. */
    var centroid:Vector;
        /** Collider the intersection was with. */
    var collider:Collider;
        /** The distance from the ray origin to the impact point. */
    var distance:Float = 0.0;
        /** Fraction of the distance along the ray that the hit occurred. */
    var fraction:Float = 0.0;
    var fractionLast:Float = 1.0;
        /** The normal vector of the surface hit by the ray. */
    var normal:Vector;
        /** The point in world space where the ray hit the collider's surface. */
    var point:Vector;
        /** The point in world space where the ray out the collider's surface. */
    var pointOut:Vector;

    @:noCompletion
    inline function new() {

        centroid = new Vector();
        normal = new Vector();
        point = new Vector();
        pointOut = new Vector();
        
    }

    inline function destroy() {

        centroid = null;
        normal = null;
        point = null;
        pointOut = null;
        collider = null;
        
        distance = 0.0;
        fraction = 0.0;
        fractionLast = 1.0;

    } //destroy

    inline function reset() {

        centroid.x = 0;
        centroid.y = 0;

        distance = 0;
        fraction = 0;
        fractionLast = 1;

        normal.x = 0;
        normal.y = 0;

        point.x = 0;
        point.y = 0;

        pointOut.x = 0;
        pointOut.y = 0;

        return this;

    } //reset

    inline function copy_from(other:RaycastHit) {


        centroid.x = other.centroid.x;
        centroid.y = other.centroid.y;

        collider = other.collider;

        distance = other.distance;
        fraction = other.fraction;
        fractionLast = other.fractionLast;

        normal.x = other.normal.x;
        normal.y = other.normal.y;

        point.x = other.point.x;
        point.y = other.point.y;

        pointOut.x = other.pointOut.x;
        pointOut.y = other.pointOut.y;

    } //copy_from

    inline function clone() {

        var _clone = new RaycastHit();

        _clone.copy_from(this);

        return _clone;

    } //clone


} //RaycastHit
