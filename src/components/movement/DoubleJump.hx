package components.movement;

import luxe.Component;
import luxe.Entity;
import luxe.Vector;
import luxe.Input;

import physics.CollisionFaces;

import components.physics.Collider;
import components.input.InputComponent;


class DoubleJump extends Component{


	public var maxJumps:Int = 1;
	public var jumpCount:Int = 0;
	public var factor:Float = 0.5;

	var inputComp:InputComponent;
	var collider:Collider;
	var jumpComp:Jump;
	var stickComp:Sticking;


	public function new(_mj:Int = 1, _factor:Float = 0.5){

		super({name : 'DoubleJump'});
		maxJumps = _mj;
		factor = _factor;

	}
	
	override public function init() {


		inputComp = get("InputComponent");
		if(inputComp == null) {
			throw(entity.name + " must have Input component");
		}

		stickComp = get("Sticking");
		// if(stickComp == null) throw(entity.name + " must have Sticking component");

		jumpComp = get("Jump");
		if(jumpComp == null) {
			throw(entity.name + " must have Jump component");
		}

		collider = get("Collider");
		if(collider == null) {
			throw(entity.name + " must have Collider component");
		}

	}
	
	override public function update(dt:Float) {

		if(!collider.isTouching(CollisionFaces.FLOOR)){
			if (inputComp.jump && jumpComp.jumpState == Jump.START && jumpCount < maxJumps) {
				
				if(stickComp != null && stickComp.isSticking) {
					return;
				}

				jumpCount++;
				collider.velocity.y = -jumpComp.jumpVelocity * jumpComp.factor * factor;
				jumpComp.jumpTime = 0;
				jumpComp.jumpState = Jump.UP;

			}
		} else {
			jumpCount = 0;
		}

	}

	
}



