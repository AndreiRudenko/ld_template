package components.physics;

import luxe.Component;
import luxe.Vector;
import luxe.utils.Maths;

import utils.ShapeDrawer;


class Velocity extends Component{


	public var tag:String = "";

	public var position:Vector;
	public var velocity:Vector;

	public var active( default, set ):Bool = true;

	// public var freezeX:Bool = false;
	// public var freezeY:Bool = false;

	public var maxSpeed:Float = 3840; // 64 px per frame

	public var mass( default, set ):Float;

	public var invMass( default, null ):Float;

	public var damping(default, set):Float = 0;

	var force:Vector;

	var ignore_position_listener:Bool = false;


	@:noCompletion public function new() {

		super({name : "Collider"});

		position = new Vector();
		velocity = new Vector();
		force = new Vector();
		
		mass = 1;

	}

	override public function init() {}    

	override public function onadded() {

		position = entity.pos.clone();
		entity.transform.listen_pos(updateColliderPosition);

	}    

	override public function onremoved() {}   
	
	override public function update(dt:Float) {

		if(!active) {
			return;
		}

		updateVelocity(dt);
		clampVelocity();
		dampenVelocity();
		integratePosition(dt);
		
		updateEntityPosition();

	}

	inline function updateVelocity(dt:Float) {

		velocity.x += (force.x * invMass) * dt;
		velocity.y += (force.y * invMass) * dt;

		force.x = 0;
		force.y = 0;

	}

	inline function dampenVelocity() {

		// "cheap" damping for constant dt
		velocity.x *= 1.0 - damping;
		velocity.y *= 1.0 - damping;

		// frame independent damping
		// velocity.x *= 1.0 / (1.0 + damping * dt);
		// velocity.y *= 1.0 / (1.0 + damping * dt);

	}

	inline function clampVelocity(){

		velocity.x = Maths.clamp(velocity.x, -maxSpeed, maxSpeed);
		velocity.y = Maths.clamp(velocity.y, -maxSpeed, maxSpeed);

/*        if(maxSpeed > 0){
			var msSq:Float = maxSpeed * maxSpeed;
			if(velocity.lengthsq > msSq){
				var ratio:Float = maxSpeed / velocity.length;
				velocity.x *= ratio;
				velocity.y *= ratio;
			}
		}*/

	}

	inline public function integratePosition(dt:Float) {

		position.x += velocity.x * dt;
		position.y += velocity.y * dt;

	}

	inline public function updateEntityPosition() {

		ignore_position_listener = true;

		pos.x = position.x + offset.x;
		pos.y = position.y + offset.y;
		// pos.x = Math.round(position.x + offset.x);
		// pos.y = Math.round(position.y + offset.y);

		ignore_position_listener = false;

	}


	inline public function updateColliderPosition(_pos:Vector):Void {

		if(!ignore_position_listener){
			position.x = _pos.x;
			position.y = _pos.y;
		}

	}

	inline public function addForce(_x:Float, _y:Float){

		if(!active) {
			return;
		}

		force.x += _x;
		force.y += _y;

	}

	inline public function addVelocity(_x:Float, _y:Float){

		if(!active) {
			return;
		}

		velocity.x += _x;
		velocity.y += _y;

	}

	inline public function applyImpulse(_x:Float, _y:Float){

		if(!active) {
			return;
		}

		velocity.x += _x * invMass;
		velocity.y += _y * invMass;

	}

	inline function set_damping(value:Float):Float {
		return damping = Maths.clamp(value, 0, 1);
	}

	function set_mass(_value:Float):Float{

		if(_value > 0 ){
			mass = _value;
			invMass = 1.0/mass;
		} else {
			mass = 0;
			invMass = 0;
		}

		return mass;

	}

	function set_active(value:Bool):Bool{

		active = value;

		return active;

	}


	public function draw(){

		if(!active) {
			return;
		}

		var nextPos:Vector = new Vector();

		nextPos.x = position.x + velocity.x * Luxe.fixed_frame_time;
		nextPos.y = position.y + velocity.y * Luxe.fixed_frame_time;

	}


}    
