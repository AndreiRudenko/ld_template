package components.movement;

import luxe.Component;
import luxe.Entity;
import luxe.Vector;
import luxe.Input;

import utils.Mathf;
import physics.CollisionFaces;

import components.physics.Collider;
import components.input.InputComponent;


class Sticking extends Component{


	public var stickBreakTime:Float = 0.4;
	public var gravSlideFactor:Float = 0.3;
	public var isSticking:Bool = false;
	public var allowSticking:Bool = true;

	var canStick:Bool = false;
	var stickTime:Float = 0;

	var collider:Collider;
	var moveComp:Move;
	var inputComp:InputComponent;


	public function new(_time:Float = 0.4, _slideFactor:Float = 0.3){

		super({name : 'Sticking'});
		stickBreakTime = _time;
		gravSlideFactor = _slideFactor;

	}
	
	override public function init() {
		
		inputComp = get("InputComponent");
		if(inputComp == null) throw(entity.name + " Sticking must have Input Component");

		collider = get("Collider");
		if(collider == null) throw(entity.name + " Sticking must have Collider Component");
		
		moveComp = get("MoveComponent");
		if(moveComp == null) throw(entity.name + " Sticking must have Move Component");

	}

	override public function update(dt:Float) {

		if(!allowSticking) {
			return;
		}

		if ((!collider.isTouching(CollisionFaces.WALL) && !canStick) || collider.isTouching(CollisionFaces.FLOOR) && !canStick) {
			isSticking = false;
			canStick = true;
			moveComp.allowX = true;
		} 

		if (((collider.isTouching(CollisionFaces.RIGHT) && !collider.isTouching(CollisionFaces.RIGHT_PLAYER) && collider.velocity.x >= 0)
			|| (collider.isTouching(CollisionFaces.LEFT) && !collider.isTouching(CollisionFaces.LEFT_PLAYER) && collider.velocity.x <= 0))
			&& canStick && !collider.isTouching(CollisionFaces.FLOOR)) 
		{
			isSticking = true;
			canStick = false;
			moveComp.allowX = false;
			collider.velocity.x = 0; 
		}

		if(isSticking){
			if(collider.velocity.y > 0){
				collider.velocity.y = Mathf.ApValue(collider.velocity.y, 0, gravSlideFactor);
			}

			if(inputComp.right){
				if(collider.isTouching(CollisionFaces.LEFT)){
					stickTime += dt;
					if(stickTime >= stickBreakTime){
						isSticking = false;
						moveComp.allowX = true;
						stickTime = 0.0;
					}
				}
			} else if(inputComp.left){
				if(collider.isTouching(CollisionFaces.RIGHT)){
					stickTime += dt;
					if(stickTime >= stickBreakTime){
						isSticking = false;
						moveComp.allowX = true;
						stickTime = 0.0;
					}
				}
			} else {
				stickTime = 0.0;
			}
		}

	}


}



