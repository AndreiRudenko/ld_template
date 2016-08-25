package components.physics;

import luxe.Component;
import luxe.Vector;

import luxe.utils.Maths;
import utils.ShapeDrawer;

import physics.Contact;
import physics.AABB;
import physics.CollisionFaces;

import physics.collision.IntersectAABB;


class Collider extends Component{


		/** collider types */
	public static inline var SOLID:Int = 1;
	public static inline var PLAYER:Int = 1 << 1;
	public static inline var MOVABLE:Int = 1 << 2;
	public static inline var ITEM:Int = 1 << 3;
	public static inline var ENEMY:Int = 1 << 4;


		/** collider type */
	public var type : Int = 0;
		/** collider tag */
	public var tag : String = "";

		/** collider isTrigger */
	public var isTrigger : Bool = false;

	// public var freezeX : Bool = false;
	// public var freezeY : Bool = false;

		/** collider position */
	public var position : Vector;
		/** Collider velocity */
	public var velocity : Vector;
		/** Collider half */
	public var half : Vector;
		/** Collider offset */
	public var offset : Vector;

		/** Collider restitution */
	public var restitution : Float = 0;
		/** Collider restitution with terrain */
	public var restitutionTerrain : Float = 0;

		/** Collision group for filtering */
	public var collisionGroup : Int = 0x00000001;
		/** Collision mask for filtering */
	public var collisionMask : Int = 0xFFFFFFFF;

		/* Contact list */
	@:noCompletion public var contacts : Contact;

		/* Colliders list */
	@:noCompletion public var next : Collider;
	@:noCompletion public var prev : Collider;

		/** Bounds for broadphase */
	public var aabb (default, null) : AABB;

		/** Collider active */
	public var active        	( default, set ) : Bool = true;
		/** Collider allow collision */
	public var allowCollision	( default, set ) : Bool = true;

		/** Collider maxSpeed */
	public var maxSpeed (get, set) : Int; // px per frame

        /** Collider width */
	public var w (get, set) : Float;
        /** Collider height */
	public var h (get, set) : Float;

        /** Collider mass */
	public var mass   	( default, set ) : Float;
        /** Collider inverted mass */
	public var invMass	( default, null ) : Float;
        /** Collider damping */
	public var damping (default, set) : Float = 0;

        /** Returns collider is collide */
	public var isCollide   	(get, never) : Bool;
        /** Returns collider is touching from left */
	public var isTouchLeft 	(get, never) : Bool;
        /** Returns collider is touching from right */
	public var isTouchRight	(get, never) : Bool;
        /** Returns collider is touching from up */
	public var isTouchUp   	(get, never) : Bool;
        /** Returns collider is touching from bottom */
	public var isTouchDown 	(get, never) : Bool;

		/** Spatial hash grid index */
	@:allow(physics.SpatialHash)
	var gridIndex : Array<Int>;
	
		/** Collider force */
	var force : Vector;

		/** for update entity position listener */
	var ignore_position_listener : Bool = false;

		/** Collider touching */
	var touching : Int = 0;
		/** Collider was touched */
	var wasTouching : Int = 0;

	var _maxSpeed : Float = 3840; // 64 px per frame

	@:noCompletion public function new() {

		super({name : "Collider"});

		half = new Vector(32, 32);
		position = new Vector();
		offset = new Vector();
		velocity = new Vector();
		force = new Vector();
		aabb = new AABB();
		
		mass = 1;

		gridIndex = [];

	}

	// override public function init() {}    

	override public function onadded() {

		position = entity.pos.clone();
		entity.transform.listen_pos(updateColliderPosition);

		var sprite:luxe.Sprite = cast entity;

		if(sprite != null){
			half.x = sprite.size.x * 0.5;
			half.y = sprite.size.y * 0.5;
		}

		updateAABB();
		Physics.AddCollider(this);
		
	}    

	override public function onremoved() {

		Physics.RemoveCollider(this);

	}   
	
	override public function update(dt:Float) {

		if(!active) {
			return;
		}

		Physics.debugStart();

		updateVelocity(dt);

		if(allowCollision){
			checkCollision(dt);
		} else {
			clampVelocity();
			dampenVelocity();
			integratePosition(dt);
		}

		// бывает когда entity уничтожается во время столкновения
		if(entity.destroyed) {
			return;
		}

		updateEntityPosition();

		if(allowCollision) {
			Physics.UpdateCollider(this);
		}

		Physics.debugEnd();
		
		if(Main._usePause) { // TODO: remove this
			entity.active = false;
		}

	}

	inline public function updateContacts(){

		Physics.UpdateCollider(this);
		Physics.FindContacts(this);

	}

	public function onCollision(_other:Collider){

		if(_other == null || _other.entity.destroyed) {
			return;
		}
		
		if(script != null) {
			script.onCollision(_other);
		}

	}

	public function collide(px:Float, py:Float, _type:Int = -1):Collider {

		updateContacts();

		var c:Contact = contacts;

		if(_type == -1){
			while(c != null) {
				if(c.otherCollider.overlapBox( px, py, half.x, half.y ) ) return c.otherCollider;
				c = c.next;
			}
		} else {
			while(c != null) {
				if(c.otherCollider.type == _type && c.otherCollider.overlapBox( px, py, half.x, half.y ) ) return c.otherCollider;
				c = c.next;
			}
		}

		return null;

	}

	public function collideWith(px:Float, py:Float, other:Collider):Collider {

		if(other.overlapBox( px, py, half.x, half.y ) ) {
			return other;
		}

		return null;

	}

	inline public function overlapBox(px:Float, py:Float, hx:Float, hy:Float ):Bool{

		if(Math.abs(position.x - px) > half.x + hx) return false;
		if(Math.abs(position.y - py) > half.y + hy) return false;

		return true;

	}

	inline public function overlapPoint(px:Float, py:Float):Bool {

		if(Math.abs(position.x - px) > half.x) return false;
		if(Math.abs(position.y - py) > half.y) return false;

		return true;

	}

	inline public function isTouching(dir:Int):Bool{

		if(touching & dir != 0) return true;

		return false;

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

			if(!active) {
				Physics.UpdateCollider(this);
			}
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

	inline public function applyImpulse(_x:Float, _y:Float) {

		if(!active) {
			return;
		}

		velocity.x += _x * invMass;
		velocity.y += _y * invMass;

	}


	public function updateAABB() {

		aabb.min.x = position.x - (half.x + 2);
		aabb.min.y = position.y - (half.y + 2);
		aabb.max.x = position.x + (half.x + 2);
		aabb.max.y = position.y + (half.y + 2);

	}

	inline function checkCollision(dt:Float) {

		var c:Contact;
		var other:Collider;

		wasTouching = touching;
		touching = 0; // reset collision faces
		
		updateContacts();

		c = contacts;

		while(c != null) {
			if(IntersectAABB.test(c)){
				findCollisionFaces_Fast(c);
				if(velocity.dot(c.normal) < 0.0){
					velocitySolver(c);
				}
			}
			c = c.next;
		}

		// solve velocity discrete
		position.x += velocity.x * dt;
		position.y += velocity.y * dt; 

		updateContacts();

		c = contacts;

		while(c != null) {
			if(IntersectAABB.test(c)){
				if(velocity.dot(c.normal) <= 0.0){
					velocitySolver(c);
				}
			}
			c = c.next;
		}

		// solve position
		c = contacts;

		while(c != null) {
			if(IntersectAABB.test(c)){

				c.isCollide = true;

				positionSolver(c);

				findCollisionFaces(c);

				other = c.otherCollider;
				onCollision(other);

				if(other != null && !other.entity.destroyed) {
					other.onCollision(this);
				}

			} else {
				c.isCollide = false;
			}

			c = c.next;
		}

	}

	function velocitySolver(c:Contact) {

		if(c.otherCollider.isTrigger || isTrigger) {
			return;
		}
		
		// if(c.normal.x != 0) velocity.x *= -restitution;
		// if(c.normal.y != 0) velocity.y *= -restitution;


		var normImp:Float = (-(1 + restitution) * velocity.dot(c.normal));

		if(c.otherCollider.active && velocity.dot(c.otherCollider.velocity) < 0) {
			var normImpOther:Float = (-(1 + c.otherCollider.restitution) * c.otherCollider.velocity.dot(c.normal));

			c.otherCollider.velocity.x += normImpOther * c.normal.x;
			c.otherCollider.velocity.y += normImpOther * c.normal.y;
		}

		velocity.x += normImp * c.normal.x;
		velocity.y += normImp * c.normal.y;

	}

	function positionSolver(c:Contact) {

		if(c.otherCollider.isTrigger || isTrigger) {
			return;
		}

		position.x += c.separation * c.normal.x;
		position.y += c.separation * c.normal.y;

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

		velocity.x = Maths.clamp(velocity.x, -_maxSpeed, _maxSpeed);
		velocity.y = Maths.clamp(velocity.y, -_maxSpeed, _maxSpeed);

/*        if(_maxSpeed > 0){
			var msSq:Float = _maxSpeed * _maxSpeed;
			if(velocity.lengthsq > msSq){
				var ratio:Float = _maxSpeed / velocity.length;
				velocity.x *= ratio;
				velocity.y *= ratio;
			}
		}*/

	}

	inline function findCollisionFaces(c:Contact) {

		if(c.otherCollider.isTrigger) {
			return;
		}

		if(c.normal.x > 0){
			touching |= CollisionFaces.LEFT;
			if(c.otherCollider.type == Collider.SOLID) touching |= CollisionFaces.LEFT_SOLID;
			if(c.otherCollider.type == Collider.ITEM) touching |= CollisionFaces.LEFT_ITEM;
			if(c.otherCollider.type == Collider.ENEMY) touching |= CollisionFaces.LEFT_ENEMY;
			if(c.otherCollider.type == Collider.PLAYER) touching |= CollisionFaces.LEFT_PLAYER;
			if(c.otherCollider.type == Collider.MOVABLE) touching |= CollisionFaces.LEFT_MOVABLE;
		} else if(c.normal.x < 0){
			touching |= CollisionFaces.RIGHT;
			if(c.otherCollider.type == Collider.SOLID) touching |= CollisionFaces.RIGHT_SOLID;
			if(c.otherCollider.type == Collider.ITEM) touching |= CollisionFaces.RIGHT_ITEM;
			if(c.otherCollider.type == Collider.ENEMY) touching |= CollisionFaces.RIGHT_ENEMY;
			if(c.otherCollider.type == Collider.PLAYER) touching |= CollisionFaces.RIGHT_PLAYER;
			if(c.otherCollider.type == Collider.MOVABLE) touching |= CollisionFaces.RIGHT_MOVABLE;
		}

		if(c.normal.y > 0){
			touching |= CollisionFaces.UP;
			if(c.otherCollider.type == Collider.SOLID) touching |= CollisionFaces.UP_SOLID;
			if(c.otherCollider.type == Collider.ITEM) touching |= CollisionFaces.UP_ITEM;
			if(c.otherCollider.type == Collider.ENEMY) touching |= CollisionFaces.UP_ENEMY;
			if(c.otherCollider.type == Collider.PLAYER) touching |= CollisionFaces.UP_PLAYER;
			if(c.otherCollider.type == Collider.MOVABLE) touching |= CollisionFaces.UP_MOVABLE;
		} else if(c.normal.y < 0){
			touching |= CollisionFaces.DOWN;
			if(c.otherCollider.type == Collider.SOLID) touching |= CollisionFaces.DOWN_SOLID;
			if(c.otherCollider.type == Collider.ITEM) touching |= CollisionFaces.DOWN_ITEM;
			if(c.otherCollider.type == Collider.ENEMY) touching |= CollisionFaces.DOWN_ENEMY;
			if(c.otherCollider.type == Collider.PLAYER) touching |= CollisionFaces.DOWN_PLAYER;
			if(c.otherCollider.type == Collider.MOVABLE) touching |= CollisionFaces.DOWN_MOVABLE;
		}

	}

	inline function findCollisionFaces_Fast(c:Contact) {

		if(c.otherCollider.isTrigger) {
			return;
		}

		if(c.normal.x > 0){
			touching |= CollisionFaces.LEFT;
		} else if(c.normal.x < 0){
			touching |= CollisionFaces.RIGHT;
		}

		if(c.normal.y > 0){
			touching |= CollisionFaces.UP;
		} else if(c.normal.y < 0){
			touching |= CollisionFaces.DOWN;
		}

	}

	inline function get_isTouchLeft():Bool{

		return isTouching(CollisionFaces.LEFT);

	}

	inline function get_isTouchRight():Bool{

		return isTouching(CollisionFaces.RIGHT);

	}

	inline function get_isTouchUp():Bool{

		return isTouching(CollisionFaces.UP);

	}

	inline function get_isTouchDown():Bool{

		return isTouching(CollisionFaces.DOWN);

	}

	
	inline function set_damping(value:Float):Float {

		return damping = Maths.clamp(value, 0, 1);

	}

	inline function get_isCollide():Bool {

		return touching != 0;

	}

	inline function set_w(value:Float):Float {

		return half.x = value * 0.5;

	}
	
	inline function set_h(value:Float):Float {

		return half.y = value * 0.5;

	}
	
	inline function get_w():Float {

		return half.x * 2;

	}
	
	inline function get_h():Float {

		return half.y * 2;

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

	function set_allowCollision(value:Bool):Bool{

		allowCollision = value;

		if(allowCollision){
			Physics.AddCollider(this);
		} else {
			Physics.RemoveCollider(this);
		}

		return allowCollision;

	}

	function set_active(value:Bool):Bool{

		active = value;

		Physics.UpdateCollider(this);

		return active;

	}

	function get_maxSpeed():Int{

		return Std.int(_maxSpeed / 60);

	}

	function set_maxSpeed(value:Int):Int{

		_maxSpeed = value * 60;

		return value;

	}

	public function draw(){

		if(active){
			var nextPos:Vector = new Vector();

			nextPos.x = position.x + velocity.x * Luxe.fixed_frame_time;
			nextPos.y = position.y + velocity.y * Luxe.fixed_frame_time;
		
			ShapeDrawer.drawBox_MinMax(aabb.min, aabb.max, ShapeDrawer.color_gray_01);  

			ShapeDrawer.drawBox(nextPos, half, ShapeDrawer.color_green);
			ShapeDrawer.drawLine(position, nextPos, ShapeDrawer.color_green);
		}

		
		ShapeDrawer.drawBox(position, half, ShapeDrawer.color_yellow);


		// ShapeDrawer.drawText(position.x, position.y - 12, id);
		
		// ShapeDrawer.drawText(position.x, position.y - 64, "vel.x" + velocity.x);
		// ShapeDrawer.drawText(position.x, position.y - 48, "vel.y" + velocity.y);

		// ShapeDrawer.drawText(position.x, position.y - 112, "x" + position.x);
		// ShapeDrawer.drawText(position.x, position.y - 96, "y" + position.y);

	}


}    
