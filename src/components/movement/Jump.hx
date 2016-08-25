package components.movement;

import luxe.Input;
import luxe.Component;
import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;

import utils.Mathf;
import utils.ShapeDrawer;

import physics.CollisionFaces;

import components.physics.Gravity;
import components.physics.Collider;
import components.input.InputComponent;


class Jump extends Component{


	public static inline var START:Int = 0;
	public static inline var UP:Int = 1;
	public static inline var FALLING:Int = 2;
	public static inline var END:Int = 3;


	public var jumpState:Int = 0;

	public var jumpVelocity:Float = 0;

	public var jumpTime:Float = 0;
	public var factor:Float = 1;

	public var dropJumpVel:Bool = true;
	public var ghostJumpTime:Float = 0.08;

	var gJumpTimer:Float = 0;
	var jumpStartPos:Float = 0;
	var jumpHeight:Float = 0;
	var minJumpHeight:Float = 64; // 64
	
	var gravity:Gravity;
	var collider:Collider;
	var inputComp:InputComponent;


	public function new(_jumpVel:Float){

		super({name : "Jump"});

		jumpVelocity = _jumpVel;

	}

	override public function init() {

		inputComp = get("InputComponent");
		if(inputComp == null) {
			throw(entity.name + " must have Input component");
		}

		collider = get("Collider");
		if(collider == null) {
			throw(entity.name + " must have Collider component");
		}

		gravity = get("Gravity");
		if(gravity == null) {
			throw(entity.name + " must have Gravity component");
		}
		
	}    


	override public function onremoved() {

		collider = null;
		inputComp = null;

	}


	override public function update(dt:Float) {

		if(!collider.isTouching(CollisionFaces.FLOOR)) {
			gJumpTimer += dt;
		} else {
			gJumpTimer = 0;
		}

		switch (jumpState) {

			case 0 : { // START
				if((inputComp.jump && collider.isTouching(CollisionFaces.FLOOR)) || (inputComp.jump && gJumpTimer < ghostJumpTime)) {
					collider.velocity.y = -jumpVelocity * factor;
					jumpTime = 0;
					gJumpTimer = ghostJumpTime;
					jumpState = UP;

					jumpStartPos = collider.position.y;
					jumpHeight = 0;
				}
			} // case 0

			case 1 : { // UP
				if(collider.velocity.y < 0){
					jumpHeight = jumpStartPos - collider.position.y;

					jumpTime += dt;
					if(inputComp.jump){
						gravity.gravityScale = 1;
					} else if(jumpHeight >= minJumpHeight){
						if(dropJumpVel) {
							collider.velocity.y *= 0.5;
						} else {
							gravity.gravityScale = 1;
						}

						jumpState = FALLING;
					}
				} else {
					jumpState = FALLING;
				}
			} // case 1

			case 2 : { // FALLING
				gravity.gravityScale = 1;

				if(!inputComp.jump){
					jumpState = START;
				}

				if(collider.isTouching(CollisionFaces.FLOOR)){
					jumpState = END;
				}
			} // case 2

			case 3 : { // END
				if(!inputComp.jump){
					jumpState = START;
				}
			} // case 3

		} // switch
		
	}


}

