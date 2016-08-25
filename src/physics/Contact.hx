package physics;

import luxe.Vector;

import components.physics.Collider;

import utils.ShapeDrawer;


@:publicFields
class Contact {


	/* shape1 */
	var collider:Collider;
	/* shape2 */
	var otherCollider:Collider;
	/* The separation amount */
	var separation:Float = 0.0;
	/* normal */
	var normal:Vector;
	/* relative velocity */
	var velocity:Vector;
	/* The point of contact between the two shapes. */
	var point:Vector;
	/* first time of collision */
	var time:Float = 0.0;
	/* last time of collision */
	var timeLast:Float = 1.0;
	/* should be removed */
	var remove:Bool = false;

	var isCollide:Bool = false;
	
	var wasCollide:Bool = false;

	var prev:Contact;
	var next:Contact;


    @:noCompletion
    inline function new() {

		normal = new Vector();
		point = new Vector();
		velocity = new Vector();

		prev = null;
		next = null;

	}

	inline function clone(){

		var c:Contact = new Contact();
		
		c.collider = collider;
		c.otherCollider = otherCollider;
		c.separation = separation;
		c.normal = normal.clone();
		c.velocity = velocity.clone();
		c.point = point.clone();
		c.time = time;
		c.timeLast = timeLast;
		c.remove = remove;
		c.isCollide = isCollide;
		c.wasCollide = wasCollide;

		return c;

	}

	inline function reset(){

	    separation = 0;

		normal.x = 0;
		normal.y = 0;

		point.x = 0;
		point.y = 0;

		time = 0;
		timeLast = 1;
		
		return this;

	}

    inline function toString() {

        return 
        "collider: " + collider.id 
        + "\notherCollider: " + otherCollider.id 
        + "\npenetration: " + separation 
        + "\nnormal: " + normal 
        + "\npoint: " + point 
        + "\ntime: " + time
        + "\ntimeLast: " + timeLast
        ;

    }

	inline function destroy():Void{

	    collider = null;
	    otherCollider = null;

		point = null;
	    normal = null;

		prev = null;
		next = null;

	}

	inline function swapColliders():Void{

	    var _cA:Collider = collider;
	    collider = otherCollider;
	    otherCollider = _cA;

	}

    public function draw(immediate:Bool = true){

        if(isCollide){
            ShapeDrawer.drawLine(collider.position, otherCollider.position, ShapeDrawer.color_blue, immediate);
        } else {
            ShapeDrawer.drawLine(collider.position, otherCollider.position, ShapeDrawer.color_gray, immediate);
        }
        
        // ShapeDrawer.drawBox_MinMax(min, max, ShapeDrawer.color_gray, immediate);  

        // if(!isStatic){
        //     // ShapeDrawer.drawBox(nextPos, half, ShapeDrawer.color_yellow);
        //     ShapeDrawer.drawLine(position, Vector.Multiply(velocity, Luxe.physics.step_delta).add(position), ShapeDrawer.color_green, immediate);
        // }
    }


}
