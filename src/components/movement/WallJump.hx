package components.movement;

import luxe.Component;
import luxe.Entity;
import luxe.Vector;
import luxe.Input;

import physics.CollisionFaces;

import components.physics.Collider;
import components.input.InputComponent;


class WallJump extends Component{


    var inputComp:InputComponent;
    var jumpComp:Jump;
    var moveComp:Move;
    var collider:Collider;


    public function new(){

        super({name : 'WallJump'});

    }
    
    override public function init() {
        // trace(entity.name + ' init WallJump');
        
        inputComp = get("InputComponent");
        if(inputComp == null) throw(entity.name + " must have Input component");

        jumpComp = get("Jump");
        if(jumpComp == null) throw(entity.name + " must have Jump component");

        moveComp = get("MoveComponent");
        if(moveComp == null) throw(entity.name + " must have Move component");

        collider = get("Collider");
        if(collider == null) throw(entity.name + " must have Collider component");

    }
    
    override public function update(dt:Float) {

        if(!collider.isTouching(CollisionFaces.FLOOR) && inputComp.jump) {
            if(collider.isTouching(CollisionFaces.LEFT) && jumpComp.jumpState == Jump.START && !collider.isTouching(CollisionFaces.FLOOR | CollisionFaces.LEFT_PLAYER)){
                jumpComp.jumpState = Jump.UP;

                // moveComp.allowX = true;

                if(inputComp.left){
                    collider.velocity.y = -jumpComp.jumpVelocity * jumpComp.factor;
                    collider.velocity.x = moveComp.maxSpeed.x;
                } else {
                    collider.velocity.y = -jumpComp.jumpVelocity * jumpComp.factor;
                    collider.velocity.x = moveComp.maxSpeed.x + Settings.UNIT;
                    // collider.velocity.x = jumpComp.jumpVelocity * 1 *jumpComp.factor;
                }
            }   

            if(collider.isTouching(CollisionFaces.RIGHT) && jumpComp.jumpState == Jump.START && !collider.isTouching(CollisionFaces.FLOOR | CollisionFaces.RIGHT_PLAYER)){
                jumpComp.jumpState = Jump.UP;

                // moveComp.allowX = true;

                if(inputComp.right){
                    collider.velocity.y = -jumpComp.jumpVelocity * jumpComp.factor;
                    collider.velocity.x = -moveComp.maxSpeed.x;
                } else {
                    collider.velocity.y = -jumpComp.jumpVelocity * jumpComp.factor;
                    collider.velocity.x = -(moveComp.maxSpeed.x + Settings.UNIT);
                    // collider.velocity.x = -jumpComp.jumpVelocity * 1 * jumpComp.factor;
                }
            }
        }

    }

    
}



